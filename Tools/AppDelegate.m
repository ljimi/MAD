//
//  AppDelegate.m
//  Tools
//
//  Created by fission on 2021/5/17.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    

    return YES;
}



@end
