//
//  CCExcelView.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "CCExcelView.h"
#import "CCExcelRowCell.h"
#import "CCUtil.h"

const CGFloat excelViewLoadMoreOffset = 100;

@interface CCExcelView() <UITableViewDelegate, UITableViewDataSource, CCExcelRowCellDelegate>

@end

@implementation CCExcelView {
    CCExcelRowCell *headerCell;
    CCExcelRowCell *footerCell;
    CGPoint currentRowCellOffset;
    
    NSInteger columnNum;
    NSInteger lockColumnNum;
    NSInteger farrightLockColumnNum;
    
    CGFloat rowHeight;
    CGFloat topRowHeight;
    CGFloat bottomRowHeight;
    CGFloat rowWidth;
    
    NSMutableDictionary *reusableCells;
    NSMutableArray *cells;
    
    CGFloat topViewHeight;
    UIView *topView;
    
    CGFloat currentOffsetY;
    BOOL forward;
    BOOL dragging;
    
    UIActivityIndicatorView *loadingView;
}
@synthesize table, showFooter;

- (instancetype)initWithFrame:(CGRect)frame rowHeight:(CGFloat)rowHeight_ {
    return [self initWithFrame:frame rowHeight:rowHeight_ showFooter:NO];
}

- (instancetype)initWithFrame:(CGRect)frame rowHeight:(CGFloat)rowHeight_ showFooter:(BOOL)showFooter_ {
    if (self = [super initWithFrame:frame]) {
        self.autoShowTopView = YES;
        showFooter = showFooter_;
        rowHeight = rowHeight_;
        topRowHeight = rowHeight;
        if (showFooter) {
            bottomRowHeight = rowHeight;
        }
        
        CGRect tableFrame = rect(0, rowHeight, self.bounds.size.width, self.bounds.size.height - topRowHeight - bottomRowHeight);
        table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = ColorClear;
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        [self addSubview:table];
        
        reusableCells = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)refreshData:(id)sender {
    if ([self.delegate respondsToSelector:@selector(refresh)]) {
        [self.delegate refresh];
    }
}

- (void)deleteRow:(NSInteger)row {
    if (row > 0 && ![self isBottomRow:row]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:0];
        [table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)reloadDataAndRowCell {
    [table setContentOffset:point(0, -table.contentInset.top) animated:NO];
    currentRowCellOffset = CGPointZero;
    [self reloadData];
}

- (void)reloadData {
    if ([self.delegate respondsToSelector:@selector(topRowHeightInExcelView:)]) {
        topRowHeight = [self.delegate topRowHeightInExcelView:self];
    }
    if (showFooter && [self.delegate respondsToSelector:@selector(bottomRowHeightInExcelView:)]) {
        bottomRowHeight = [self.delegate bottomRowHeightInExcelView:self];
    }
    table.frame = rect(0, topRowHeight, self.bounds.size.width, self.bounds.size.height - topRowHeight - bottomRowHeight);
    [reusableCells removeAllObjects];
    columnNum = [self.delegate numberOfColumnsInExcelView:self];
    lockColumnNum = 1;
    if ([self.delegate respondsToSelector:@selector(numberOfColumnsLockInExcelView:)]) {
        lockColumnNum = [self.delegate numberOfColumnsLockInExcelView:self];
    }
    farrightLockColumnNum = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfFarrightColumnsLockInExcelView:)]) {
        farrightLockColumnNum = [self.delegate numberOfFarrightColumnsLockInExcelView:self];
    }
    rowWidth = 0;
    for (int i = 0; i < columnNum; i++) {
        CGFloat width = [self.delegate excelView:self widthAtColumn:i];
        rowWidth += width;
    }
    [headerCell removeFromSuperview];
    headerCell = [[CCExcelRowCell alloc] initWithFrame:rectZP(self.bounds.size.width, topRowHeight)];
    headerCell.frame = rectZP(self.bounds.size.width, topRowHeight);
    headerCell.delegate = self;
    headerCell.backgroundColor = RGB(244, 246, 248);
    
    if ([self.delegate respondsToSelector:@selector(excelView:bottomLineColorAtRow:)]) {
        UIColor *c = [self.delegate excelView:self bottomLineColorAtRow:0];
        if (c) {
            headerCell.line.backgroundColor = c;
        }
    }
    [self addSubview:headerCell];
    [self resetRowCell:headerCell atRow:0];
    
    if (showFooter) {
        NSInteger footRow = [self.delegate numberOfRowsInExcelView:self] + 1;
        [footerCell removeFromSuperview];
        footerCell = [[CCExcelRowCell alloc] initWithFrame:rect(0, self.bounds.size.height - bottomRowHeight, self.bounds.size.width, bottomRowHeight)];
        footerCell.frame = rect(0, self.bounds.size.height - bottomRowHeight, self.bounds.size.width, bottomRowHeight);
        footerCell.delegate = self;
        footerCell.backgroundColor = ColorClear;
        
        if ([self.delegate respondsToSelector:@selector(excelView:bottomLineColorAtRow:)]) {
            UIColor *c = [self.delegate excelView:self bottomLineColorAtRow:footRow];
            if (c) {
                footerCell.line.backgroundColor = c;
            }
        }
        [self addSubview:footerCell];
        [self resetRowCell:footerCell atRow:footRow];
    }
    
    [table reloadData];
    
    [self handleTopView];
    [self handleTopViewFrame];
    [self handleHeaderCellFrame];
    
    [loadingView stopAnimating];
}

