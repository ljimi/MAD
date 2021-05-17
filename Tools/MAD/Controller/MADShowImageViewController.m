//
//  OpenCVEditImageViewController.m
//  test
//
//  Created by Sunror on 2019/3/1.
//  Copyright © 2019 Sunror. All rights reserved.
//

#import "MADShowImageViewController.h"
#import "Tool.h"
#import "MADManager.h"
#import "MADViewController.h"

@interface MADShowImageViewController ()
// 返回按钮
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *finishBtn;
@end

@implementation MADShowImageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.finishBtn];
    [self.view addSubview:self.imageBack];
    
    [self layoutUI];
    
    self.imageBack.layer.contents = (__bridge id _Nullable)(_cropImage.CGImage);
}


#pragma mark - handler
- (NSString *) getNameWithTime{
    
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmm"];
    NSString * dateString = [formatter stringFromDate:date];
    return dateString;
    
}



-(void)sureActionButton:(UIButton *)sender{

        [[MADManager sharedInstance].photos addObject:_cropImage];
//        [[MADManager sharedInstance].assets addObject:dic];
    
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[MADViewController class]]){
                MADViewController *vc = (MADViewController *)controller;
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
        UIViewController *controller = self.navigationController.viewControllers[1];
        [self.navigationController popToViewController:controller animated:YES];
//    }
    
    
}

- (void)onActionButton:(id)sender{
    if (sender == _backBtn) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
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


-(UIView *)imageBack{
    if (!_imageBack) {
        CGFloat X = 10;
        CGFloat W = SCREENWIDTH - X*2;
        CGFloat H = (SCREENWIDTH - X*2)*_cropImage.size.height/_cropImage.size.width;
        if (H > SCREENHEIGHT - 200) {
            H = SCREENHEIGHT - 200;
            W = (SCREENHEIGHT - 200)*_cropImage.size.width/_cropImage.size.height;
            X = (SCREENWIDTH - W)/2;
        }
        _imageBack = [[UIView alloc] initWithFrame:CGRectMake(X, NAVBARHEIGHT + 20, W, H )];
    }
    return _imageBack;
}

-(void)layoutUI{
    
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


