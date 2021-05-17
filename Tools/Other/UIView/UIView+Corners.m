//
//  UIView+Corners.m
//  BHBL
//
//  Created by mei Wang on 16/10/28.
//  Copyright © 2016年 TYUN. All rights reserved.
//

#import "UIView+Corners.h"

@implementation UIView (Corners)

- (void)cornersTop:(BOOL)top bottom:(BOOL)bottom radii:(CGFloat)radii {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIBezierPath *maskPath;
        if (top) {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(radii,radii)];
        }
        if (bottom) {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(radii,radii)];
        }
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
    });
}

//哪个角是圆角
- (void)corners:(UIRectCorner)corners radii:(CGFloat)radii {
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radii,radii)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

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
               width:(CGFloat)width {
    dispatch_async(dispatch_get_main_queue(), ^{
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setFillColor:[UIColor clearColor].CGColor];
        //  设置虚线颜色
        [shapeLayer setStrokeColor:lineColor.CGColor];
        //  设置虚线宽度
        [shapeLayer setLineWidth:0.8];
        [shapeLayer setLineJoin:kCALineJoinRound];
        //  设置线宽，线间距
        [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
        //  设置路径
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, offsetLeft, offsetTop);
        CGPathAddLineToPoint(path, NULL,width, offsetTop);
        [shapeLayer setPath:path];
        CGPathRelease(path);
        //  把绘制好的虚线添加上来
        [lineView.layer addSublayer:shapeLayer];
    });
}

- (void)addCornersWithType:(CornersType)type radii:(CGFloat)radii {
    UIRectCorner corner = 0;
    switch (type) {
        case CornersTypeAll: {
            corner = UIRectCornerTopRight | UIRectCornerTopLeft | UIRectCornerBottomRight | UIRectCornerBottomLeft;
        }
            break;
        case CornersTypeTopRight: {
            corner = UIRectCornerTopRight;
        }
            break;
        case CornersTypeTopLeft: {
            corner = UIRectCornerTopLeft;
        }
            break;
        case CornersTypeBottomRight: {
            corner = UIRectCornerBottomRight;
        }
            break;
        case CornersTypeBottomLeft: {
            corner = UIRectCornerBottomLeft;
        }
            break;
        case CornersTypeTop: {
            corner = UIRectCornerTopRight | UIRectCornerTopLeft;
        }
            break;
        case CornersTypeBottom: {
            corner = UIRectCornerBottomRight | UIRectCornerBottomLeft;
        }
            break;
        case CornersTypeLeft: {
            corner = UIRectCornerTopLeft | UIRectCornerTopLeft;
        }
            break;
        case CornersTypeRight: {
            corner = UIRectCornerTopRight | UIRectCornerTopRight;
        }
            break;
            case CornersTypeNone:
            break;
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radii,radii)];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        
        maskLayer.frame = self.bounds;
        
        maskLayer.path = maskPath.CGPath;
        
        self.layer.mask = maskLayer;
    });
}




@end
