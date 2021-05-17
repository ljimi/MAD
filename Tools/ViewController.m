//
//  ViewController.m
//  Tools
//
//  Created by fission on 2021/5/17.
//

#import "ViewController.h"
#import "MADViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = UIColor.redColor;
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
        make.width.height.equalTo(@100);
    }];
    
    
}

-(void)click{
    
    MADViewController *vc = [MADViewController new];
    [self.navigationController pushViewController:vc animated:YES];
    
}


@end
