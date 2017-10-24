//
//  CCBorderMaker.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "CCBorderMaker.h"

@interface CCBorderLayer:CAShapeLayer

@end

@implementation CCBorderLayer

@end

@implementation CCBorderMaker

+ (void) borderView:( UIView * _Nonnull ) view withCornerRadius:(CGFloat) radius width:(CGFloat)borderWidth color:(UIColor * _Nonnull)borderColor {
    [self borderView:view withCornerRadius:radius width:borderWidth color:borderColor byRoundingCorners:UIRectCornerAllCorners];
    
}

+ (void) borderView:( UIView * _Nonnull ) view withCornerRadius:(CGFloat) radius width:(CGFloat)borderWidth color:(UIColor * _Nonnull)borderColor byRoundingCorners:(UIRectCorner)corners {
    NSMutableArray<CALayer *> * layers = [[view.layer sublayers] mutableCopy];
    [layers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[CCBorderLayer class]]) {
            [obj removeFromSuperlayer];
        }
    }];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CCBorderLayer *borderLayer = [CCBorderLayer layer];
    borderLayer.path = path.CGPath;
    borderLayer.lineWidth = borderWidth;
    borderLayer.strokeColor = borderColor.CGColor;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.frame = view.bounds;
    [view.layer addSublayer:borderLayer];
}

@end
