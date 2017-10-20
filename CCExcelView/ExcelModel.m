//
//  ExcelModel.m
//  CCExcelView
//
//  Created by luo on 2017/10/19.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "ExcelModel.h"

@implementation ExcelModel

- (NSString *)description {
    return [NSString stringWithFormat:@"code:%@,name:%@,quantity:%@,amount:%@,purchase:%@,date:%@,color:%@,size:%@",self.code,self.name,self.quantity,self.amount,self.purchase,self.date,self.color,self.size];
}

+ (NSMutableArray <ExcelModel *> *)initData {
    NSInteger total = arc4random_uniform(5) + 5;
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < total; i ++) {
        ExcelModel *model = [ExcelModel new];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d",arc4random_uniform(4) + 1] ofType :@"png"];
        model.image = [UIImage imageWithContentsOfFile:filePath];
        model.code = [self arc4random:5];
        model.name = [self arc4randomName];
        NSMutableString *mutableString = [NSMutableString stringWithString:model.name];
        CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
        CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformStripDiacritics, false);
        model.pinyin = mutableString;
        model.amount = [self arc4randomInteger:4];
        model.purchase = [self arc4randomInteger:3];
        do {
            model.sales = [self arc4randomInteger:3];
        } while (model.sales.integerValue > model.purchase.integerValue);
        
        model.quantity = [NSString stringWithFormat:@"%ld",model.purchase.integerValue - model.sales.integerValue];
        model.supplier = [self arc4randomSupplier];
        mutableString = [NSMutableString stringWithString:model.supplier];
        CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
        CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformStripDiacritics, false);
        model.supplierPinyin = mutableString;
        model.date = [self arc4randomDate];
        model.color = [self arc4randomColor];
        mutableString = [NSMutableString stringWithString:model.color];
        CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
        CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformStripDiacritics, false);
        model.colorPinyin = mutableString;
        model.size = [self arc4randomSize];
        [dataSource addObject:model];
    }
    
    return dataSource;
}

+ (NSString *)arc4random:(NSInteger)place {
    NSString *str = @"";
    for (int i = 0; i < place; i ++) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%d",arc4random_uniform(10)]];
    }
    return str;
}

+ (NSString *)arc4randomName {
    NSArray *nameArray = @[@"棉麻清新",@"麻裤",@"忽略图片",@"韩版文艺男款",@"韩版文艺女款",@"程序猿专用格子衬衣"];
    return nameArray[arc4random_uniform((unsigned int)nameArray.count)];
}

+ (NSString *)arc4randomInteger:(NSInteger)place {
    NSString *str = nil;
    for (int i = 0; i < place; i ++) {
        do {
            if (i == 0) {
                str = @"";
            }
            str = [str stringByAppendingString:[NSString stringWithFormat:@"%d",arc4random_uniform(10)]];
        } while (i == 0 && [str isEqualToString:@"0"]);
    }
    return str;
}

+ (NSString *)arc4randomSupplier {
    NSArray *nameArray = @[@"供货商1",@"供货商2",@"供货商3",@"供货商007",@"供货商5",@"程序猿专供"];
    return nameArray[arc4random_uniform((unsigned int)nameArray.count)];
}

+ (NSString *)arc4randomDate {
    NSArray *nameArray = @[@"2017-05-06",@"2017-03-30",@"2017-03-18",@"2017-04-09",@"2017-11-11",@"2012-12-12"];
    return nameArray[arc4random_uniform((unsigned int)nameArray.count)];
}

+ (NSString *)arc4randomColor {
    NSArray *nameArray = @[@"红色",@"大红",@"玫红",@"粉红",@"柠檬黄",@"宝蓝",@"淡蓝",@"墨绿",@"军绿",@"卡其色",@"杏色",@"藕紫",@"牛仔蓝"];
    return nameArray[arc4random_uniform((unsigned int)nameArray.count)];
}

+ (NSString *)arc4randomSize {
    NSArray *nameArray = @[@"XS",@"S",@"M",@"L",@"XL",@"2XL",@"3XL",@"4XL"];
    return nameArray[arc4random_uniform((unsigned int)nameArray.count)];
}

+ (void)sortWithSourceArray:(NSMutableArray<ExcelModel *> *)array columnTitle:(NSString *)title type:(CCSortType)type {
    if (!array.count) {
        return;
    }
    if ([title isEqualToString:Code]) {
        [self sortByKeyValueWithSourceArray:array type:type key:@"code"];
    } else if ([title isEqualToString:Name]) {
        [self sortByNameWithSourceArray:array type:type key:@"pinyin"];
    } else if ([title isEqualToString:Quantity]) {
        [self sortByKeyValueWithSourceArray:array type:type key:@"quantity"];
    } else if ([title isEqualToString:Amount]) {
        [self sortByKeyValueWithSourceArray:array type:type key:@"amount"];
    } else if ([title isEqualToString:Purchase]) {
        [self sortByKeyValueWithSourceArray:array type:type key:@"purchase"];
    } else if ([title isEqualToString:Sales]) {
        [self sortByKeyValueWithSourceArray:array type:type key:@"sales"];
    } else if ([title isEqualToString:Supplier]) {
        [self sortByNameWithSourceArray:array type:type key:@"supplierPinyin"];
    } else if ([title isEqualToString:Date]) {
        [self sortByDateWithSourceArray:array type:type];
    } else if ([title isEqualToString:Color]) {
        [self sortByNameWithSourceArray:array type:type key:@"colorPinyin"];
    } else if ([title isEqualToString:Size]) {
        [self sortBySizeWithSourceArray:array type:type];
    }
}

