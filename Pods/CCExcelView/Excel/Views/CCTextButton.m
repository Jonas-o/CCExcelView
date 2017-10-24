//
//  CCTextButton.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "CCTextButton.h"
#import "CCBorderMaker.h"
#import "CCUtil.h"
#import "NSString+size.h"

#define defaultTextButtonColor ColorLightGreen
#define defaultTextButtonHighlightedColor ColorGreen
#define defaultTextButtonUnEnabledColor ColorBack

@implementation CCTextButton {
    CGFloat _radius;
    CGFloat _borderWidth;
    UIColor *_borderColor;
}

@synthesize title;

- (instancetype)initWithText:(NSString *)text font:(UIFont *)font radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)color {
    if (self = [self initWithText:text font:font]) {
        [self setTitleColor:color forState:UIControlStateNormal];
        _radius = radius;
        _borderWidth = borderWidth;
        if (color) {
            _borderColor = color;
        } else {
            _borderColor = defaultTextButtonColor;
        }
        
        [CCBorderMaker borderView:self withCornerRadius:_radius width:_borderWidth color:_borderColor];
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size text:(NSString *)text font:(UIFont *)font radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)color {
    if (self = [self initWithText:text font:font]) {
        [self setTitleColor:color forState:UIControlStateNormal];
        self.frame = rectZP(size.width, size.height);
        _radius = radius;
        _borderWidth = borderWidth;
        if (color) {
            _borderColor = color;
        } else {
            _borderColor = defaultTextButtonColor;
        }
        if (borderWidth > 0 && color != nil) {
            [CCBorderMaker borderView:self withCornerRadius:_radius width:_borderWidth color:_borderColor];
        }
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size text:(NSString *)text font:(UIFont *)font {
    return [self initWithFrame:rectZPFromSize(size) text:text font:font];
}

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font {
    if (self = [super initWithFrame:frame]) {
        title = text;
        self.titleLabel.font = font;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setTitle:text forState:UIControlStateNormal];
        
        [self setTitleColor:defaultTextButtonColor forState:UIControlStateNormal];
        [self setTitleColor:defaultTextButtonHighlightedColor forState:UIControlStateHighlighted];
        [self setTitleColor:ColorBack forState:UIControlStateDisabled];
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text font:(UIFont *)font {
    if (self = [super init]) {
        title = text;
        self.titleLabel.font = font;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setTitle:text forState:UIControlStateNormal];
        
        [self setTitleColor:defaultTextButtonColor forState:UIControlStateNormal];
        [self setTitleColor:defaultTextButtonHighlightedColor forState:UIControlStateHighlighted];
        [self setTitleColor:ColorBack forState:UIControlStateDisabled];
        
        CGFloat height = [text heightWithFont:font width:MAXFLOAT];
        CGFloat width = [text widthWithFont:font height:height];
        CGRect frame = rectZP(width + 10, height + 10);
        self.frame = frame;
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
        [self setTitleColor:defaultTextButtonColor forState:UIControlStateNormal];
        if (_borderColor && _borderWidth > 0) {
            [CCBorderMaker borderView:self withCornerRadius:_radius width:_borderWidth color:_borderColor];
        }
    } else {
        [self setTitleColor:defaultTextButtonUnEnabledColor forState:UIControlStateNormal];
        if (_borderColor && _borderWidth > 0) {
            [CCBorderMaker borderView:self withCornerRadius:_radius width:_borderWidth color:defaultTextButtonUnEnabledColor];
        }
    }
}

@end
