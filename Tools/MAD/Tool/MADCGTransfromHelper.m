//
//  MADCGTransfromHelper.m
//  MADDocScan
//
//  Created by Sunror on 2017/11/3.
//  Copyright © 2017年 Sunror. All rights reserved.
//

#import "MADCGTransfromHelper.h"

@implementation MADCGTransfromHelper

+ (TransformCIFeatureRect)transfromRealCIRectInPreviewRect:(CGRect)previewRect imageRect:(CGRect)imageRect topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight{
    
    return [MADCGTransfromHelper md_transfromRealRectInPreviewRect:previewRect imageRect:imageRect isUICoordinate:NO topLeft:topLeft topRight:topRight bottomLeft:bottomLeft bottomRight:bottomRight];
}

+ (TransformCIFeatureRect)transfromRealCGRectInPreviewRect:(CGRect)previewRect imageRect:(CGRect)imageRect topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight{
    
    return [MADCGTransfromHelper md_transfromRealRectInPreviewRect:previewRect imageRect:imageRect isUICoordinate:YES topLeft:topLeft topRight:topRight bottomLeft:bottomLeft bottomRight:bottomRight];
}


+ (TransformCIFeatureRect)md_transfromRealRectInPreviewRect:(CGRect)previewRect imageRect:(CGRect)imageRect  isUICoordinate:(BOOL)isUICoordinate topLeft:(CGPoint)topLeft  topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight{
    
    // find ratio between the video preview rect and the image rect; rectangle feature coordinates are relative to the CIImage
    CGFloat deltaX = CGRectGetWidth(previewRect)/CGRectGetWidth(imageRect);
    CGFloat deltaY = CGRectGetHeight(previewRect)/CGRectGetHeight(imageRect);
    
    // transform to UIKit coordinate system
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0.f, CGRectGetHeight(previewRect));
    if (!isUICoordinate) {
        transform = CGAffineTransformScale(transform, 1, -1);
    }
    // apply preview to image scaling
    transform = CGAffineTransformScale(transform, deltaX, deltaY);
    TransformCIFeatureRect featureRect;
    featureRect.topLeft = CGPointApplyAffineTransform(topLeft, transform);
    featureRect.topRight = CGPointApplyAffineTransform(topRight, transform);
    featureRect.bottomRight = CGPointApplyAffineTransform(bottomRight, transform);
    featureRect.bottomLeft = CGPointApplyAffineTransform(bottomLeft, transform);

    return featureRect;
}

+ (TransformCIFeatureRect)md_transfromRealRectInPreviewRect:(CGRect)previewRect imageRect:(CGRect)imageRect topLeft:(CGPoint)topLeft  topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight{
    
    CGFloat deltaX = CGRectGetWidth(previewRect)/CGRectGetWidth(imageRect);
    CGFloat deltaY = CGRectGetHeight(previewRect)/CGRectGetHeight(imageRect);
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0.f, CGRectGetHeight(previewRect));
    transform = CGAffineTransformScale(transform, -1, 1);
    transform = CGAffineTransformScale(transform, deltaX, deltaY);
    transform = CGAffineTransformRotate(transform, M_PI);
    TransformCIFeatureRect featureRect;
    featureRect.topLeft = CGPointApplyAffineTransform(topLeft, transform);
    featureRect.topRight = CGPointApplyAffineTransform(topRight, transform);
    featureRect.bottomRight = CGPointApplyAffineTransform(bottomRight, transform);
    featureRect.bottomLeft = CGPointApplyAffineTransform(bottomLeft, transform);
    
    return featureRect;
}


@end
