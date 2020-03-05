//
//  ZZModuleLoader.m
//  Nimble
//
//  Created by Chuan on 2020/3/5.
//

#import "ZZModuleLoader.h"
#import <ZZModule/ZZModule-Swift.h>

@implementation ZZModuleLoader

+ (void)load {
    [ZZModule loadPlist:nil];
}

@end
