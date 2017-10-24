//
//  CCWarnLabel.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "CCWarnLabel.h"
#import "CCUtil.h"

@implementation CCWarnLabel {
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
    if (self.text.length > 0 && [self isPureDouble:self.text]) {
        if ([decimalWithString(self.text) compare:decimalZero] == NSOrderedAscending) {
            if (self.warnColor != nil) {
                self.textColor = self.warnColor;
            } else {
                self.textColor = ColorRed;
            }
        } else {
            self.textColor = initialColor;
        }
    }
}

- (BOOL)isPureDouble:(NSString*)string {
    NSScanner* scan = [NSScanner scannerWithString:string];
    double val;
    return[scan scanDouble:&val] && [scan isAtEnd];
}

@end
