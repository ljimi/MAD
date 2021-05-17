//
//  MADManager.h
//  ManJiCloud
//
//  Created by Sunror on 2019/3/6.
//  Copyright © 2019 ManJiCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MADManager : NSObject

@property(nonatomic, strong) NSMutableArray *photos;
@property(nonatomic, strong) NSMutableArray *assets;
+(instancetype)sharedInstance;
+(NSString *)getFilePathStrWith:(NSString *)string;
+(void)deledateAllFileFromPaths;
@end

NS_ASSUME_NONNULL_END
