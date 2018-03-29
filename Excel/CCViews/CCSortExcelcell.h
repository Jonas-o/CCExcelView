//
//  CCSortExcelcell.h
//  CCExcelView
//
//  Created by luo on 2017/9/19.
//  Copyright © 2017年 CCExcelView. All rights reserved.
//

#import "CCExcelCell.h"

typedef enum : NSUInteger {
    CCSortTypeDefault,      //默认排序
    CCSortTypeAscending,    //升序
    CCSortTypeDescending,   //降序
} CCSortType;

@interface CCSortExcelcell : CCExcelCell

@property (nonatomic, strong) UIImageView *sortImageView;

@property (nonatomic, assign) CCSortType  sortType;

@end