- (void)resetAllColumnsWidth {
    [self resetAllColumnsWidthFromIndex:0];
}

- (void)resetAllColumnsWidthFromIndex:(NSInteger)reloadColumnIndex {
    for (NSInteger i = reloadColumnIndex; i < [self.delegate numberOfColumnsInExcelView:self]; i++) {
        [self resetColumnsWidthFromIndex:i];
    }
}

- (void)resetColumnsWidthFromIndex:(NSInteger)reloadColumnIndex {
    NSInteger columnCount = [self.delegate numberOfColumnsInExcelView:self];
    NSInteger rightLockCount = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfFarrightColumnsLockInExcelView:)]) {
        rightLockCount = [self.delegate numberOfFarrightColumnsLockInExcelView:self];
    }
    CGFloat columnWidth = [self.delegate excelView:self widthAtColumn:reloadColumnIndex];
    CCExcelCell *headerColumnCell = [self cellAtMatrix:[CCMatrix matrixWithColumn:reloadColumnIndex row:0]];
    if (headerColumnCell.bounds.size.width != columnWidth) {
        CGFloat xoffset = columnWidth - headerColumnCell.bounds.size.width;
        if (reloadColumnIndex < lockColumnNum) {
            [self resetLeftColumnsWithXOffset:xoffset fromIndex:reloadColumnIndex];
        } else if (reloadColumnIndex < columnCount - rightLockCount) {
            [self resetScrollColumnsWithXOffset:xoffset fromIndex:reloadColumnIndex];
        } else {
            [self resetRightCoumnsWithXOffset:xoffset fromIndex:reloadColumnIndex];
        }
        [headerCell resetCellContentViewSize];
        for (CCExcelRowCell *cell in [table visibleCells]) {
            [cell resetCellContentViewSize];
        }
    }
}

- (void)resetLeftColumnsWithXOffset:(CGFloat)xoffset fromIndex:(NSInteger)index {
    for (NSInteger i = 0; i < lockColumnNum; i++) {
        if (i >= index) {
            for (NSNumber *rowNum in [self visiableRows]) {
                CCExcelCell *cell = [self cellAtMatrix:[CCMatrix matrixWithColumn:i row:rowNum.integerValue]];
                CGRect frame = cell.frame;
                if (i == index) {
                    frame.size.width += xoffset;
                } else {
                    frame.origin.x += xoffset;
                }
                cell.frame = frame;
            }
        }
    }
    CGRect scrollFrame = headerCell.contentScrollView.frame;
    scrollFrame.origin.x += xoffset;
    headerCell.contentScrollView.frame = scrollFrame;
    for (CCExcelRowCell *cell in [table visibleCells]) {
        cell.contentScrollView.frame = scrollFrame;
    }
}

