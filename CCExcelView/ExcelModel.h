//
//  ExcelModel.h
//  CCExcelView
//
//  Created by luo on 2017/10/19.
//  Copyright © 2017年 luo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseExcelDataSource.h"

#define Number @"序号"
#define Image @"图片"
#define Code @"款号"
#define Name @"名称"
#define Quantity @"库存"
#define Amount @"库存价值"
#define Purchase @"累计进"
#define Sales @"累计销"
#define Supplier @"供货商"
#define Date @"上架日期"
#define Color @"颜色"
#define Size @"尺码"

@interface ExcelModel : NSObject

@property (nonatomic, strong) UIImage  *image;
@property (nonatomic, copy) NSString  *code;
@property (nonatomic, copy) NSString  *name;
@property (nonatomic, copy) NSString  *pinyin;//排序用
@property (nonatomic, copy) NSString  *quantity;
@property (nonatomic, copy) NSString  *amount;
@property (nonatomic, copy) NSString  *purchase;
@property (nonatomic, copy) NSString  *sales;
@property (nonatomic, copy) NSString  *supplier;
@property (nonatomic, copy) NSString  *supplierPinyin; //排序用
@property (nonatomic, copy) NSString  *date;
@property (nonatomic, copy) NSString  *color;
@property (nonatomic, copy) NSString  *colorPinyin; //排序用
@property (nonatomic, copy) NSString  *size;

+ (NSMutableArray <ExcelModel *> *)initData;

+ (void)sortWithSourceArray:(NSMutableArray <ExcelModel *> *)array columnTitle:(NSString *)title type:(CCSortType)type;

@end
