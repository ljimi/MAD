//
//  MADCameraCaptureView.m
//  MADDocScan
//
//  Created by Sunror on 2017/11/1.
//  Copyright © 2017年 Sunror. All rights reserved.
//

#import "MADCameraCaptureView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <GLKit/GLKit.h>
#import "Tool.h"

@interface MADCameraCaptureView()<AVCaptureVideoDataOutputSampleBufferDelegate>{
    CIContext *_coreImageContext;
    GLuint _renderBuffer;
    GLKView *_glkView;
    BOOL _isStopped;
    CGFloat _imageDedectionConfidence;
    NSTimer *_borderDetectTimeKeeper;
    CIRectangleFeature *_borderDetectLastRectangleFeature;
    __block BOOL _isCapturing;

}

@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) AVCaptureDevice *captureDevice;
@property (nonatomic,strong) EAGLContext *context;
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
// 是否强制停止
@property (nonatomic, assign) BOOL forceStop;


@end
@implementation MADCameraCaptureView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        // 注册进入后台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_backgroundMode) name:UIApplicationWillResignActiveNotification object:nil];
        // 注册进入前台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_foregroundMode) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}


- (void)_backgroundMode{
    self.forceStop = YES;
}

- (void)_foregroundMode{
    self.forceStop = NO;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - egine
/// 开始捕获图像
- (void)start{
    _isStopped = NO;
    
    [self.captureSession startRunning];
    
    if (_borderDetectTimeKeeper) {
        [_borderDetectTimeKeeper invalidate];
    }
    [self hideGLKView:NO completion:nil];
}

// 停止捕获图像
- (void)stop{
    _isStopped = YES;
    [self.captureSession stopRunning];
    [_borderDetectTimeKeeper invalidate];
    [self hideGLKView:YES completion:nil];
}


// 设置手电筒
- (void)setEnableTorch:(BOOL)enableTorch{
    _enableTorch = enableTorch;
    
    AVCaptureDevice *device = self.captureDevice;
    if ([device hasTorch] && [device hasFlash]){
        [device lockForConfiguration:nil];
        if (enableTorch){
            [device setTorchMode:AVCaptureTorchModeOn];
        }else{
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}
// 设置闪光灯
- (void)setEnableFlash:(BOOL)enableFlash{
    _enableFlash = enableFlash;
    AVCaptureDevice *device = self.captureDevice;
    if ([device hasTorch] && [device hasFlash]){
        [device lockForConfiguration:nil];
        if (enableFlash){
            [device setTorchMode:AVCaptureTorchModeOn];
        }else{
            [device setFlashMode:AVCaptureFlashModeOff];
        }
        [device unlockForConfiguration];
    }
}


- (void)createGLKView{
    if (self.context) return;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = [[GLKView alloc] initWithFrame:self.bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.translatesAutoresizingMaskIntoConstraints = YES;
    view.context = self.context;
    view.contentScaleFactor = 1.0f;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self insertSubview:view atIndex:0];
    _glkView = view;
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    _coreImageContext = [CIContext contextWithEAGLContext:self.context];
    [EAGLContext setCurrentContext:self.context];
}

- (void)setupCameraView{
    [self createGLKView];
    
    NSArray *possibleDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = [possibleDevices firstObject];
    if (!device) return;
    
    _imageDedectionConfidence = 1.0;
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.captureSession = session;
    [session beginConfiguration];
    self.captureDevice = device;
    
    NSError *error = nil;
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    [session addInput:input];
    
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [dataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}];
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:dataOutput];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [session addOutput:self.stillImageOutput];
    
    AVCaptureConnection *connection = [dataOutput.connections firstObject];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    if (device.isFlashAvailable){
        [device lockForConfiguration:nil];
        [device setFlashMode:AVCaptureFlashModeOff];
        [device unlockForConfiguration];
        
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
            [device lockForConfiguration:nil];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        }
    }
    
    [session commitConfiguration];
}

// 聚焦动作
- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)(void))completionHandler{
    AVCaptureDevice *device = self.captureDevice;
    CGPoint pointOfInterest = CGPointZero;
    CGSize frameSize = self.bounds.size;
    pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
        NSError *error;
        if ([device lockForConfiguration:&error]){
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
                [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                [device setFocusPointOfInterest:pointOfInterest];
            }if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
                [device setExposurePointOfInterest:pointOfInterest];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                completionHandler();
            }
            
            [device unlockForConfiguration];
        }
    }else{
        completionHandler();
    }
}

// 隐藏glkview
- (void)hideGLKView:(BOOL)hidden completion:(void(^)(void))completion{
    [UIView animateWithDuration:0.1 animations:^{
        self->_glkView.alpha = (hidden) ? 0.0 : 1.0;
     }completion:^(BOOL finished){
         if (!completion) return;
         completion();
     }];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if (self.forceStop || _isStopped || _isCapturing || !CMSampleBufferIsValid(sampleBuffer)) return;
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    image = [Tool filteredImageUsingContrastFilterOnImage:image];
    
    if (self.context && _coreImageContext){
        // 将捕获到的图片绘制进_coreImageContext
        [_coreImageContext drawImage:image inRect:self.bounds fromRect:image.extent];
        [self.context presentRenderbuffer:GL_RENDERBUFFER];
        [_glkView setNeedsDisplay];
    }
}


/// 拍照动作
- (void)captureImageWithCompletionHandler:(CompletionHandler)completionHandler{
    if (_isCapturing) return;
    
    _isCapturing = YES;
    //关闭闪光灯
    [self setEnableFlash:NO];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections){
        for (AVCaptureInputPort *port in [connection inputPorts]){
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ){
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) break;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error){
        NSData *imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:imageSampleBuffer previewPhotoSampleBuffer:imageSampleBuffer];
        CIImage *enhancedImage = [CIImage imageWithData:imageData];
        UIGraphicsBeginImageContext(CGSizeMake(enhancedImage.extent.size.height, enhancedImage.extent.size.width));
        [[UIImage imageWithCIImage:enhancedImage scale:1.0 orientation:UIImageOrientationRight] drawInRect:CGRectMake(0,0, enhancedImage.extent.size.height, enhancedImage.extent.size.width)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        completionHandler(image, nil);
        self->_isCapturing = NO;
        
     }];
}


BOOL rectangleDetectionConfidenceHighEnough(float confidence){
    return (confidence > 1.0);
}

@end
