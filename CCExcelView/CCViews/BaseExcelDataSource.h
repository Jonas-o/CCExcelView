//
//  BaseListView.h
//  CCExcelView
//
//  Created by luo on 2017/6/6.
//  Copyright © 2017年 CCExcelView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCExcelView.h"
#import "CCSortExcelcell.h"

typedef void(^ExcelSortAction)(NSNumber  *sortColumn , CCSortType type);
typedef void(^ExcelSortTitleAction)(NSString  *sortTitle , CCSortType type);

@protocol BaseExcelDelegate;

@interface BaseExcelDataSource : NSObject<CCExcelViewDelegate>

@property (nonatomic, weak)   id <BaseExcelDelegate> delegate;

/**
 *  顶部View
 */
@property (nonatomic, weak)   UIView *topView;

/**
 *  表头的高度
 */
@property (nonatomic, assign) CGFloat headerHeight;

/**
 *  左侧锁住的列数
 */
@property (nonatomic, assign) NSInteger lockNum;

/**
 *  右侧锁住的列数 （锁住的列会在表中居右）
 */
@property (nonatomic, assign) NSInteger lockRightNum;

/**
 *  最小列宽 （最小最大列宽会作用于整个列表，列表的宽度会根据内容自适应，代理中可以对指定的列设置最小最大列宽）
 */
@property (nonatomic, assign) NSInteger minExcelColumnWidth;

/**
 *  最大列宽 （最小最大列宽会作用于整个列表，列表的宽度会根据内容自适应，代理中可以对指定的列设置最小最大列宽）
 */
@property (nonatomic, assign) NSInteger maxExcelColumnWidth;

/**
 *  当前排序的列
 */
@property (nonatomic, strong) NSNumber *currentSortColumn;

/**
 *  当前排序的类型  升序、降序、没有排序
 */
@property (nonatomic, assign) CCSortType currentSortType;

/**
 *  点击排序的支持两种回调方式
 *  按列的序号的排序Action，sortColumn 列序号, type 升序还是降序
 */
@property (nonatomic, copy) ExcelSortAction sortAction;

/**
 *  点击排序的支持两种回调方式
 *  按列的标题的排序Action，sortTitle 列标题, type 升序还是降序
 */
@property (nonatomic, copy) ExcelSortTitleAction sortActionWithTitle;

/**
 *  reloadData
 */
- (void)reloadData;

/**
 *  reloadData 的同时重置所有scrollview的contentOffset
 */
- (void)reloadDataAndCells;

/**
 *  reloadData 的同时会根据新的表头数据是否变化来自动选择是否重置所有scrollview的contentOffset
 *  表头数据是否变化的判断标准是刷新后的列的数量是否小于刷新前
 */
- (void)reloadDataWithAutoReloadCells;

/**
 *  清除所有的排序，（只会操作表头，不会操作数据）
 */
- (void)resetSorts;

/**
 *  外部排序赋值
 */
- (void)resetTargetSort:(NSNumber *)sortColumn sortType:(CCSortType)sortType;

@end

@protocol BaseExcelDelegate <NSObject>

/**
 *  @synthesize excelView;
 */
@property (nonatomic, strong) CCExcelView *excelView;

- (NSString *)dataSource:(BaseExcelDataSource *)dataSource contentAtMatrix:(CCMatrix *)matrix;

- (void)dataSource:(BaseExcelDataSource *)dataSource handleCell:(CCExcelCell *)cell atMatrix:(CCMatrix *)matrix;

- (CCExcelCellStyle)dataSource:(BaseExcelDataSource *)dataSource styleAtMatrix:(CCMatrix *)matrix;

- (NSInteger)numberOfRowsInDataSource:(BaseExcelDataSource *)dataSource;

- (NSInteger)numberOfColumnsInDataSource:(BaseExcelDataSource *)dataSource;

- (NSTextAlignment)dataSource:(BaseExcelDataSource *)dataSource textAlignmentAtColumn:(NSInteger)column;

- (BOOL)shouldLoadMore:(BaseExcelDataSource *)dataSource;

- (void)loadNextPage:(BaseExcelDataSource *)dataSource;

- (void)dataSource:(BaseExcelDataSource *)dataSource selectAtMatrix:(CCMatrix *)matrix;

@optional

- (UIColor *)dataSource:(BaseExcelDataSource *)dataSource backgroundColorAtRow:(NSInteger)row;

/**
 *  优先级最高，当返回值有效时忽略所有自动宽度的设置
 */
- (CGFloat)dataSource:(BaseExcelDataSource *)dataSource widthAtColumn:(NSInteger)column;

- (CGFloat)dataSource:(BaseExcelDataSource *)dataSource minExcelColumnWidth:(NSInteger)column;

- (CGFloat)dataSource:(BaseExcelDataSource *)dataSource maxExcelColumnWidth:(NSInteger)column;

- (CCExcelCell *)dataSource:(BaseExcelDataSource *)dataSource cellAtMatrix:(CCMatrix *)matrix;

/**
 *  表底部的统计
 */
- (NSString *)dataSource:(BaseExcelDataSource *)dataSource sumContentAtColumn:(NSInteger)column;

/**
 *  当当前列支持排序后，列表头的对齐方式会自动设置为居左，忽略设置对齐方式的代理，且宽度在原有的基础上自动增加20，以容下排序的指示图标
 */
- (BOOL)shouldShowSortControl:(BaseExcelDataSource *)dataSource withMatrix:(CCMatrix *)matrix;

@end
