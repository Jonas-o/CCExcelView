//
//  CCExcelViewCell.m
//  CCExcelView
//
//  Created by luo on 2017/5/4.
//  Copyright © 2017年 CCExcelView. All rights reserved.
//

#import "CCExcelCell.h"
#import "CCHelper.h"
#import "CCWarnNumberLabel.h"

@implementation CCExcelCell
@synthesize label, reuseIdentifier, control, style, switchImageView, rightIcon, contentImageView, rightLineLayer,selectedBackgroundLayer;

- (instancetype)initWithReuseIdentifier:(NSString *)identifier style:(CCExcelCellStyle)cellStyle {
    if (self = [super initWithFrame:CGRectZero]) {
        reuseIdentifier = identifier;
        [self didInitialize];
        self.style = cellStyle;
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)identifier {
    return [self initWithReuseIdentifier:identifier style:CCExcelCellStyleDefault];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    selectedBackgroundLayer = [[CALayer alloc] init];
    selectedBackgroundLayer.backgroundColor = kExcelCellSelectedColor.CGColor;
    selectedBackgroundLayer.opacity = 0.0f;
    [self.layer addSublayer:selectedBackgroundLayer];

    label = [[CCWarnNumberLabel alloc] init];
    label.font = self.cellFont ?: CC_defaultFont;
    label.textColor = kExcelCellLabelColor;
    [self addSubview:label];

    control = [UIControl new];
    control.backgroundColor = CC_ColorClear;
    control.exclusiveTouch = YES;
    [self addSubview:control];

    rightLineLayer = [[CALayer alloc] init];
    rightLineLayer.backgroundColor = CC_RGB(184, 186, 186).CGColor;
    [self.layer addSublayer:rightLineLayer];

    switchImageView = [[UIImageView alloc] initWithImage:[CCHelper imageWithName:@"CC_switch_off"]];
    switchImageView.hidden = YES;
    [self addSubview:switchImageView];

    rightIcon = [[UIImageView alloc] init];
    [self addSubview:rightIcon];

    contentImageView = [[UIImageView alloc] init];
    [self addSubview:contentImageView];
}

- (void)prepareForReuse {
    // 子类继承使用
    [self setStyle:CCExcelCellStyleDefault];
}

- (void)setHeaderFont:(UIFont *)headerFont {
    _headerFont = headerFont;
    if (style & CCExcelCellStyleHeader) {
        label.font = self.headerFont ?: kExcelCellLabelHeaderFont;
    } else {
        label.font = self.cellFont ?: kExcelCellLabelFont;
    }
}

- (void)setCellFont:(UIFont *)cellFont {
    _cellFont = cellFont;
    if (style & CCExcelCellStyleHeader) {
        label.font = self.headerFont ?: kExcelCellLabelHeaderFont;
    } else {
        label.font = self.cellFont ?: kExcelCellLabelFont;
    }
}

- (void)setStyle:(CCExcelCellStyle)_style
{
    style = _style;
    [self handleStyle];
}

- (void)handleStyle
{
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
        rightLineLayer.hidden = NO;
        label.font = self.headerFont ?: kExcelCellLabelHeaderFont;
        label.textColor = kExcelCellLabelHeaderColor;
    } else {
        rightLineLayer.hidden = YES;
        label.font = self.cellFont ?: kExcelCellLabelFont;
        label.textColor = kExcelCellLabelColor;
    }
    if (style & CCExcelCellStyleWarn) {
        label.textColor = CC_ColorRed;
    } else {
        label.textColor = kExcelCellLabelColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    selectedBackgroundLayer.opacity = highlighted?1.0f:0.0f;
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
    switchImageView.image = switchOn ? [CCHelper imageWithName:@"CC_switch_on"] : [CCHelper imageWithName:@"CC_switch_off"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    control.frame = self.bounds;
    [self bringSubviewToFront:control];
    selectedBackgroundLayer.frame = self.bounds;
    rightLineLayer.frame = CC_rect(self.bounds.size.width - 1, 0, 1, self.bounds.size.height);
    if (style & CCExcelCellStyleSwitch) {
        label.frame = CC_rect(35, 0, self.bounds.size.width - 35, self.bounds.size.height);

        switchImageView.frame = CC_rect(MIN(12, (self.width-22)/2), (self.height - 22)/2,22,22);
    } else {
        label.frame = CC_rect(kExcelCellLabelMarginX, 0, self.bounds.size.width - kExcelCellLabelMarginX * 2, self.bounds.size.height);
    }
    if (rightIcon.image) {
        CGFloat width = rightIcon.image.size.width;
        CGFloat height = rightIcon.image.size.height;
        if (width > 20) {
            width = 20;
        }
        if (height > 20) {
            height = 20;
        }
        rightIcon.frame = CC_rect(self.bounds.size.width - 20 - kExcelCellLabelMarginX, (self.bounds.size.height - 20) / 2, width, height);
    }
    contentImageView.frame = CC_rect(self.bounds.size.width - self.bounds.size.height, 0, self.bounds.size.height, self.bounds.size.height);
}

+ (CGFloat)cellWidthWithTitle:(NSString *)title withFont:(UIFont *)font {
    CGSize maxSize = CC_size(MAXFLOAT, MAXFLOAT);
    CGFloat width = [CCHelper sizeWithString:title font:font maxSize:maxSize].width;
    width = ceil(width);
    return width + kExcelCellLabelMarginX*2;
}

@end
