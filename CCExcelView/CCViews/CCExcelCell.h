//
//  CCExcelViewCell.h
//  CCExcelView
//
//  Created by luo on 2017/5/4.
//  Copyright © 2017年 CCExcelView. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, CCExcelCellStyle) {
    CCExcelCellStyleDefault = 0,
    CCExcelCellStyleHeader = 1 << 0,  // 第一行
    CCExcelCellStyleLeader = 1 << 1,  // 第一列
    CCExcelCellStyleSwitch = 1 << 2,  // 选择按钮
    CCExcelCellStyleWarn = 1 << 3     // 警告文本
};

#define kExcelCellLabelMarginX 8
#define kExcelCellLabelFont CC_defaultFont
#define kExcelCellLabelHeaderFont CC_defaultBoldFont
#define kExcelCellLabelHeaderColor CC_RGB(102,102,102)
#define kExcelCellLabelColor CC_RGB(51,51,51)
#define kExcelCellSelectedColor CC_RGB(222, 222, 222)

@interface CCExcelCell : UIView

@property (nonatomic, strong, readonly) NSString *reuseIdentifier;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier style:(CCExcelCellStyle)style;

@property (nonatomic, assign) CCExcelCellStyle style;

@property (nonatomic, strong, readonly) UILabel *label;

@property (nonatomic, strong, readonly) UIControl *control;

@property (nonatomic, strong) UIImageView *switchImageView;

@property (nonatomic, strong) UIImageView *rightIcon;

@property (nonatomic, strong) UIImageView *contentImageView;

@property (nonatomic, strong) CALayer *selectedBackgroundLayer;

@property (nonatomic, strong) CALayer *rightLineLayer;

@property (nonatomic, assign) BOOL      highlighted;

@property (nonatomic, assign) BOOL      switchOn;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

+ (CGFloat)cellWidthWithTitle:(NSString *)title;

@end
