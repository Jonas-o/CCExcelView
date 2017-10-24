//
//  CCExcelViewCell.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "CCExcelCell.h"
#import "CCBorderMaker.h"
#import "CCWarnLabel.h"
#import "CCUtil.h"

@implementation CCExcelCell
@synthesize label, reuseIdentifier, control, style, switchImageView, rightIcon, contentImageView, rightLine,selectedBackgroundView;

- (instancetype)initWithReuseIdentifier:(NSString *)identifier style:(CCExcelCellStyle)cellStyle {
    if (self = [super init]) {
        reuseIdentifier = identifier;
        
        selectedBackgroundView = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = kExcelCellSelectedColor;
        selectedBackgroundView.layer.opacity = 0.0f;
        [self addSubview:selectedBackgroundView];
        
        label = [[CCWarnLabel alloc] init];
        label.font = defaultFont;
        label.textColor = kExcelCellLabelColor;
        [self addSubview:label];
        
        control = [UIControl new];
        control.backgroundColor = ColorClear;
        control.exclusiveTouch = YES;
        [self addSubview:control];
        
        rightLine = [[UIView alloc] init];
        rightLine.backgroundColor = RGB(184, 186, 186);
        rightLine.userInteractionEnabled = NO;
        [self addSubview:rightLine];
        
        switchImageView = [[UIImageView alloc] initWithImage:CCImage(@"switch_off")];
        switchImageView.hidden = YES;
        [self addSubview:switchImageView];
        
        rightIcon = [[UIImageView alloc] init];
        [self addSubview:rightIcon];
        
        contentImageView = [[UIImageView alloc] init];
        [self addSubview:contentImageView];
        
        self.style = cellStyle;
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)identifier {
    return [self initWithReuseIdentifier:identifier style:CCExcelCellStyleDefault];
}

- (void)setStyle:(CCExcelCellStyle)_style {
    style = _style;
    [self handleStyle];
}

- (void)handleStyle {
    if (style & CCExcelCellStyleLeader) {
        label.textAlignment = NSTextAlignmentCenter;
    } else {
        label.textAlignment = NSTextAlignmentLeft;
    }
    if (style & CCExcelCellStyleSwitch) {
        switchImageView.hidden = NO;
    } else {
        switchImageView.hidden = YES;
    }
    if (style & CCExcelCellStyleHeader) {
        rightLine.hidden = NO;
        label.font = kExcelCellLabelHeaderFont;
        label.textColor = kExcelCellLabelHeaderColor;
    } else {
        rightLine.hidden = YES;
        label.font = kExcelCellLabelFont;
        label.textColor = kExcelCellLabelColor;
    }
    if (style & CCExcelCellStyleWarn) {
        label.textColor = ColorRed;
    } else {
        label.textColor = kExcelCellLabelColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    selectedBackgroundView.layer.opacity = highlighted?1.0f:0.0f;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    if (animated) {
        [UIView animateWithDuration:.2 animations:^{
            self.highlighted = highlighted;
        }];
    }else{
        self.highlighted = highlighted;
    }
}

- (void)setSwitchOn:(BOOL)switchOn {
    _switchOn = switchOn;
    switchImageView.image = switchOn ? CCImage(@"switch_on") : CCImage(@"switch_off");
}

- (void)layoutSubviews {
    [super layoutSubviews];
    control.frame = self.bounds;
    [self bringSubviewToFront:control];
    selectedBackgroundView.frame = self.bounds;
    rightLine.frame = rect(self.bounds.size.width - 1, 0, 1, self.bounds.size.height);
    if (style & CCExcelCellStyleSwitch) {
        label.frame = rect(35, 0, self.bounds.size.width - 35, self.bounds.size.height);
        
        switchImageView.frame = rect(MIN(15, (self.bounds.size.width-20)/2), self.bounds.size.height/2-10,20,20);
    } else {
        label.frame = rect(kExcelCellLabelMarginX, 0, self.bounds.size.width - kExcelCellLabelMarginX * 2, self.bounds.size.height);
    }
    rightIcon.frame = rect(self.bounds.size.width - 20 - kExcelCellLabelMarginX, (self.bounds.size.height - 20) / 2, 20, 20);
    contentImageView.frame = rect(self.bounds.size.width - self.bounds.size.height, 0, self.bounds.size.height, self.bounds.size.height);
}

+ (CGFloat)cellWidthWithTitle:(NSString *)title {
    CGFloat width = ceil([title widthWithFont:kExcelCellLabelFont height:MAXFLOAT]);
    return width + kExcelCellLabelMarginX*2;
}

@end
