//
//  CCNumberInputCell.h
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "OrderExcelCell.h"
#import "CCUtil.h"


@interface CCExcelNumberInputCell : OrderExcelCell

typedef void(^CCExcelNumberInputAction)(CCExcelNumberInputCell *cell, NSDecimalNumber *number);
typedef void(^CCExcelNumberInputBeginEditAction)(CCExcelCell *cell);

@property (nonatomic, assign) BOOL useDefaultKeyboard;

@property (nonatomic, copy) CCExcelNumberInputAction inputAction;

@property (nonatomic, copy) CCExcelNumberInputBeginEditAction editAction;

@property (nonatomic, copy) CCExcelNumberInputBeginEditAction returnAction;

@property (nonatomic, strong) CCTextField *contentField;

@property (nonatomic, strong) UILabel *detailLabel;

- (void)setDetailLabelText:(NSString *)str;

+ (CGFloat)cellWidthWithTitle:(NSString *)title;

@end
