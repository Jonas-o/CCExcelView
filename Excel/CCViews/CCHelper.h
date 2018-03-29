//
//  CCHelper.h
//  ccexcelView
//
//  Created by luo on 2018/3/29.
//  Copyright © 2018年 luo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIView+CCFrame.h"
#import "CCUtil.h"

@interface CCHelper : NSObject

+ (instancetype _Nonnull)sharedInstance;
@end

extern NSString *const _Nonnull CCResourcesMainBundleName;

@interface CCHelper (Bundle)

+ (nullable NSBundle *)resourcesBundle;
+ (nullable UIImage *)imageWithName:(nullable NSString *)name;

+ (nullable NSBundle *)resourcesBundleWithName:(nullable NSString *)bundleName;
+ (nullable UIImage *)imageInBundle:(nullable NSBundle *)bundle withName:(nullable NSString *)name;
@end

@interface CCHelper (NSStringSize)

+ (CGSize)sizeWithString:(NSString *_Nonnull)string font:(UIFont *_Nonnull)font maxSize:(CGSize)maxSize;
@end
