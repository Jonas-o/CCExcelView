//
//  CCExcelAcccssoryCell.h
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "OrderExcelCell.h"

@interface CCExcelAcccssoryCell : OrderExcelCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier rightText:(NSString *)rightText;

@property (nonatomic, strong) UIButton *rightButton;

@end
