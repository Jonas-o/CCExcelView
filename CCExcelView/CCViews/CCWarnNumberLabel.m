//
//  CCWarnNumberLabel.m
//  ccexcelView
//
//  Created by luo on 2018/3/29.
//  Copyright © 2018年 luo. All rights reserved.
//

#import "CCWarnNumberLabel.h"
#import "CCHelper.h"

@implementation CCWarnNumberLabel{
    UIColor *initialColor;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _warn = YES;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _warn = YES;
}

- (void)setWarn:(BOOL)warn {
    _warn = warn;
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    if (initialColor == nil) {
        initialColor = textColor;
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if (self.warn) {
        [self resetTextColor];
    }
}

- (void)resetTextColor {
    if ([self isNegativeDecimalDouble:self.text]) {
        self.textColor = self.warnColor ?: CC_ColorRed;
    } else if ([self.text containsString:@"\n"]) {
        // 换行后字体颜色处理（数量为负时使用富文本）
        NSArray <NSString *> *texts = [self.text componentsSeparatedByString:@"\n"];
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:self.text];
        
        NSInteger location = 0;
        for (NSString *text in texts) {
            if (text.length > 0 && [self isNegativeDecimalDouble:text]) {
                [att addAttribute:NSForegroundColorAttributeName value:self.warnColor ?: CC_ColorRed range:NSMakeRange(location, text.length)];
            }
            location += text.length + 1;
        }
        self.attributedText = att;
    } else {
        self.textColor = initialColor;
    }
}

- (BOOL)isNegativeDecimalDouble:(NSString*)string {
    if (self.text.length < 2) {
        return NO;
    }
    if (![string hasPrefix:@"-"]) {
        return NO;
    }
    NSString *scanString = [string stringByReplacingOccurrencesOfString:@"," withString:@""];
    scanString = [scanString stringByReplacingOccurrencesOfString:@"¥" withString:@""];
    scanString = [scanString stringByReplacingOccurrencesOfString:@"￥" withString:@""];
    NSScanner* scan = [NSScanner scannerWithString:scanString];
    double val;
    return [scan scanDouble:&val] && scan.isAtEnd;
}

@end
