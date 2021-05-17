//
//  MADManager.m
//  ManJiCloud
//
//  Created by Sunror on 2019/3/6.
//  Copyright © 2019 ManJiCloud. All rights reserved.
//

#import "MADManager.h"

@implementation MADManager
static id _instance = nil;

+(instancetype)sharedInstance{
    return [[self alloc] init];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    //只进行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init{
    // 只进行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return  _instance;
}
+ (id)copyWithZone:(struct _NSZone *)zone{
    return  _instance;
}
+ (id)mutableCopyWithZone:(struct _NSZone *)zone{
    return _instance;
}
- (id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}

-(NSMutableArray *)photos{
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}

-(NSMutableArray *)assets{
    if (!_assets) {
        _assets = [NSMutableArray array];
    }
    return _assets;
}

+(NSString *)getFilePathStrWith:(NSString *)string{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",string]];
}

+(void)deledateAllFileFromPaths{
    
    MADManager *mad = [MADManager sharedInstance];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    for (NSDictionary *dic in mad.assets) {
    
        BOOL isDelete = [manager removeItemAtPath:[MADManager getFilePathStrWith:dic[@"name"]] error:nil];
        if (isDelete) {
//            NSLog(@"Account删除成功");
        }else{
//            NSLog(@"Account删除失败");
        }
    }
    
}

@end
