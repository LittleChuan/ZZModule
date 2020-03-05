//
//  CViewController.m
//  ZZModule_Example
//
//  Created by Chuan on 2020/3/5.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#import "CViewController.h"
#import <ZZModuleLoader.h>

@interface CViewController ()

@end

@implementation CViewController

ZZModuleScheme(@"zz://test/c")

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
