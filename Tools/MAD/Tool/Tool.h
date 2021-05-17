//
//  Tool.h
//  MADDocScan
//
//  Created by Sunror on 2019/2/28.
//  Copyright © 2019 Sunror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MADCGTransfromHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface Tool : NSObject
// 将任意四边形转换成长方形
+ (CIImage *)correctPerspectiveForImage:(CIImage *)image withFeatures:(CIRectangleFeature *)rectangleFeature;
/// 将任意四边形转换成长方形
+ (CIImage *)correctPerspectiveForImage:(CIImage *)image withFeaturesRect:(TransformCIFeatureRect)rectangleFeatureRect;
+ (void)saveImage:(UIImage *)image;

// 添加边缘识别遮盖
+ (CIImage *)drawHighlightOverlayForPoints:(CIImage *)image topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight;
// 高精度边缘识别器
+ (CIDetector *)highAccuracyRectangleDetector;
// 低精度边缘识别器
+ (CIDetector *)rectangleDetetor;
// 选取feagure rectangles中最大的矩形
+ (CIRectangleFeature *)biggestRectangleInRectangles:(NSArray *)rectangles;

//滤镜
+ (CIImage *)filteredImageUsingContrastFilterOnImage:(CIImage *)image;
+ (CIImage *)filteredImageUsingEnhanceFilterOnImage:(CIImage *)image;
//扣图
+ (UIImage *) cropImageWithImageV:(UIImage*)image topLift:(CGPoint)topLift topRight:(CGPoint)topRight bottomLift:(CGPoint)bottomLift bottomRight:(CGPoint)bottomRight;

@end

NS_ASSUME_NONNULL_END
