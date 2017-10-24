//
//  CCExcelDiscountCell.h
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "OrderExcelCell.h"
#import "CCUtil.h"

typedef void(^CCExcelDiscountCellAction)(NSDecimalNumber *number);
typedef void(^CCExcelDiscountCellEditAction)(CCExcelCell *cell);

@interface CCExcelDiscountCell : OrderExcelCell

@property (nonatomic, copy) CCExcelDiscountCellAction inputAction;

@property (nonatomic, copy) CCExcelDiscountCellEditAction editAction;

@property (nonatomic, strong, readonly) CCTextField *discountField;

@property (nonatomic, strong, readonly) UIButton *button;

@end
