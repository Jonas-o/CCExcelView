//
//  OrderExcelCell.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "OrderExcelCell.h"
#import "CCBorderMaker.h"
#import "CCUtil.h"

@implementation OrderExcelCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier style:(CCExcelCellStyle)style {
    if (self = [super initWithReuseIdentifier:reuseIdentifier style:style]) {
        self.backgroundColor = RGB(246, 246, 246);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.rightLine.hidden = YES;
    if (self.warn) {
        [CCBorderMaker borderView:self withCornerRadius:0 width:1 color:OrderExcelBorderWarnColor];
    } else {
        [CCBorderMaker borderView:self withCornerRadius:0 width:0.5 color:OrderExcelBorderColor];
    }
}

@end
