//
//  UIView+Corners.h
//  BHBL
//
//  Created by mei Wang on 16/10/28.
//  Copyright © 2016年 TYUN. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef NS_ENUM(NSInteger, CornersType) {
    
    CornersTypeNone,
    
    CornersTypeAll,
    
    CornersTypeTopRight,
    
    CornersTypeTopLeft,
    
    CornersTypeBottomRight,
    
    CornersTypeBottomLeft,
    
    CornersTypeTop,
    
    CornersTypeBottom,
    
    CornersTypeLeft,
    
    CornersTypeRight
    
};


@interface UIView (Corners)

//下圆角 是上圆角
- (void)cornersTop:(BOOL)top bottom:(BOOL)bottom radii:(CGFloat)radii;

//哪个角是圆角
- (void)corners:(UIRectCorner)corners radii:(CGFloat)radii;

- (void)addCornersWithType:(CornersType)type radii:(CGFloat)radii;


/**
 ** lineView:       需要绘制成虚线的view
 ** lineLength:     虚线的宽度
 ** lineSpacing:    虚线的间距
 ** lineColor:      虚线的颜色
 **/
- (void)drawDashLine:(UIView *)lineView
          lineLength:(int)lineLength
         lineSpacing:(int)lineSpacing
           lineColor:(UIColor *)lineColor
          offsetLeft:(CGFloat)offsetLeft
           offsetTop:(CGFloat)offsetTop
               width:(CGFloat)width;


@end