- (void)resetRightCoumnsWithXOffset:(CGFloat)xoffset fromIndex:(NSInteger)index {
    NSInteger columnCount = [self.delegate numberOfColumnsInExcelView:self];
    NSInteger rightLockCount = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfFarrightColumnsLockInExcelView:)]) {
        rightLockCount = [self.delegate numberOfFarrightColumnsLockInExcelView:self];
    }
    for (NSInteger i = columnCount - rightLockCount; i < columnCount; i++) {
        if (i >= index) {
            for (NSNumber *rowNum in [self visiableRows]) {
                CCExcelCell *cell = [self cellAtMatrix:[CCMatrix matrixWithColumn:i row:rowNum.integerValue]];
                CGRect frame = cell.frame;
                if (i == index) {
                    frame.size.width += xoffset;
                } else {
                    frame.origin.x += xoffset;
                }
                cell.frame = frame;
            }
        }
    }
}

- (void)resetScrollColumnsWithXOffset:(CGFloat)xoffset fromIndex:(NSInteger)index {
    NSInteger columnCount = [self.delegate numberOfColumnsInExcelView:self];
    NSInteger rightLockCount = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfFarrightColumnsLockInExcelView:)]) {
        rightLockCount = [self.delegate numberOfFarrightColumnsLockInExcelView:self];
    }
    for (NSInteger i = lockColumnNum; i < columnCount - rightLockCount; i++) {
        if (i >= index) {
            for (NSNumber *rowNum in [self visiableRows]) {
                CCExcelCell *cell = [self cellAtMatrix:[CCMatrix matrixWithColumn:i row:rowNum.integerValue]];
                CGRect frame = cell.frame;
                if (i == index) {
                    frame.size.width += xoffset;
                } else {
                    frame.origin.x += xoffset;
                }
                cell.frame = frame;
            }
        }
    }
}

- (void)showTopView {
    [table setContentOffset:point(0, -table.contentInset.top) animated:YES];
}

- (void)hideTopView {
    [table setContentOffset:CGPointZero animated:YES];
}

- (void)handleTopView {
    CGFloat height = 0;
    UIView *view = nil;
    if ([self.delegate respondsToSelector:@selector(topViewHeightInExcelView:)]) {
        height = [self.delegate topViewHeightInExcelView:self];
    }
    if (height > 0) {
        if ([self.delegate respondsToSelector:@selector(topViewInExcelView:)]) {
            view = [self.delegate topViewInExcelView:self];
        }
    }
    if (view != nil && height > 0) {
        topViewHeight = height;
        if (![view isEqual:topView]) {
            [topView removeFromSuperview];
            topView = view;
        }
        if (topView.superview == nil) {
            topView.frame = rect(0, 0, self.bounds.size.width, height);
            [self addSubview:topView];
        }
        UIEdgeInsets insets = table.contentInset;
        insets.top = height;
        table.contentInset = insets;
    } else {
        [topView removeFromSuperview];
        UIEdgeInsets insets = table.contentInset;
        insets.top = 0;
        table.contentInset = insets;
    }
}

