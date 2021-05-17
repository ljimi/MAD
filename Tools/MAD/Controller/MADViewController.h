//
//  ViewController.h
//  test
//
//  Created by Sunror on 2019/3/1.
//  Copyright © 2019 Sunror. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface MADViewController : UIViewController
@property(nonatomic, copy) void(^Photos)(NSMutableArray *photos);
@end

