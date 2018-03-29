//
//  CCExcelView.h
//  CCExcelView
//
//  Created by luo on 2017/5/4.
//  Copyright © 2017年 CCExcelView. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCExcelCell.h"
#import "CCExcelRowCell.h"

@class CCMatrix;
@protocol CCExcelViewDelegate;

@interface CCExcelView : UIView

@property (nonatomic, weak) id<CCExcelViewDelegate> delegate;

@property (nonatomic, strong, readonly) UITableView *table;

@property (nonatomic, strong, readonly) CCExcelRowCell *headerCell;;

@property (nonatomic, assign) BOOL autoShowTopView;

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, assign) CCExcelViewCellSelectionStyle selectionStyle;

@property (nonatomic, assign, readonly) BOOL showFooter;

- (instancetype)initWithFrame:(CGRect)frame rowHeight:(CGFloat)rowHeight;

- (instancetype)initWithFrame:(CGRect)frame rowHeight:(CGFloat)rowHeight showFooter:(BOOL)showFooter;

- (void)reloadData;

- (void)reloadDataAndRowCell; // 同时重置每个cell的contentScrollView.contentOffset

/// 重新计算所有列的宽度，并重新定位frame。不涉及内容重载。
- (void)resetAllColumnsWidth;

/// 从reloadColumnIndex起，按照reloadColumnIndex及其之后所有列的新的width值,重新计算所有在reloadColumnIndex(包含)之后所有列的frame。不涉及内容重载。
- (void)resetAllColumnsWidthFromIndex:(NSInteger)reloadColumnIndex;

/// 从reloadColumnIndex起，按照reloadColumnIndex所在列宽度差，重新定位之后所有列的坐标。不涉及内容重载。
- (void)resetColumnsWidthFromIndex:(NSInteger)reloadColumnIndex;

- (NSArray *)visiableRows;

- (CCExcelCell *)dequeueReusableCellWithIdentifier:(NSString *)cellIdentifier;

- (void)setHighlight:(BOOL)highlight atRow:(NSInteger)row;

- (CCExcelCell *)cellAtMatrix:(CCMatrix *)matrix;

- (CCMatrix *)matrixOfCell:(CCExcelCell *)cell;

- (CCExcelRowCell *)contenViewAtRow:(NSInteger)row;

- (void)deleteRow:(NSInteger)row;

- (void)showTopView;

- (void)hideTopView;

@end

@interface CCMatrix : NSObject

@property (nonatomic, assign) NSInteger column;

@property (nonatomic, assign) NSInteger row;

- (NSString *)genIndexString;

+ (CCMatrix *)matrixWithColumn:(NSInteger)column row:(NSInteger)row;

- (BOOL)isHeader;

- (BOOL)isLeader;

- (BOOL)isHeaderAndLeader;

- (BOOL)notHeaderLeader;

@end

@protocol CCExcelViewDelegate <NSObject>

- (CGFloat)excelView:(CCExcelView *)excelView widthAtColumn:(NSInteger)column;

- (CCExcelCell *)excelView:(CCExcelView *)excelView cellAtMatrix:(CCMatrix *)matrix;

- (NSInteger)numberOfColumnsInExcelView:(CCExcelView *)excelView;

- (NSInteger)numberOfRowsInExcelView:(CCExcelView *)excelView;

@optional

- (CGFloat)topRowHeightInExcelView:(CCExcelView *)excelView;

- (CGFloat)bottomRowHeightInExcelView:(CCExcelView *)excelView;

- (CGFloat)topViewHeightInExcelView:(CCExcelView *)excelView;

- (UIView *)topViewInExcelView:(CCExcelView *)excelView;

- (void)excelViewDidShowTopView:(CCExcelView *)excelView;

- (void)excelViewDidHideTopView:(CCExcelView *)excelView;

- (void)excelView:(CCExcelView *)excelView didSelectAt:(CCMatrix *)matrix;

- (NSInteger)numberOfColumnsLockInExcelView:(CCExcelView *)excelView; /// 锁定的头N列, 默认1

- (NSInteger)numberOfFarrightColumnsLockInExcelView:(CCExcelView *)excelView; /// 锁定的最右侧N列, 默认0

- (BOOL)excelView:(CCExcelView *)excelView shouldHighlightAtRow:(NSInteger)row;

- (BOOL)excelViewShouldResponseFooterCell:(CCExcelView *)excelView; /// footerView事件是否要响应,默认NO

- (UIColor *)excelView:(CCExcelView *)excelView backgroundColorAtRow:(NSInteger)row;

- (UIColor *)excelView:(CCExcelView *)excelView bottomLineColorAtRow:(NSInteger)row;

- (BOOL)shouldLoadMore:(CCExcelView *)excelView;

- (void)loadNextPage:(CCExcelView *)excelView;

- (void)refresh;

- (void)excelViewDidEndScroll:(CCExcelView *)excelView;

- (void)excelViewDidScroll:(CCExcelView *)excelView;

@end

