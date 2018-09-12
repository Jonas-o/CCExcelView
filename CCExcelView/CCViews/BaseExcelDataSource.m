//
//  BaseListView.m
//  CCExcelView
//
//  Created by luo on 2017/6/6.
//  Copyright © 2017年 CCExcelView. All rights reserved.
//

#import "BaseExcelDataSource.h"
#import "CCHelper.h"

@implementation BaseExcelDataSource
{
    NSMutableArray *columnWidthArray;
    NSInteger currentPage;
}
@synthesize delegate;

- (instancetype)init
{
    if (self = [super init]) {
        self.minExcelColumnWidth = 80;
        self.maxExcelColumnWidth = 160;
        self.lockNum = 1;
        self.lockRightNum = 0;
        columnWidthArray = [NSMutableArray array];
    }
    return self;
}

- (void)reloadData
{
    [self calculateColumnWidths];
    [delegate.excelView reloadData];
}

- (void)reloadDataAndCells
{
    [self calculateColumnWidths];
    [delegate.excelView reloadDataAndRowCell];
}

- (void)reloadDataWithAutoReloadCells {
    CCExcelRowCell *cell = delegate.excelView.headerCell;
    if (!cell) {
        [self reloadData];
        return;
    }
    NSInteger currentColumnCount = cell.lockCells.count + cell.scrollCells.count + cell.farrightLockCells.count;
    NSInteger targetColumnCount = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfColumnsInDataSource:)]) {
        targetColumnCount = [delegate numberOfColumnsInDataSource:self];
    }
    if (currentColumnCount > targetColumnCount) {
        [self reloadDataAndCells];
    } else {
        [self reloadData];
    }
}

- (void)updateCurrentPage:(NSInteger)page {
    currentPage = page;
}

- (void)reloadDataWithAutoInsertCells:(NSInteger)pageSize currentPage:(NSInteger)page completion:(void (^)(void))completion {
    if (page == 0) {
        if (self.currentSortColumn) {
            //排序请求第一页时只需要刷新数据不需要刷新表
            [self reloadData];
        } else {
            //非排序请求第一页需要刷新整个表
            [self reloadDataAndCells];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion();
        });
    } else if (page > 0 && pageSize > 0 && page > currentPage) {
        [self insertDataFromRow:page * pageSize completion:completion];
    } else {
        [self reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion();
        });
    }
    currentPage = page;
}

- (void)insertDataFromRow:(NSInteger)from completion:(void(^)(void))completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *indexs = [NSMutableArray array];
        NSInteger totalRows = [self.delegate numberOfRowsInDataSource:self];
        NSInteger begin = from;
        if (begin < totalRows) {
            for (NSInteger i = begin; i < totalRows; i ++) {
                [indexs addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            NSInteger index = [self calculateColumnWidthsFromRow:begin + 1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.1f animations:^{
                    [self.delegate.excelView resetAllColumnsWidthFromIndex:index];
                } completion:^(BOOL finished) {
                    BOOL canInsert = YES;
                    NSArray *visibleIndexs = [self.delegate.excelView.table indexPathsForVisibleRows];
                    for (NSIndexPath *index in indexs) {
                        if ([visibleIndexs containsObject:index]) {
                            canInsert = NO;
                            break;
                        }
                    }
                    if (canInsert) {
                        [UIView setAnimationsEnabled:NO];// 或者[CATransaction setDisableActions:YES];
                        @try {
                            [self.delegate.excelView.table insertRowsAtIndexPaths:indexs withRowAnimation:UITableViewRowAnimationNone];
                        } @catch (NSException *exception) {
                            [self reloadData];
                        }
                        [UIView setAnimationsEnabled:YES];// 或者[CATransaction setDisableActions:NO];
                    } else {
                        [self reloadData];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) completion();
                    });
                }];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion();
                });
            });
        }
    });
}

- (void)resetSorts {
    self.currentSortType = CCSortTypeDefault;
    self.currentSortColumn = nil;
    [self reloadHeader];
}

