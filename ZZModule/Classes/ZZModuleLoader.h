//
//  ZZModuleLoader.h
//  Nimble
//
//  Created by Chuan on 2020/3/5.
//

#import <Foundation/Foundation.h>

#define ZZModuleScheme(string) \
+ (NSString *)scheme { \
    return string;\
}

NS_ASSUME_NONNULL_BEGIN

@interface ZZModuleLoader : NSObject

@end

NS_ASSUME_NONNULL_END
