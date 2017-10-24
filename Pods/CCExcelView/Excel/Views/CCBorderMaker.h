//
//  CCBorderMaker.h
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCBorderMaker : NSObject

+ (void) borderView:( UIView * _Nonnull ) view withCornerRadius:(CGFloat) radius width:(CGFloat)borderWidth color:(UIColor * _Nonnull)borderColor;


+ (void) borderView:( UIView * _Nonnull ) view withCornerRadius:(CGFloat) radius width:(CGFloat)borderWidth color:(UIColor * _Nonnull)borderColor byRoundingCorners:(UIRectCorner)corners;

@end