- (void)resetTargetSort:(NSNumber *)sortColumn sortType:(CCSortType)sortType {
    if (!sortColumn) {
        return;
    }
    self.currentSortType = sortType == CCSortTypeAscending?CCSortTypeDescending:CCSortTypeAscending;;
    self.currentSortColumn = sortColumn;
    CCMatrix *matrix = [CCMatrix matrixWithColumn:sortColumn.integerValue row:0];
    CCExcelCell *cell = [delegate.excelView cellAtMatrix:matrix];
    UIScrollView *scrollView = delegate.excelView.headerCell.contentScrollView;
    CGPoint point = [scrollView.superview convertPoint:scrollView.frame.origin toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    CGFloat adjustX = 0;
    if (point.x < CC_ScreenWidth/2) {
        adjustX = CC_ScreenWidth/2 - point.x - cell.width/2;
    }
    CGFloat offsetX = cell.x - adjustX;
    if (offsetX < 0) {
        offsetX = 0;
    } else if (offsetX > scrollView.contentSize.width - scrollView.width) {
        offsetX = scrollView.contentSize.width - scrollView.width;
    }
    delegate.excelView.headerCell.shouldSendScrollNotification = YES;
    [scrollView setContentOffset:CC_point(offsetX, 0) animated:YES];
    __weak typeof(self) weak_self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weak_self) {
            __strong typeof(self) strong_self = weak_self;
            [weak_self excelView:strong_self -> delegate.excelView didSelectAt:matrix];
        }
    });
}

#pragma mark-
- (NSInteger)numberOfColumnsLockInExcelView:(CCExcelView *)excelView
{
    return self.lockNum;
}
- (NSInteger)numberOfFarrightColumnsLockInExcelView:(CCExcelView *)excelView
{
    return self.lockRightNum;
}

- (CGFloat)topRowHeightInExcelView:(CCExcelView *)excelView
{
    return self.headerHeight;
}

- (UIView *)topViewInExcelView:(CCExcelView *)excelView
{
    return self.topView;
}

- (CGFloat)topViewHeightInExcelView:(CCExcelView *)excelView
{
    UIView *v = self.topView;
    return v.bounds.size.height;
}

- (NSInteger)numberOfRowsInExcelView:(CCExcelView *)excelView
{
    return [delegate numberOfRowsInDataSource:self];
}

- (NSInteger)numberOfColumnsInExcelView:(CCExcelView *)excelView
{
    return [delegate numberOfColumnsInDataSource:self];
}

- (CGFloat)excelView:(CCExcelView *)excelView widthAtColumn:(NSInteger)column
{
    if ([delegate respondsToSelector:@selector(dataSource:widthAtColumn:)]) {
        CGFloat width =  [delegate dataSource:self widthAtColumn:column];
        if (width > 0) {
            if ([self shouldShowSortControl:[CCMatrix matrixWithColumn:column row:0]]) {
                width += 20;
            }
            return width;
        }
    }
    NSNumber *number = columnWidthArray[column];
    CGFloat calWidth = number.floatValue;
    return calWidth;
}

- (CCExcelCell *)excelView:(CCExcelView *)excelView cellAtMatrix:(CCMatrix *)matrix
{
    NSString *content = [self contentAtMatrix:matrix];
    CCExcelCell *cell;
    if ([delegate respondsToSelector:@selector(dataSource:cellAtMatrix:)]) {
        cell = [delegate dataSource:self cellAtMatrix:matrix];
    }
    if (excelView.showFooter && matrix.row == [delegate numberOfRowsInDataSource:self] + 1) {
        if (cell == nil) {
            cell = [[CCExcelCell alloc] initWithReuseIdentifier:@"footer"];
        }
    } else {
        if (matrix.row == 0) {
            if (cell == nil) {
                cell = [excelView dequeueReusableCellWithIdentifier:@"header"];
                if (!cell) {
                    if ([self shouldShowSortControl:matrix]) {
                        cell = [[CCSortExcelcell alloc] initWithReuseIdentifier:@"header"];
                    } else {
                        cell = [[CCExcelCell alloc] initWithReuseIdentifier:(@"header")];
                    }
                }
            }
        } else {
            if (cell == nil) {
                cell = [excelView dequeueReusableCellWithIdentifier:@"default"];
                if (cell == nil) {
                    cell = [[CCExcelCell alloc] initWithReuseIdentifier:@"default"];
                }
            }
        }
    }
    cell.style = [delegate dataSource:self styleAtMatrix:matrix];
    cell.label.text = content;
    if (!(excelView.showFooter && matrix.row == [delegate numberOfRowsInDataSource:self] + 1)) {
        [delegate dataSource:self handleCell:cell atMatrix:matrix];
    }
    if ([cell isMemberOfClass:[CCSortExcelcell class]]) {
        cell.label.textAlignment = NSTextAlignmentLeft;
        if (self.currentSortColumn && matrix.column == self.currentSortColumn.integerValue) {
            [(CCSortExcelcell *)cell setSortType:self.currentSortType];
        } else {
           [(CCSortExcelcell *)cell setSortType:CCSortTypeDefault];
        }
    } else {
        cell.label.textAlignment = [delegate dataSource:self textAlignmentAtColumn:matrix.column];
    }
    return cell;
}