- (void)handleTopViewFrame {
    if (topView != nil && topViewHeight > 0) {
        CGFloat offsetY = table.contentOffset.y;
        CGRect frame = topView.frame;
        if (offsetY >= 0) {
            frame.origin.y = -topViewHeight;
            if ([self.delegate respondsToSelector:@selector(excelViewDidHideTopView:)]) {
                [self.delegate excelViewDidHideTopView:self];
            }
        } else if (offsetY > -topViewHeight) {
            frame.origin.y = -topViewHeight - offsetY;
        } else {
            frame.origin.y = 0;
            if ([self.delegate respondsToSelector:@selector(excelViewDidShowTopView:)]) {
                [self.delegate excelViewDidShowTopView:self];
            }
        }
        if (topView.frame.origin.y != frame.origin.y) {
            topView.frame = frame;
        }
    }
}

- (void)handleHeaderCellFrame {
    CGFloat offsetY = table.contentOffset.y;
    CGRect frame = headerCell.frame;
    if (offsetY >= 0) {
        frame.origin.y = 0;
        table.showsVerticalScrollIndicator = YES;
    } else {
        table.showsVerticalScrollIndicator = NO;
        frame.origin.y = -offsetY;
    }
    headerCell.frame = frame;
}

- (CCExcelCell *)dequeueReusableCellWithIdentifier:(NSString *)cellIdentifier {
    NSMutableArray *array = [reusableCells objectForKey:cellIdentifier];
    if ([array count] == 0) {
        return nil;
    }
    CCExcelCell *lastCell = [array lastObject];
    [array removeLastObject];
    return lastCell;
}

- (void)reuseCell:(CCExcelCell *)cell {
    [cell removeFromSuperview];
    NSString *identifer = cell.reuseIdentifier;
    if ([reusableCells objectForKey:identifer] == nil) {
        NSMutableArray *array = [NSMutableArray array];
        [reusableCells setObject:array forKey:identifer];
    }
    NSMutableArray *array = [reusableCells objectForKey:identifer];
    if (![array containsObject:cell]) {
        [array addObject:cell];
    }
}

- (CCExcelRowCell *)contenViewAtRow:(NSInteger)row {
    if (row == 0) {
        return headerCell;
    }
    if ([self isBottomRow:row]) {
        return footerCell;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:0];
    CCExcelRowCell *cell = [table cellForRowAtIndexPath:indexPath];
    return cell;
}

- (NSArray *)visiableRows {
    NSMutableArray *visableRows = [NSMutableArray arrayWithObject:@(0)];
    
    for (NSIndexPath *indexPath in [table indexPathsForVisibleRows]) {
        [visableRows addObject:@(indexPath.row + 1)];
    }
    if (showFooter) {
        NSInteger rowCount = [self.delegate numberOfRowsInExcelView:self] + 2;
        [visableRows addObject:@(rowCount-1)];
    }
    return visableRows;
}

- (void)setHighlight:(BOOL)highlight atRow:(NSInteger)row {
    if (row > 0 && ![self isBottomRow:row]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:0];
        CCExcelRowCell *cell = [table cellForRowAtIndexPath:indexPath];
        cell.contentView.backgroundColor = highlight ? RGBA(240, 240, 240, 1) : ColorClear;
        CCExcelCell *lockCell = [cell excelCellAtColumn:0];
        [lockCell setSwitchOn:highlight];
    }
}

- (CCExcelCell *)cellAtMatrix:(CCMatrix *)matrix {
    if (matrix == nil) {
        return nil;
    }
    if ([self isBottomRow:matrix.row]) {
        return [footerCell excelCellAtColumn:matrix.column];
    }
    if (matrix.row == 0) {
        return [headerCell excelCellAtColumn:matrix.column];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:matrix.row-1 inSection:0];
    CCExcelRowCell *cell = [table cellForRowAtIndexPath:indexPath];
    return [cell excelCellAtColumn:matrix.column];
}

