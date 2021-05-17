//
//  NewViewController.h
//  test
//
//  Created by Sunror on 2019/3/1.
//  Copyright © 2019 Sunror. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface MADEditViewController : UIViewController
@property (nonatomic, strong) UIImage *cropImage;
@property (nonatomic, strong) CIRectangleFeature *borderDetectFeature;

@end

NS_ASSUME_NONNULL_END