- (BOOL)shouldLoadMore:(CCExcelView *)excelView
{
    if ([delegate respondsToSelector:@selector(shouldLoadMore:)]) {
        return [delegate shouldLoadMore:self];
    }
    return NO;
}

- (void)loadNextPage:(CCExcelView *)excelView
{
    if ([delegate respondsToSelector:@selector(loadNextPage:)]) {
        return [delegate loadNextPage:self];
    }
}

- (void)excelView:(CCExcelView *)excelView didSelectAt:(CCMatrix *)matrix
{
    if ([matrix isHeader]) {
        if ([self shouldShowSortControl:matrix]) {
            if (self.currentSortColumn.integerValue == matrix.column) {
                self.currentSortType = self.currentSortType == CCSortTypeAscending?CCSortTypeDescending:CCSortTypeAscending;
            } else {
                self.currentSortType = CCSortTypeAscending;
            }
            self.currentSortColumn = @(matrix.column);
            [self reloadHeader];
            if (self.sortAction) {
                self.sortAction(self.currentSortColumn, self.currentSortType);
            }
            if (self.sortActionWithTitle) {
                CCExcelCell *cell = [excelView cellAtMatrix:matrix];
                self.sortActionWithTitle(cell.label.text, self.currentSortType);
            }
        }
    }
    if ([delegate respondsToSelector:@selector(dataSource:selectAtMatrix:)]) {
        [delegate dataSource:self selectAtMatrix:matrix];
    }
}

- (void)reloadHeader {
    for (int i = 0; i < [delegate numberOfColumnsInDataSource:self]; i ++) {
        CCExcelCell *cell = [delegate.excelView cellAtMatrix:[CCMatrix matrixWithColumn:i row:0]];
        if ([cell isMemberOfClass:[CCSortExcelcell class]]) {
            [(CCSortExcelcell *)cell setSortType:CCSortTypeDefault];
            if (self.currentSortColumn.integerValue == i) {
                [(CCSortExcelcell *)cell setSortType:self.currentSortType];
            }
        }
    }
}

- (UIColor *)excelView:(CCExcelView *)excelView backgroundColorAtRow:(NSInteger)row
{
    if ([self.delegate respondsToSelector:@selector(dataSource:backgroundColorAtRow:)]) {
        return [self.delegate dataSource:self backgroundColorAtRow:row];
    }
    return CC_ColorClear;
}

