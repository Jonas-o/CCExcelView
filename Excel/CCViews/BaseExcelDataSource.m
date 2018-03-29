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
}
@synthesize delegate;

- (instancetype)init
{
    if (self = [super init]) {
        self.minExcelColumnWidth = 80;
        self.maxExcelColumnWidth = 160;
        self.lockNum = 1;
        self.lockRightNum = 0;
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
    NSNumber *number = columnWidthArray[column];
    CGFloat calWidth = number.floatValue;
    if ([delegate respondsToSelector:@selector(dataSource:widthAtColumn:)]) {
        CGFloat width =  [delegate dataSource:self widthAtColumn:column];
        if (width > 0) {
            if ([self shouldShowSortControl:[CCMatrix matrixWithColumn:column row:0]]) {
                return width + 20;
            }
            return width;
        }
    }
    if ([self shouldShowSortControl:[CCMatrix matrixWithColumn:column row:0]]) {
        return calWidth + 20;
    }
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
    return [delegate shouldLoadMore:self];
}

- (void)loadNextPage:(CCExcelView *)excelView
{
    [delegate loadNextPage:self];
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
- (void)calculateColumnWidths
{
    NSInteger columnCount = [delegate numberOfColumnsInDataSource:self];
    NSInteger rowCount = [delegate numberOfRowsInDataSource:self] + 1;
    if (delegate.excelView.showFooter) {
        rowCount++;
    }
    columnWidthArray = [NSMutableArray array];
    for (NSInteger i = 0; i < columnCount; i++) {
        CGFloat width = 0;
        for (NSInteger j = 0; j < rowCount; j++) {
            CCMatrix *matrix = [CCMatrix matrixWithColumn:i row:j];
            NSString *content = [self contentAtMatrix:matrix];
            CGSize maxSize = CC_size(MAXFLOAT, 40);
            CGFloat cellWidth = [CCHelper sizeWithString:content font:kExcelCellLabelFont maxSize:maxSize].width;
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
