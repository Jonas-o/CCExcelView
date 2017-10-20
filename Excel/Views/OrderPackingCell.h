//
//  OrderPackingCell.h
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "OrderExcelCell.h"

@interface OrderPackingCell : OrderExcelCell

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UIImageView *imageView;

- (void)updateDetail:(NSString *)detail;

@end