#pragma mark-
///返回变化的最小的列号
- (NSInteger)calculateColumnWidthsFromRow:(NSInteger)row {
    NSInteger columnCount = [delegate numberOfColumnsInDataSource:self];
    NSInteger rowCount = [delegate numberOfRowsInDataSource:self] + 1;
    if (delegate.excelView.showFooter) {
        rowCount++;
    }
    NSInteger fromCloumn = columnCount - 1;
    if (row == 0) {
        fromCloumn = 0;
        [columnWidthArray removeAllObjects];
        for (NSInteger i = 0; i < columnCount; i++) {
            [columnWidthArray addObject:@0];
        }
    }
    for (NSInteger i = 0; i < columnCount; i++) {
        CGFloat width = 0;
        for (NSInteger j = row; j < rowCount; j++) {
            CCMatrix *matrix = [CCMatrix matrixWithColumn:i row:j];
            NSString *content = [self contentAtMatrix:matrix];
            CGSize maxSize = CC_size(MAXFLOAT, 40);
            CGFloat cellWidth = [CCHelper sizeWithString:content font:kExcelCellLabelFont maxSize:maxSize].width;
            if (j == 0) {
                //如果支持排序加上排序图片的宽度
                if ([self shouldShowSortControl:matrix]) {
                    cellWidth += 20;
                }
            }
            width = MAX(width, cellWidth);
        }
        CGFloat minWidth = self.minExcelColumnWidth;
        CGFloat maxWidth = self.maxExcelColumnWidth;
        if ([delegate respondsToSelector:@selector(dataSource:minExcelColumnWidth:)]) {
            CGFloat width =  [delegate dataSource:self minExcelColumnWidth:i];
            if (width > 0) {
                minWidth = width;
            }
        }
        if ([delegate respondsToSelector:@selector(dataSource:maxExcelColumnWidth:)]) {
            CGFloat width =  [delegate dataSource:self maxExcelColumnWidth:i];
            if (width > 0) {
                maxWidth = width;
            }
        }
        if (width < minWidth) {
            width = minWidth;
        }
        if (width > maxWidth) {
            width = maxWidth;
        }
        CGFloat targetWidth = width + kExcelCellLabelMarginX*2;
        CGFloat oldWidth = [[columnWidthArray objectAtIndex:i] floatValue];
        if (oldWidth != targetWidth) {
            targetWidth = MAX(targetWidth, oldWidth);
            fromCloumn = MIN(fromCloumn, i);//最左侧列，所以取最小值
            [columnWidthArray replaceObjectAtIndex:i withObject:@(targetWidth)];
        }
    }
    return fromCloumn;
}

- (void)calculateColumnWidths
{
    NSInteger columnCount = [delegate numberOfColumnsInDataSource:self];
    NSInteger rowCount = [delegate numberOfRowsInDataSource:self] + 1;
    if (delegate.excelView.showFooter) {
        rowCount++;
    }
    [columnWidthArray removeAllObjects];
    for (NSInteger i = 0; i < columnCount; i++) {
        CGFloat width = 0;
        for (NSInteger j = 0; j < rowCount; j++) {
            CCMatrix *matrix = [CCMatrix matrixWithColumn:i row:j];
            NSString *content = [self contentAtMatrix:matrix];
            CGSize maxSize = CC_size(MAXFLOAT, 40);
            CGFloat cellWidth = [CCHelper sizeWithString:content font:kExcelCellLabelFont maxSize:maxSize].width;
            if (j == 0) {
                //如果支持排序加上排序图片的宽度
                if ([self shouldShowSortControl:matrix]) {
                    cellWidth += 20;
                }
            }
            width = MAX(width, cellWidth);
        }
        CGFloat minWidth = self.minExcelColumnWidth;
        CGFloat maxWidth = self.maxExcelColumnWidth;
        if ([delegate respondsToSelector:@selector(dataSource:minExcelColumnWidth:)]) {
            CGFloat width =  [delegate dataSource:self minExcelColumnWidth:i];
            if (width > 0) {
                minWidth = width;
            }
        }
        if ([delegate respondsToSelector:@selector(dataSource:maxExcelColumnWidth:)]) {
            CGFloat width =  [delegate dataSource:self maxExcelColumnWidth:i];
            if (width > 0) {
                maxWidth = width;
            }
        }
        if (width < minWidth) {
            width = minWidth;
        }
        if (width > maxWidth) {
            width = maxWidth;
        }
        [columnWidthArray addObject:@(width + kExcelCellLabelMarginX*2)];
    }
}

- (NSString *)contentAtMatrix:(CCMatrix *)matrix
{
    NSString *content = nil;
    if (delegate.excelView.showFooter && matrix.row == [delegate numberOfRowsInDataSource:self] + 1) {
        if ([delegate respondsToSelector:@selector(dataSource:sumContentAtColumn:)]) {
            content = [delegate dataSource:self sumContentAtColumn:matrix.column];
        }
    } else {
        content = [delegate dataSource:self contentAtMatrix:matrix];
    }
    return content;
}

- (BOOL)shouldShowSortControl:(CCMatrix *)matrix {
    if ([delegate respondsToSelector:@selector(shouldShowSortControl:withMatrix:)]) {
        return [delegate shouldShowSortControl:self withMatrix:matrix];
    }
    return NO;
}

@end
