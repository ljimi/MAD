//
//  Tool.m
//  MADDocScan
//
//  Created by Sunror on 2019/2/28.
//  Copyright © 2019 Sunror. All rights reserved.
//

#import "Tool.h"

@implementation Tool

+ (void)saveImage:(UIImage *)image {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"demo.png"]];  // 保存文件的名称
    BOOL result =[UIImagePNGRepresentation(image)writeToFile:filePath   atomically:YES]; // 保存成功会返回YES
    if (result == YES) {
        NSLog(@"保存成功");
    }
}

/// 将任意四边形转换成长方形
+ (CIImage *)correctPerspectiveForImage:(CIImage *)image withFeaturesRect:(TransformCIFeatureRect)rectangleFeatureRect{
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:rectangleFeatureRect.topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:rectangleFeatureRect.topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:rectangleFeatureRect.bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:rectangleFeatureRect.bottomRight];
    return [image imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
}


/// 将任意四边形转换成长方形
+ (CIImage *)correctPerspectiveForImage:(CIImage *)image withFeatures:(CIRectangleFeature *)rectangleFeature{
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:rectangleFeature.topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomRight];
    return [image imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
}


// 添加边缘识别遮盖

+ (CIImage *)drawHighlightOverlayForPoints:(CIImage *)image topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight{
    // overlay
    CIImage *overlay = [CIImage imageWithColor:[CIColor colorWithRed:73/255.0 green:130/255.0 blue:180/255.0 alpha:0.5]];
    overlay = [overlay imageByCroppingToRect:image.extent];
    
    overlay = [overlay imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:@{@"inputExtent":[CIVector vectorWithCGRect:image.extent],
                                                                                                       @"inputTopLeft":[CIVector vectorWithCGPoint:topLeft],
                                                                                                       @"inputTopRight":[CIVector vectorWithCGPoint:topRight],
                                                                                                       @"inputBottomLeft":[CIVector vectorWithCGPoint:bottomLeft],
                                                                                                       @"inputBottomRight":[CIVector vectorWithCGPoint:bottomRight]}];
    
    return [overlay imageByCompositingOverImage:image];
}


// 高精度边缘识别器
+ (CIDetector *)highAccuracyRectangleDetector{
    static CIDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
                  });
    return detector;
}
// 低精度边缘识别器
+ (CIDetector *)rectangleDetetor{
    static CIDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyLow,CIDetectorTracking : @(YES)}];
    });
    return detector;
}

// 选取feagure rectangles中最大的矩形
+ (CIRectangleFeature *)biggestRectangleInRectangles:(NSArray *)rectangles{
    if (![rectangles count]) return nil;
    float halfPerimiterValue = 0;
    CIRectangleFeature *biggestRectangle = [rectangles firstObject];
    for (CIRectangleFeature *rect in rectangles){
        CGPoint p1 = rect.topLeft;
        CGPoint p2 = rect.topRight;
        CGFloat width = hypotf(p1.x - p2.x, p1.y - p2.y);
        CGPoint p3 = rect.topLeft;
        CGPoint p4 = rect.bottomLeft;
        CGFloat height = hypotf(p3.x - p4.x, p3.y - p4.y);
        CGFloat currentHalfPerimiterValue = height + width;
        if (halfPerimiterValue < currentHalfPerimiterValue){
            halfPerimiterValue = currentHalfPerimiterValue;
            biggestRectangle = rect;
        }
    }
    return biggestRectangle;
}


+ (CIImage *)filteredImageUsingContrastFilterOnImage:(CIImage *)image{
    return [CIFilter filterWithName:@"CIColorControls" withInputParameters:@{@"inputContrast":@(1.2),kCIInputImageKey:image}].outputImage;
}


+ (CIImage *)filteredImageUsingEnhanceFilterOnImage:(CIImage *)image{
    return [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, image, @"inputBrightness", [NSNumber numberWithFloat:0.0], @"inputContrast", [NSNumber numberWithFloat:1.14], @"inputSaturation", [NSNumber numberWithFloat:0.0], nil].outputImage;
}


+ (UIImage *) cropImageWithImageV:(UIImage*)image topLift:(CGPoint)topLift topRight:(CGPoint)topRight bottomLift:(CGPoint)bottomLift bottomRight:(CGPoint)bottomRight{
    
    CGRect rect = CGRectZero;
    rect.size = image.size;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
    [[UIColor blackColor] setFill];
    UIRectFill(rect);
    [[UIColor whiteColor] setFill];
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [aPath moveToPoint:topLift];
    [aPath addLineToPoint:topRight];
    [aPath addLineToPoint:bottomRight];
    [aPath addLineToPoint:bottomLift];
    [aPath closePath];
    [aPath fill];
    [aPath addClip];
    
    
    CGRect myImageRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    
    //裁剪图片
    CGImageRef imageRef = image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    UIGraphicsBeginImageContext(myImageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage *maskedImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    return maskedImage;
}

@end