- (CCMatrix *)matrixOfCell:(CCExcelCell *)cell {
    NSInteger column = -1;
    NSInteger row = -1;
    CCExcelRowCell *containCell;
    if ([footerCell.lockCells containsObject:cell] || [footerCell.scrollCells containsObject:cell] || [footerCell.farrightLockCells containsObject:cell]) {
        row = [self.delegate numberOfRowsInExcelView:self] + 1;
        containCell = footerCell;
    } else if ([headerCell.lockCells containsObject:cell] || [headerCell.scrollCells containsObject:cell] || [headerCell.farrightLockCells containsObject:cell]) {
        row = 0;
        containCell = headerCell;
    } else {
        for (CCExcelRowCell *rowCell in [table visibleCells]) {
            NSIndexPath *path = [table indexPathForCell:rowCell];
            if ([rowCell.lockCells containsObject:cell] || [rowCell.scrollCells containsObject:cell] || [rowCell.farrightLockCells containsObject:cell]) {
                row = path.row + 1;
                containCell = rowCell;
                break;
            }
        }
    }
    if (row >= 0 && containCell != nil) {
        if ([containCell.lockCells containsObject:cell]) {
            column = [containCell.lockCells indexOfObject:cell];
        } else if ([containCell.scrollCells containsObject:cell]) {
            column = containCell.lockCells.count + [containCell.scrollCells indexOfObject:cell];
        } else {
            column = containCell.lockCells.count + containCell.scrollCells.count + [containCell.farrightLockCells indexOfObject:cell];
        }
        return [CCMatrix matrixWithColumn:column row:row];
    }
    return nil;
}

- (BOOL)isBottomRow:(NSInteger)row {
    if (!showFooter) {
        return NO;
    }
    return row == [self.delegate numberOfRowsInExcelView:self] + 1;
}

#pragma mark- UITableViewDelegate & UITableViewDataSource
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(excelViewDidScroll:)]) {
        [self.delegate excelViewDidScroll:self];
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if (dragging) {
        forward = offsetY > currentOffsetY;
        currentOffsetY = offsetY;
    }
    [self handleTopViewFrame];
    [self handleHeaderCellFrame];
}

