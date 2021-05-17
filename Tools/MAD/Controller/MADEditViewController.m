//
//  NewViewController.m
//  test
//
//  Created by Sunror on 2019/3/1.
//  Copyright © 2019 Sunror. All rights reserved.
//

#import "MADEditViewController.h"
#import "MADCGTransfromHelper.h"
#import "Tool.h"
#import "MADCropScaleView.h"
#import "MADShowImageViewController.h"
#import "UIImage+FixOrientation.h"

@interface MADEditViewController ()
@property (nonatomic, strong) MADCropScaleView *cropScaleView;
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIView *imageBack;
@property (nonatomic, strong) UIImage *inPutImage;
@end

@implementation MADEditViewController

-(void)sureActionButton:(UIButton *)sender{
    
    
    [SVProgressHUD show];
    // 拍照时候 设置了 UIImageOrientationRight， 所以要变换 extent
    // 转换成UIKit坐标系
    CGRect extent = CGRectMake(0, 0, _cropImage.size.width, _cropImage.size.height);
    TransformCIFeatureRect featureRect = [MADCGTransfromHelper md_transfromRealRectInPreviewRect:extent imageRect:_cropScaleView.frame topLeft:_cropScaleView.topLeftPoint topRight:_cropScaleView.topRightPoint bottomLeft:_cropScaleView.bottomLeftPoint bottomRight:_cropScaleView.bottomRightPoint];
    UIImage *newimage = [Tool cropImageWithImageV:_cropImage topLift:featureRect.topLeft topRight:featureRect.topRight bottomLift:featureRect.bottomLeft bottomRight:featureRect.bottomRight];

    CIImage *enhancedImage = [CIImage imageWithData:UIImagePNGRepresentation(newimage)];
    enhancedImage = [Tool correctPerspectiveForImage:enhancedImage withFeaturesRect:featureRect];
    
    // 获取图片
    UIGraphicsBeginImageContext(CGSizeMake(enhancedImage.extent.size.height, enhancedImage.extent.size.width));
    [[UIImage imageWithCIImage:enhancedImage scale:0.0 orientation:UIImageOrientationRight] drawInRect:CGRectMake(0,0, enhancedImage.extent.size.height, enhancedImage.extent.size.width)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [SVProgressHUD dismiss];
    MADShowImageViewController *vc = [[MADShowImageViewController alloc] init];
    vc.cropImage = [UIImage image:image rotation:UIImageOrientationLeft];
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.imageBack];
    [self.view addSubview:self.cropScaleView];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.finishBtn];
    [self layoutUI];
    
    
    _inPutImage = [UIImage grayImage:_cropImage];
    self.imageBack.layer.contents = (__bridge id _Nullable)(_cropImage.CGImage);
    
    CIImage *image = [CIImage imageWithData:UIImagePNGRepresentation(_inPutImage)];
    
    image = [Tool filteredImageUsingContrastFilterOnImage:image];
    // 用高精度边缘识别器 识别特征
    NSArray <CIFeature *>*features = [[Tool highAccuracyRectangleDetector] featuresInImage:image];
    // 选取特征列表中最大的矩形
    self.borderDetectFeature = [Tool biggestRectangleInRectangles:features];
    
    if (self.borderDetectFeature) {
        // 拍照时候 设置了 UIImageOrientationRight， 所以要变换 extent
        // 转换成UIKit坐标系
        CGRect extent = CGRectMake(0, 0, _cropImage.size.width, _cropImage.size.height);
        TransformCIFeatureRect rect =  [MADCGTransfromHelper transfromRealCIRectInPreviewRect:_imageBack.frame imageRect:extent topLeft:_borderDetectFeature.topLeft topRight:_borderDetectFeature.topRight bottomLeft:_borderDetectFeature.bottomLeft bottomRight:_borderDetectFeature.bottomRight];
        
        [_cropScaleView setCornerPointsWithTopLeft:rect.topLeft topRight:rect.topRight bottomLeft:rect.bottomLeft bottomRight:rect.bottomRight];
    }else{
        [_cropScaleView setCornerPointsWithTopLeft:CGPointMake(30, 30) topRight:CGPointMake(_cropScaleView.frame.size.width - 30, 30) bottomLeft:CGPointMake(30, _cropScaleView.frame.size.height - 30) bottomRight:CGPointMake(_cropScaleView.frame.size.width - 30, _cropScaleView.frame.size.height - 30)];
    }
    
}

#pragma mark - Getter

- (MADCropScaleView *)cropScaleView{
    if (!_cropScaleView) {
        _cropScaleView = [[MADCropScaleView alloc] initWithFrame:self.imageBack.frame];
    }
    return _cropScaleView;
}

- (UIButton *)finishBtn{
    if (!_finishBtn) {
        _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishBtn.backgroundColor = [UIColor whiteColor];
        [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_finishBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _finishBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_finishBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        _finishBtn.layer.cornerRadius = 35/2;
        _finishBtn.layer.masksToBounds = YES;
        [_finishBtn addTarget:self action:@selector(sureActionButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishBtn;
}

- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.backgroundColor = [UIColor whiteColor];
        [_backBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_backBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        _backBtn.layer.cornerRadius = 35/2;
        _backBtn.layer.masksToBounds = YES;
        [_backBtn addTarget:self action:@selector(onActionButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

#pragma mark - handler
- (void)onActionButton:(id)sender{
    if (sender == _backBtn) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(UIView *)imageBack{
    if (!_imageBack) {
        _imageBack = [[UIView alloc] initWithFrame:CGRectMake(0, NAVBARHEIGHT, SCREENWIDTH, SCREENWIDTH*_cropImage.size.height/_cropImage.size.width )];
    }
    return _imageBack;
}

#pragma mark - Layout
- (void)layoutUI{
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(-20);
        make.size.mas_equalTo(CGSizeMake(65, 35));
    }];
    
    [_finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-20);
        make.size.mas_equalTo(CGSizeMake(65, 35));
    }];
}



@end
