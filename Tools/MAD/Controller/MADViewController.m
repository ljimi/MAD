//
//  ViewController.m
//  test
//
//  Created by Sunror on 2019/3/1.
//  Copyright © 2019 Sunror. All rights reserved.
//

#import "MADViewController.h"
#import "MADSnapshotButton.h"
#import "MADCameraCaptureView.h"
#import "MADEditViewController.h"
#import "Tool.h"
#import "MADManager.h"
@interface MADViewController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

// 返回按钮
//@property (nonatomic,strong) UIButton *sureBtn;
// 闪光灯按钮
@property (nonatomic,strong) UIButton *flashLigthToggle;
// 拍照按钮
@property (nonatomic, strong) MADSnapshotButton *snapshotBtn;
// 拍照视图
@property (nonatomic, strong) MADCameraCaptureView *captureCameraView;
// 聚焦指示器
@property (nonatomic, strong) UIView *focusIndicator;

@end

@implementation MADViewController

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blueColor;
    self.navigationController.delegate = self;
    [self initUI];
    // 设置需要更新约束
    [self.view setNeedsUpdateConstraints];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // 关闭闪光灯
    self.captureCameraView.enableTorch = NO;
    // 停止捕获图像
    [self.captureCameraView stop];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // 开始捕获图像
    [self.captureCameraView start];
}

#pragma mark - engine
- (void)onFlashLigthToggle {
    BOOL enable = !self.captureCameraView.isTorchEnabled;
    self.captureCameraView.enableTorch = enable;
    [self updateTitleLabel];
}


- (void)onSnapshotBtn:(id)sender {

    // // 拍照视图
    [self.captureCameraView captureImageWithCompletionHandler:^(UIImage *data, CIRectangleFeature *borderDetectFeature) {

        MADEditViewController *vc = [MADEditViewController new];
        vc.cropImage = data;
        [self.navigationController pushViewController:vc animated:YES];

    }];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateRecognized){
        CGPoint location = [sender locationInView:self.view];
        [self.captureCameraView focusAtPoint:location completionHandler:^
         {
             [self focusIndicatorAnimateToPoint:location];
         }];
        [self focusIndicatorAnimateToPoint:location];
    }
}

- (void)focusIndicatorAnimateToPoint:(CGPoint)targetPoint{
    [self.focusIndicator setCenter:targetPoint];
    self.focusIndicator.alpha = 0.0;
    self.focusIndicator.hidden = NO;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.focusIndicator.alpha = 1.0;
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.4 animations:^{
            self.focusIndicator.alpha = 0.0;
        }];
    }];
}

- (void)popSelf{
    
    if (self.Photos) {
        self.Photos([MADManager sharedInstance].photos);
        [[MADManager sharedInstance].photos removeAllObjects];
        [self.navigationController popViewControllerAnimated:YES];;
    }
    
}

// 更新
- (void)updateTitleLabel{
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    animation.duration = 0.5;
//    [self.navigationItem.titleView.layer addAnimation:animation forKey:@"kCATransitionFade"];
    self.title = self.captureCameraView.isTorchEnabled ? @"闪光灯 开" : @"闪光灯 关";
    [_flashLigthToggle setImage:[UIImage imageNamed:(self.captureCameraView.isTorchEnabled ? @"开灯" : @"关灯")] forState:UIControlStateNormal];
}

/**
 初始化视图
 */
- (void)initUI{
    
    // 导航栏
    

//    [view addSubview:self.flashLigthToggle];

    


    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.flashLigthToggle];
    
    // 拍照视图
    [self.view addSubview:self.captureCameraView];
    [self.captureCameraView setupCameraView];
    
    // 拍照按钮
    [self.view addSubview:self.snapshotBtn];
    // 添加聚焦指示器
    [self.view addSubview:self.focusIndicator];
    // 更新导航栏标题
    [self updateTitleLabel];
    
}

#pragma mark - Getter

- (UIView *)focusIndicator{
    if (!_focusIndicator) {
        _focusIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _focusIndicator.layer.borderWidth = 5.0f;
        _focusIndicator.layer.borderColor = [UIColor whiteColor].CGColor;
        _focusIndicator.alpha = 0;
    }
    return _focusIndicator;
}



//- (UIButton *)sureBtn{
//    if (!_sureBtn) {
//        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_sureBtn setTitle:@"完成" forState:UIControlStateNormal];
//        _sureBtn.adjustsImageWhenHighlighted = NO;
//        [_sureBtn addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _sureBtn;
//}


- (UIButton *)flashLigthToggle{
    if (!_flashLigthToggle) {
        _flashLigthToggle = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashLigthToggle setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
        [_flashLigthToggle setTitle:@"o0o" forState:UIControlStateNormal];
        _flashLigthToggle.titleLabel.font = [UIFont systemFontOfSize:17];
        _flashLigthToggle.adjustsImageWhenHighlighted = NO;
        [_flashLigthToggle addTarget:self action:@selector(onFlashLigthToggle) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashLigthToggle;
}

- (MADSnapshotButton *)snapshotBtn{
    if (!_snapshotBtn) {
        _snapshotBtn = [MADSnapshotButton new];
        [_snapshotBtn addTarget:self action:@selector(onSnapshotBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _snapshotBtn;
}

- (MADCameraCaptureView *)captureCameraView{
    if (!_captureCameraView) {
        _captureCameraView = [[MADCameraCaptureView alloc] initWithFrame:CGRectZero];
        //打开边缘检测
        [_captureCameraView setEnableBorderDetection:YES];
        _captureCameraView.backgroundColor = [UIColor blackColor];
    }
    return _captureCameraView;
}

#pragma mark - Contraints
- (void)updateViewConstraints{
    [super updateViewConstraints];
    

//    [_sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-10);
//        make.centerY.mas_equalTo(@0);
//        make.size.mas_equalTo(CGSizeMake(40, 40));
//    }];

//    [_flashLigthToggle mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(_sureBtn.mas_left).offset(15);
//        make.centerY.mas_equalTo(@0);
//        make.size.mas_equalTo(CGSizeMake(18, 18));
//    }];
    
    [_snapshotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(65, 65));
        make.bottom.mas_equalTo(-25);
        make.centerX.mas_equalTo(self.view);
    }];
    
    [_captureCameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(NAVBARHEIGHT);
        make.bottom.mas_equalTo(-110);
    }];
}



@end