- (void)loadNextPage {
    CGFloat offsetY = table.contentOffset.y;
    if (!self.loading &&  offsetY > table.contentSize.height - table.bounds.size.height - excelViewLoadMoreOffset) {
        BOOL shouldLoadMore = NO;
        if ([self.delegate respondsToSelector:@selector(shouldLoadMore:)]) {
            shouldLoadMore = [self.delegate shouldLoadMore:self];
        }
        if (shouldLoadMore) {
            if ([self.delegate respondsToSelector:@selector(loadNextPage:)]) {
                if (loadingView == nil) {
                    loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [table addSubview:loadingView];
                }
                loadingView.frame = rect((table.bounds.size.width-30)/2, table.contentSize.height + 5, 30, 30);
                [self.delegate loadNextPage:self];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    dragging = YES;
    currentOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(excelViewDidEndScroll:)]) {
        [self.delegate excelViewDidEndScroll:self];
        
    }
    [self loadNextPage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(excelViewDidEndScroll:)]) {
        [self.delegate excelViewDidEndScroll:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    dragging = NO;
    if (!decelerate) {
        if ([self.delegate respondsToSelector:@selector(excelViewDidEndScroll:)]) {
            [self.delegate excelViewDidEndScroll:self];
        }
        [self loadNextPage];
    }
    if (!decelerate && topView != nil && self.autoShowTopView) {
        NSInteger rowNum = [self.delegate numberOfRowsInExcelView:self];
        if (rowNum * rowHeight <= table.bounds.size.height) {
            return;
        }
        if (forward && scrollView.contentOffset.y < 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideTopView];
            });
        }
        if (!forward && scrollView.contentOffset.y < 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showTopView];
            });
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.delegate numberOfRowsInExcelView:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCExcelRowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[CCExcelRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.delegate = self;
    }
    [self resetRowCell:cell atRow:indexPath.row+1];
    
    UIColor *lineColor = nil;
    if ([self.delegate respondsToSelector:@selector(excelView:bottomLineColorAtRow:)]) {
        lineColor = [self.delegate excelView:self bottomLineColorAtRow:indexPath.row+1];
    }
    if (lineColor) {
        cell.line.backgroundColor = lineColor;
    }
    
    UIColor *color = ColorClear;
    if ([self.delegate respondsToSelector:@selector(excelView:backgroundColorAtRow:)]) {
        color = [self.delegate excelView:self backgroundColorAtRow:indexPath.row + 1];
        if (color == nil) {
            color = ColorClear;
        }
    }
    BOOL highlight = NO;
    if ([self.delegate respondsToSelector:@selector(excelView:shouldHighlightAtRow:)]) {
        highlight = [self.delegate excelView:self shouldHighlightAtRow:indexPath.row + 1];
        CCExcelCell *lockCell = [cell excelCellAtColumn:0];
        [lockCell setSwitchOn:highlight];
    }
    if (highlight) {
        color = RGBA(240, 240, 240, 1);
    }
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CCExcelRowCell *rowCell = (CCExcelRowCell *) cell;
    for (CCExcelCell *excelCell in rowCell.lockCells) {
        [self reuseCell:excelCell];
    }
    for (CCExcelCell *excelCell in rowCell.scrollCells) {
        [self reuseCell:excelCell];
    }
    for (CCExcelCell *excelCell in rowCell.farrightLockCells) {
        [self reuseCell:excelCell];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark-
- (void)resetRowCell:(CCExcelRowCell*)cell atRow:(NSInteger)row {
    NSMutableArray *lockExcelCells = [NSMutableArray array];
    NSMutableArray *scrollCells = [NSMutableArray array];
    NSMutableArray *rightLockExcelCells = [NSMutableArray array];
    for (int i = 0; i < columnNum; i++) {
        CCExcelCell *excelCell = [self.delegate excelView:self cellAtMatrix:[CCMatrix matrixWithColumn:i row:row]];
        CGFloat excelCellWidth = [self.delegate excelView:self widthAtColumn:i];
        CGFloat height = rowHeight;
        if (row == 0) {
            height = topRowHeight;
        }
        if ([self isBottomRow:row]) {
            height = bottomRowHeight;
        }
        excelCell.frame = rectZP(excelCellWidth, height);
        if (i < lockColumnNum) {
            [lockExcelCells addObject:excelCell];
        } else if (i < columnNum - farrightLockColumnNum) {
            [scrollCells addObject:excelCell];
        } else {
            [rightLockExcelCells addObject:excelCell];
        }
    }
    [cell setLockItems:lockExcelCells scrollItems:scrollCells rightLockItems:rightLockExcelCells];
    [cell controlScrollOffset:currentRowCellOffset];
}

#pragma mark- CCExcelRowCellDelegate
- (void)excelRowCell:(CCExcelRowCell *)cell didScrollViewAtOffset:(CGPoint)offset {
    if (!cell.shouldSendScrollNotification) {
        return;
    }
    currentRowCellOffset = offset;
    for (CCExcelRowCell *rowCell in [table visibleCells]) {
        if (rowCell != cell) {
            [rowCell controlScrollOffset:currentRowCellOffset];
        }
    }
    if (headerCell != cell) {
        [headerCell controlScrollOffset:offset];
    }
    if (footerCell != cell) {
        [footerCell controlScrollOffset:offset];
    }
}

- (void)excelRowCellDidBeginDragging:(CCExcelRowCell *)cell atOffest:(CGPoint)offset {
    cell.shouldSendScrollNotification = YES;
    currentRowCellOffset = offset;
    for (CCExcelRowCell *rowCell in [table visibleCells]) {
        if (rowCell != cell) {
            rowCell.shouldSendScrollNotification = NO;
            [rowCell controlScrollOffset:currentRowCellOffset];
        }
    }
    if (headerCell != cell) {
        headerCell.shouldSendScrollNotification = NO;
        [headerCell controlScrollOffset:currentRowCellOffset];
    }
    if (footerCell != cell) {
        footerCell.shouldSendScrollNotification = NO;
        [footerCell controlScrollOffset:currentRowCellOffset];
    }
}

- (BOOL)excelRowCellShouldControlSrcoll:(CCExcelRowCell *)cell {
    if (cell.shouldSendScrollNotification) {
        return YES;
    }
    for (CCExcelRowCell *c in table.visibleCells) {
        if (c.shouldSendScrollNotification) {
            return NO;
        }
    }
    if (headerCell.shouldSendScrollNotification) {
        return NO;
    }
    if (footerCell.shouldSendScrollNotification) {
        return NO;
    }
    return YES;
}

- (void)resetControlScroll {
    for (CCExcelRowCell *c in table.visibleCells) {
        c.shouldSendScrollNotification = NO;
    }
    headerCell.shouldSendScrollNotification = NO;
    footerCell.shouldSendScrollNotification = NO;
}

- (void)resetAllRowCellsContentOffset:(CCExcelRowCell *)cell {
    CGPoint point = cell.contentScrollView.contentOffset;
    for (CCExcelRowCell *rowCell in [table visibleCells]) {
        if (rowCell != cell) {
            rowCell.contentScrollView.contentOffset = point;
        }
    }
    headerCell.contentScrollView.contentOffset = point;
    footerCell.contentScrollView.contentOffset = point;
    currentRowCellOffset = point;
}

- (void)excelRowCell:(CCExcelRowCell *)cell didSelectAtColumn:(NSInteger)column {
    NSInteger row = -1;
    if (cell == footerCell) {
        BOOL resp = NO;
        if ([self.delegate respondsToSelector:@selector(excelViewShouldResponseFooterCell:)]) {
            resp = [self.delegate excelViewShouldResponseFooterCell:self];
        }
        if (resp) {
            row = [self.delegate numberOfRowsInExcelView:self] + 1;
        }
    } if (cell == headerCell) {
        row = 0;
    } else {
        NSIndexPath *indexPath = [table indexPathForCell:cell];
        if (indexPath != nil) {
            row = indexPath.row + 1;
        }
    }
    if (row >= 0 && [self.delegate respondsToSelector:@selector(excelView:didSelectAt:)]) {
        [self.delegate excelView:self didSelectAt:[CCMatrix matrixWithColumn:column row:row]];
    }
}

- (CCExcelViewCellSelectionStyle)excelRowCell:(CCExcelRowCell *)cell highlightStyleAtColumn:(NSInteger)column {
    if (cell == footerCell) {
        return CCExcelViewCellSelectionStyleNone;
    } if (cell == headerCell) {
        return CCExcelViewCellSelectionStyleNone;
    }
    if ([self.delegate respondsToSelector:@selector(excelView:didSelectAt:)]) {
        return self.selectionStyle;
    }
    return NO;
}

@end

@implementation CCMatrix

+ (CCMatrix *)matrixWithColumn:(NSInteger)column row:(NSInteger)row {
    CCMatrix *matrix = [[CCMatrix alloc] init];
    matrix.column = column;
    matrix.row = row;
    return matrix;
}

- (NSString *)genIndexString {
    NSString *str = [NSString stringWithFormat:@"%ld", self.row];
    if (self.row < 10) {
        str = [NSString stringWithFormat:@"0%ld", self.row];
    }
    return str;
}

- (BOOL)isHeader {
    return self.row == 0;
}

- (BOOL)isLeader {
    return self.column == 0;
}

- (BOOL)isHeaderAndLeader {
    return self.row == 0 && self.column == 0;
}

- (BOOL)notHeaderLeader {
    return self.row > 0 && self.column > 0;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"column: %ld, row:%ld", self.column, self.row];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[CCMatrix class]]) {
        return NO;
    }
    CCMatrix *other = (CCMatrix *)object;
    if ((_row != other.row) || (_column != other.column)) {
        return NO;
    }
    return YES;
}

@end

