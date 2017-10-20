//
//  ViewController.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "ViewController.h"
#import "BaseExcelDataSource.h"
#import "ExcelModel.h"
#import "CCUtil.h"

@interface ViewController () <BaseExcelDelegate>

@property (nonatomic, strong) BaseExcelDataSource *dataSource;

@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@end

@implementation ViewController

@synthesize excelView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.titleArray = @[Number,Image,Code,Name,Quantity,Amount,Purchase,Sales,Supplier,Date,Color,Size];
    self.dataSourceArray = [ExcelModel initData];
    excelView = [[CCExcelView alloc] initWithFrame:self.safeAreaView.bounds rowHeight:40 showFooter:NO];
    excelView.selectionStyle = CCExcelViewCellSelectionStyleCell;
    [self.safeAreaView addSubview:excelView];
    
    self.dataSource = [BaseExcelDataSource new];
    self.dataSource.headerHeight = 40;
    self.dataSource.delegate = self;
    self.dataSource.minExcelColumnWidth = 150;
    self.dataSource.maxExcelColumnWidth = 200;
    self.dataSource.lockNum = 1;
    self.dataSource.lockRightNum = 1;
    excelView.delegate = self.dataSource;
    
    [self.dataSource reloadData];
    
    __weak typeof(self) weak_self = self;
    self.dataSource.sortActionWithTitle = ^(NSString *sortTitle, CCSortType type) {
        [ExcelModel sortWithSourceArray:weak_self.dataSourceArray columnTitle:sortTitle type:type];
        [weak_self.dataSource reloadData];
    };
}

- (NSString *)getContentWithColumnTitle:(NSString *)title fromSource:(ExcelModel *)source {
    if ([title isEqualToString:Code]) {
        return source.code;
    } else if ([title isEqualToString:Name]) {
        return source.name;
    } else if ([title isEqualToString:Quantity]) {
        return source.quantity;
    } else if ([title isEqualToString:Amount]) {
        return source.amount;
    } else if ([title isEqualToString:Purchase]) {
        return source.purchase;
    } else if ([title isEqualToString:Sales]) {
        return source.sales;
    } else if ([title isEqualToString:Supplier]) {
        return source.supplier;
    } else if ([title isEqualToString:Date]) {
        return source.date;
    } else if ([title isEqualToString:Color]) {
        return source.color;
    } else if ([title isEqualToString:Size]) {
        return source.size;
    }
    return nil;
}

#pragma mark- BaseExcelDataSource
- (NSString *)dataSource:(BaseExcelDataSource *)dataSource contentAtMatrix:(CCMatrix *)matrix{
    
    NSString *columnTitle = self.titleArray[matrix.column];
    NSInteger column = matrix.column;
    if ([matrix isHeader]) {
        return columnTitle;
    }
    NSInteger index  = matrix.row - 1;
    if (column == 0) {
        return [NSString stringWithFormat:@"%02ld",(long)matrix.row];
    }
    ExcelModel *model = self.dataSourceArray[index];
    return [self getContentWithColumnTitle:columnTitle fromSource:model];
}

- (void)dataSource:(BaseExcelDataSource *)dataSource handleCell:(CCExcelCell *)cell atMatrix:(CCMatrix *)matrix
{
    if (matrix.row > 0 && matrix.column == 1) {
        CCExcelImageCell *imageCell = (CCExcelImageCell *) cell;
        NSInteger index  = matrix.row - 1;
        ExcelModel *model = self.dataSourceArray[index];
        imageCell.imageView.image = model.image;
        imageCell.clipsToBounds = YES;
    }
}

- (CCExcelCell *)dataSource:(BaseExcelDataSource *)dataSource cellAtMatrix:(CCMatrix *)matrix
{
    if (matrix.row > 0 && matrix.column == 1) {
        CCExcelImageCell *cell = (CCExcelImageCell *) [excelView dequeueReusableCellWithIdentifier:@"image"];
        if (cell == nil) {
            cell = [[CCExcelImageCell alloc] initWithReuseIdentifier:@"image"];
        }
        return cell;
    }
    return nil;
}

- (CGFloat)dataSource:(BaseExcelDataSource *)dataSource widthAtColumn:(NSInteger)column
{
    if (column == 1) {
        return 60;
    }
    return -1;
}

- (CGFloat)dataSource:(BaseExcelDataSource *)dataSource minExcelColumnWidth:(NSInteger)column {
    if (column == 0) {
        return 50;
    }
    return -1;
}

- (BOOL)shouldShowSortControl:(BaseExcelDataSource *)dataSource withMatrix:(CCMatrix *)matrix {
    if (matrix.column == 0 || matrix.column == 1) {
        return NO;
    }
    return YES;
}

- (CCExcelCellStyle)dataSource:(BaseExcelDataSource *)dataSource styleAtMatrix:(CCMatrix *)matrix{
    CCExcelCellStyle style = CCExcelCellStyleDefault;
    if ([matrix isHeader]) {
        style = style | CCExcelCellStyleHeader;
    }
    if ([matrix isLeader]) {
        style = style | CCExcelCellStyleLeader;
    }
    return style;
}

- (NSInteger)numberOfRowsInDataSource:(BaseExcelDataSource *)dataSource{
    return self.dataSourceArray.count;
}

- (NSInteger)numberOfColumnsInDataSource:(BaseExcelDataSource *)dataSource{
    return self.titleArray.count;
}

- (NSTextAlignment)dataSource:(BaseExcelDataSource *)dataSource textAlignmentAtColumn:(NSInteger)column{
    if (column == 0 || column == 1) {
        return NSTextAlignmentCenter;
    }
    return  NSTextAlignmentLeft;
}

- (UIColor *)dataSource:(BaseExcelDataSource *)dataSource backgroundColorAtRow:(NSInteger)row
{
    if (row % 6 == 0) {
        return ColorLightGreen;
    }
    return ColorClear;
}

- (BOOL)shouldLoadMore:(BaseExcelDataSource *)dataSource {
    return NO;
}

- (void)loadNextPage:(BaseExcelDataSource *)dataSource {
    
}

- (void)dataSource:(BaseExcelDataSource *)dataSource selectAtMatrix:(CCMatrix *)matrix {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    excelView.frame = self.safeAreaView.bounds;
    [self.dataSource reloadData];
}


@end
