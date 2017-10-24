//
//  CCExcelMutilineCell.h
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "OrderExcelCell.h"

@interface CCExcelMutilineCell : OrderExcelCell

@property (nonatomic, strong) UILabel *mutilineLabel;

+ (CGFloat)cellHeightWithTitle:(NSString *)title;

@end