+ (void)sortByKeyValueWithSourceArray:(NSMutableArray<ExcelModel *> *)array type:(CCSortType)type key:(NSString *)key {
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        ExcelModel *model1 = (ExcelModel *)obj1;
        ExcelModel *model2 = (ExcelModel *)obj2;
        
        NSInteger model1Value = [[model1 valueForKey:key] integerValue];
        NSInteger model2Value = [[model2 valueForKey:key] integerValue];
        if (type == CCSortTypeDescending) {
            //降序
            if (model1Value < model2Value) {
                return NSOrderedDescending;
            }else if(model1Value > model2Value){
                return NSOrderedAscending;
            }
        } else if (type == CCSortTypeAscending) {
            //升序
            if (model1Value < model2Value) {
                return NSOrderedAscending;
            }else if(model1Value > model2Value){
                return NSOrderedDescending;
            }
        }
        return NSOrderedSame;
    }];
}

+ (void)sortByNameWithSourceArray:(NSMutableArray<ExcelModel *> *)array type:(CCSortType)type key:(NSString *)key {
    BOOL ascending;
    if (type == CCSortTypeDescending) {
        ascending = NO;
    } else if (type == CCSortTypeAscending) {
        ascending = YES;
    } else {
        return;
    }
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:ascending]];
    [array sortUsingDescriptors:sortDescriptors];
}

+ (void)sortByDateWithSourceArray:(NSMutableArray<ExcelModel *> *)array type:(CCSortType)type {
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        ExcelModel *model1 = (ExcelModel *)obj1;
        ExcelModel *model2 = (ExcelModel *)obj2;
        
        NSArray *model1Values = [model1.date componentsSeparatedByString:@"-"];
        NSArray *model2Values = [model2.date componentsSeparatedByString:@"-"];
        if (type == CCSortTypeDescending) {
            //降序
            if ([model1Values.firstObject integerValue] < [model2Values.firstObject integerValue]) {
                return NSOrderedDescending;
            } else if ([model1Values.firstObject integerValue] > [model2Values.firstObject integerValue]) {
                return NSOrderedAscending;
            } else if ([model1Values[1] integerValue] < [model2Values[1] integerValue]) {
                return NSOrderedDescending;
            } else if ([model1Values[1] integerValue] > [model2Values[1] integerValue]) {
                return NSOrderedAscending;
            }else if ([model1Values.lastObject integerValue] < [model2Values.lastObject integerValue]) {
                return NSOrderedDescending;
            } else if ([model1Values.lastObject integerValue] > [model2Values.lastObject integerValue]) {
                return NSOrderedAscending;
            }
        } else if (type == CCSortTypeAscending) {
            //升序
            if ([model1Values.firstObject integerValue] < [model2Values.firstObject integerValue]) {
                return NSOrderedAscending;
            } else if ([model1Values.firstObject integerValue] > [model2Values.firstObject integerValue]) {
                return NSOrderedDescending;
            } else if ([model1Values[1] integerValue] < [model2Values[1] integerValue]) {
                return NSOrderedAscending;
            } else if ([model1Values[1] integerValue] > [model2Values[1] integerValue]) {
                return NSOrderedDescending;
            }else if ([model1Values.lastObject integerValue] < [model2Values.lastObject integerValue]) {
                return NSOrderedAscending;
            } else if ([model1Values.lastObject integerValue] > [model2Values.lastObject integerValue]) {
                return NSOrderedDescending;
            }
        }
        return NSOrderedSame;
    }];
}

+ (void)sortBySizeWithSourceArray:(NSMutableArray<ExcelModel *> *)array type:(CCSortType)type {
    NSArray *sizeArray = @[@"XS",@"S",@"M",@"L",@"XL",@"2XL",@"3XL",@"4XL"];
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        ExcelModel *model1 = (ExcelModel *)obj1;
        ExcelModel *model2 = (ExcelModel *)obj2;
        
        NSInteger model1Value = [sizeArray indexOfObject:model1.size];
        NSInteger model2Value = [sizeArray indexOfObject:model2.size];
        if (type == CCSortTypeDescending) {
            //降序
            if (model1Value < model2Value) {
                return NSOrderedDescending;
            }else if(model1Value > model2Value){
                return NSOrderedAscending;
            }
        } else if (type == CCSortTypeAscending) {
            //升序
            if (model1Value < model2Value) {
                return NSOrderedAscending;
            }else if(model1Value > model2Value){
                return NSOrderedDescending;
            }
        }
        return NSOrderedSame;
    }];
}

@end
