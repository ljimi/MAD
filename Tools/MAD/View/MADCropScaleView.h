//
//  MADCropScaleView.h
//  MADDocScan
//
//  Created by Sunror on 2017/11/8.
//  Copyright © 2017年 Sunror. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MADCropScaleView;
@protocol MADCropScaleViewDelegate <NSObject>

@optional

/// 绘制之前调用
- (void) beforeScaleViewTouched:(MADCropScaleView *) scaleView;
/// 绘制之后调用
- (void) afterScaleViewCleared:(MADCropScaleView *) scaleView;
/// 重置状态
- (void)reset;

@end

@interface MADCropScaleView : UIView

@property (nonatomic, assign) id <MADCropScaleViewDelegate> delegate;

@property (nonatomic, assign,readonly) CGPoint topLeftPoint;
@property (nonatomic, assign,readonly) CGPoint topRightPoint;
@property (nonatomic, assign,readonly) CGPoint bottomLeftPoint;
@property (nonatomic, assign,readonly) CGPoint bottomRightPoint;



// 划线宽度
@property (nonatomic, assign) NSInteger panWidth;
// 四角圆形半径
@property (nonatomic, assign) CGFloat cornerCircleRedis;
// 划线颜色
@property (nonatomic, strong) UIColor *panStrokColor;
// 初始截取框位置, 矩形
@property (nonatomic, assign) CGRect cropperFrame;

- (void)setCornerPointsWithTopLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight;

@end
