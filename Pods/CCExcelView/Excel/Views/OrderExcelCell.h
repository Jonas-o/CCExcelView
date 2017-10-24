//
//  OrderExcelCell.h
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "CCExcelCell.h"

#define OrderExcelBorderColor RGB(184,186,186)
#define OrderExcelBorderWarnColor ColorRed

@interface OrderExcelCell : CCExcelCell

@property (nonatomic, assign) BOOL warn;

@end
