//
//  CCHelper.m
//  CCExcelView
//
//  Created by luo on 2018/3/29.
//  Copyright © 2018年 luo. All rights reserved.
//

#import "CCHelper.h"

@implementation CCHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static CCHelper *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (void)dealloc {
    
}

@end

NSString *const CCResourcesMainBundleName = @"CCExcelResources.bundle";

@implementation CCHelper (Bundle)

+ (NSBundle *)resourcesBundle {
    return [CCHelper resourcesBundleWithName:CCResourcesMainBundleName];
}

+ (NSBundle *)resourcesBundleWithName:(NSString *)bundleName {
    NSDictionary *bundleData = [self parseBundleName:bundleName];
    if (!bundleData) {
        return nil;
    }
    NSString *name = bundleData[@"name"];
    NSString *type = bundleData[@"type"];

    // CocoaPods：资源拷贝到 mainBundle
    NSBundle *bundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundleName]];
    if (bundle) {
        return bundle;
    }

    NSBundle *classBundle = [NSBundle bundleForClass:[self class]];

    // 动态 Framework / 部分 Pod 集成：资源在 framework 根目录
    NSString *path = [classBundle pathForResource:name ofType:type];
    if (path) {
        return [NSBundle bundleWithPath:path];
    }

#if SWIFT_PACKAGE
    // SwiftPM：优先使用自动生成的 module resource bundle
    path = [SWIFTPM_MODULE_BUNDLE pathForResource:name ofType:type];
    if (path) {
        return [NSBundle bundleWithPath:path];
    }
#endif

    // SwiftPM 兜底：PackageName_TargetName.bundle（静态链到 App 时 classBundle 可能是 mainBundle）
    for (NSBundle *candidate in @[classBundle, [NSBundle mainBundle]]) {
        NSString *spmPath = [candidate pathForResource:@"CCExcelView_CCExcelView" ofType:@"bundle"];
        if (!spmPath) {
            continue;
        }
        NSBundle *spmBundle = [NSBundle bundleWithPath:spmPath];
        path = [spmBundle pathForResource:name ofType:type];
        if (path) {
            return [NSBundle bundleWithPath:path];
        }
    }

    return nil;
}

+ (UIImage *)imageWithName:(NSString *)name {
    NSBundle *bundle = [CCHelper resourcesBundle];
    return [CCHelper imageInBundle:bundle withName:name];
}

+ (UIImage *)imageInBundle:(NSBundle *)bundle withName:(NSString *)name {
    if (bundle && name) {
        if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
            return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
        } else {
            NSString *imagePath = [[bundle resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
            return [UIImage imageWithContentsOfFile:imagePath];
        }
    }
    return nil;
}

+ (NSDictionary *)parseBundleName:(NSString *)bundleName {
    NSArray *bundleData = [bundleName componentsSeparatedByString:@"."];
    if (bundleData.count == 2) {
        return @{@"name":bundleData[0], @"type":bundleData[1]};
    }
    return nil;
}

@end

@implementation CCHelper (NSStringSize)

+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font maxSize:(CGSize)maxSize {
    NSDictionary *attrs = @{NSFontAttributeName : font};
    if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        return [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    }
    return CGSizeZero;
}

@end

