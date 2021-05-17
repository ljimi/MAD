//
//  UIImage+FixOrientation.h
//  Journey
//
//  Created by 魏辉 on 16/9/5.
//  Copyright © 2016年 CQUT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FixOrientation)
+ (UIImage *)fixOrientation:(UIImage *)aImage;
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

/**
 二值化
 */
+ (UIImage *)covertToGrayScale:(UIImage *)inPutImage;

/**
 转化灰度
 */
+ (UIImage *)grayImage:(UIImage *)inPutImage;
@end
