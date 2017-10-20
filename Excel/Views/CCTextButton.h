//
//  CCTextButton.h
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCTextButton : UIButton

@property (nonatomic, strong, readonly) NSString *title;

- (instancetype)initWithText:(NSString *)text font:(UIFont *)font radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)color;

- (instancetype)initWithSize:(CGSize)size text:(NSString *)text font:(UIFont *)font radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)color;

- (instancetype)initWithText:(NSString *)text font:(UIFont *)font;
- (instancetype)initWithSize:(CGSize)size text:(NSString *)text font:(UIFont *)font;
- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font;

@end
