//
//  CCExcelView.m
//  CCExcelView
//
//  Created by luo on 2017/5/4.
//  Copyright © 2017年 CCExcelView. All rights reserved.
//

#import "CCExcelView.h"
#import "CCExcelRowCell.h"
#import "CCHelper.h"

const CGFloat excelViewLoadMoreOffset = 100;
static NSString *cc_reuseIdentifier = @"cc_cell";

@interface CCExcelView() <UITableViewDelegate, UITableViewDataSource, CCExcelRowCellDelegate>

@end

@implementation CCExcelView
{
    CCExcelRowCell *footerCell;
    UIImageView *footerShadowImageView;
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
}
@synthesize table, showFooter, headerCell;

- (void)awakeFromNib {
    [super awakeFromNib];
    showFooter = NO;
    rowHeight = 50;
    [self didInitialized];
}

- (instancetype)init {
    self = [self initWithFrame:CC_rectZP(100, 100) rowHeight:50 showFooter:NO];
    if (self) {

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame rowHeight:(CGFloat)rowHeight_
{
    return [self initWithFrame:frame rowHeight:rowHeight_ showFooter:NO];
}

- (instancetype)initWithFrame:(CGRect)frame rowHeight:(CGFloat)rowHeight_ showFooter:(BOOL)showFooter_
{
    if (self = [super initWithFrame:frame]) {
        showFooter = showFooter_;
        rowHeight = rowHeight_;
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    self.autoShowTopView = YES;
    topRowHeight = rowHeight;
    if (showFooter) {
        bottomRowHeight = rowHeight;
    }
    CGRect tableFrame = CC_rect(0, rowHeight, self.bounds.size.width, self.bounds.size.height - topRowHeight - bottomRowHeight);
    table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = CC_ColorClear;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    table.estimatedRowHeight = 0;
    table.estimatedSectionHeaderHeight = 0;
    table.estimatedSectionFooterHeight = 0;
    [self addSubview:table];
    reusableCells = [NSMutableDictionary dictionary];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self.delegate respondsToSelector:@selector(topRowHeightInExcelView:)]) {
        topRowHeight = [self.delegate topRowHeightInExcelView:self];
    }
    if (showFooter && [self.delegate respondsToSelector:@selector(bottomRowHeightInExcelView:)]) {
        bottomRowHeight = [self.delegate bottomRowHeightInExcelView:self];
    }
    
    table.frame = CC_rect(0, topRowHeight, self.bounds.size.width, self.bounds.size.height - topRowHeight - bottomRowHeight);
    
    headerCell.frame = CC_rectZP(self.bounds.size.width, topRowHeight);
    [self handleHeaderCellFrame];
    
    if (showFooter) {
        footerCell.frame = CC_rect(0, self.bounds.size.height - bottomRowHeight, self.bounds.size.width, bottomRowHeight);
    }
}

- (void)refreshData:(id)sender {
    if ([self.delegate respondsToSelector:@selector(refresh)]) {
        [self.delegate refresh];
    }
}

- (void)deleteRow:(NSInteger)row
{
    if (row > 0 && ![self isBottomRow:row]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:0];
        @try {
            [table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } @catch (NSException *exception) {
            [table reloadData];
        }
    }
}

- (void)reloadDataAndRowCell
{
    [table setContentOffset:CC_point(0, -table.contentInset.top) animated:NO];
    currentRowCellOffset = CGPointZero;
    [self reloadData];
}

- (void)reloadData
{
    if ([self.delegate respondsToSelector:@selector(topRowHeightInExcelView:)]) {
        topRowHeight = [self.delegate topRowHeightInExcelView:self];
    }
    if (showFooter && [self.delegate respondsToSelector:@selector(bottomRowHeightInExcelView:)]) {
        bottomRowHeight = [self.delegate bottomRowHeightInExcelView:self];
    }
//    table.frame = CC_rect(0, topRowHeight, self.bounds.size.width, self.bounds.size.height - topRowHeight - bottomRowHeight);
//    [reusableCells removeAllObjects];
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
    headerCell = [[CCExcelRowCell alloc] initWithFrame:CC_rectZP(self.bounds.size.width, topRowHeight)];
    headerCell.frame = CC_rectZP(self.bounds.size.width, topRowHeight);
    headerCell.delegate = self;
    headerCell.backgroundColor = CC_RGB(244, 246, 248);

    if ([self.delegate respondsToSelector:@selector(excelView:bottomLineColorAtRow:)]) {
        UIColor *c = [self.delegate excelView:self bottomLineColorAtRow:0];
        if (c) {
            headerCell.line.backgroundColor = c;
        }
    }
    [self addSubview:headerCell];
    [self reloadHeaderCell];

    if (showFooter) {
        NSInteger footRow = [self.delegate numberOfRowsInExcelView:self] + 1;
        [footerCell removeFromSuperview];
        footerCell = [[CCExcelRowCell alloc] initWithFrame:CC_rect(0, self.bounds.size.height - bottomRowHeight, self.bounds.size.width, bottomRowHeight)];
        footerCell.frame = CC_rect(0, self.bounds.size.height - bottomRowHeight, self.bounds.size.width, bottomRowHeight);

        // 给 footer 增加阴影
        footerShadowImageView = [[UIImageView alloc] initWithFrame:CC_rect(-15, -10, footerCell.bounds.size.width + 30, footerCell.bounds.size.height - 10)];
        footerShadowImageView.hidden = YES;
        footerShadowImageView.image = [[CCHelper imageWithName:@"CC_back_blur"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
        [footerCell.contentView insertSubview:footerShadowImageView atIndex:0];

        footerCell.delegate = self;
        footerCell.lockScrollView.backgroundColor = CC_ColorWhite;
        footerCell.contentScrollView.backgroundColor = CC_ColorWhite;
        footerCell.farrightLockScrollView.backgroundColor = CC_ColorWhite;

        if ([self.delegate respondsToSelector:@selector(excelView:bottomLineColorAtRow:)]) {
            UIColor *c = [self.delegate excelView:self bottomLineColorAtRow:footRow];
            if (c) {
                footerCell.line.backgroundColor = c;
            }
        }
        [self addSubview:footerCell];
        [self reloadFooterCell:footRow];
    }

    [table reloadData];

    [self handleTopView];
    [self handleTopViewFrame];
    [self handleHeaderCellFrame];
}

- (void)reloadFooterCell:(NSInteger)footRow {
    /// headerCell 和 footerCell 不会进入 tableView 的重用机制，所以这里需要手动触发重用
    [footerCell prepareForReuse];
    [self resetRowCell:footerCell atRow:footRow];
}

- (void)reloadHeaderCell {
    /// headerCell 和 footerCell 不会进入 tableView 的重用机制，所以这里需要手动触发重用
    [headerCell prepareForReuse];
    [self resetRowCell:headerCell atRow:0];
}

- (void)resetAllColumnsWidth
{
    [self resetAllColumnsWidthFromIndex:0];
}

- (void)resetAllColumnsWidthFromIndex:(NSInteger)reloadColumnIndex
{
    for (NSInteger i = reloadColumnIndex; i < [self.delegate numberOfColumnsInExcelView:self]; i++) {
//        [self resetColumnsWidthFromIndex:i];

        CGFloat columnWidth = [self.delegate excelView:self widthAtColumn:i];
        CCExcelCell *tempHeaderCell = [headerCell excelCellAtColumn:i];
        tempHeaderCell.width = columnWidth;
//        [headerCell resetSubCellsOffset];
        if (showFooter) {
            CCExcelCell *tempFooterCell = [footerCell excelCellAtColumn:i];
            tempFooterCell.width = columnWidth;
//            [footerCell resetSubCellsOffset];
        }
        for (CCExcelRowCell *cell in [table visibleCells]) {
            CCExcelCell *tempCell = [cell excelCellAtColumn:i];
            tempCell.width = columnWidth;
//            [cell resetSubCellsOffset];
        }
    }
    [headerCell setNeedsLayout];
    if (showFooter) {
        [footerCell setNeedsLayout];
    }
    for (CCExcelRowCell *cell in [table visibleCells]) {
        [cell setNeedsLayout];
    }
}

- (void)resetColumnsWidthFromIndex:(NSInteger)reloadColumnIndex
{
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

- (void)resetLeftColumnsWithXOffset:(CGFloat)xoffset fromIndex:(NSInteger)index
{
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
    if (showFooter) {
        footerCell.contentScrollView.frame = scrollFrame;
    }
    for (CCExcelRowCell *cell in [table visibleCells]) {
        cell.contentScrollView.frame = scrollFrame;
    }
}

- (void)resetRightCoumnsWithXOffset:(CGFloat)xoffset fromIndex:(NSInteger)index
{
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

- (void)resetScrollColumnsWithXOffset:(CGFloat)xoffset fromIndex:(NSInteger)index
{
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

- (void)showTopView
{
    [table setContentOffset:CC_point(0, -table.contentInset.top) animated:YES];
}

- (void)hideTopView
{
    [table setContentOffset:CGPointZero animated:YES];
}

- (void)handleTopView
{
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
            topView.frame = CC_rect(0, 0, self.bounds.size.width, height);
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

- (void)handleTopViewFrame
{
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

- (void)handleHeaderCellFrame
{
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
    return [self dequeueReusableCellWithIdentifier:cellIdentifier withRowCell:nil withMatrix:nil];
}
- (CCExcelCell *)dequeueReusableCellWithIdentifier:(NSString *)cellIdentifier withRowCell:(CCExcelRowCell *)rowCell withMatrix:(CCMatrix *)matrix {
    CCExcelCell *reusableCell = nil;
    // 优先从本 cell 中寻找
    if (rowCell && matrix) {
        CCExcelCellPosition position;
        
        if (matrix.column < lockColumnNum) {
//            reusableCell = rowCell.lockCells[matrix.column];
            position = CCExcelCellPositionLock;
        } else if (matrix.column < columnNum - farrightLockColumnNum) {
//            reusableCell = rowCell.scrollCells[matrix.column - rowCell.lockCells.count];
            position = CCExcelCellPositionContent;
        } else if (matrix.column < columnNum) {
//            reusableCell = rowCell.farrightLockCells[matrix.column - rowCell.lockCells.count - rowCell.scrollCells.count];
            position = CCExcelCellPositionFarrightLock;
        }
        reusableCell = [rowCell dequeueReusableCellWithIdentifier:cellIdentifier withPosition:position];
//        if (![reusableCell.reuseIdentifier isEqualToString:cellIdentifier]) {
//            [reusableCell removeFromSuperview];
//            reusableCell = nil;
//        }
        if (reusableCell) {
            return reusableCell;
        }
    }
    NSMutableSet *set = [reusableCells objectForKey:cellIdentifier];
    if ([set count] == 0) {
        return nil;
    }
    reusableCell = [set anyObject];
    [set removeObject:reusableCell];
    reusableCell.hidden = NO;
    return reusableCell;
}

- (void)reuseCell:(CCExcelCell *)cell
{
    [cell removeFromSuperview];
    NSString *identifer = cell.reuseIdentifier;
    if (!identifer) {
        return;
    }
    NSMutableSet *set = [reusableCells objectForKey:identifer];
    if (!set) {
        set = [NSMutableSet set];
        [reusableCells setObject:set forKey:identifer];
    }
    if (![set containsObject:cell]) {
        [set addObject:cell];
    }
}

- (CCExcelRowCell *)contenViewAtRow:(NSInteger)row
{
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

- (NSArray *)visiableRows
{
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

- (void)setHighlight:(BOOL)highlight atRow:(NSInteger)row
{
    if (row > 0 && ![self isBottomRow:row]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:0];
        CCExcelRowCell *cell = [table cellForRowAtIndexPath:indexPath];
        cell.contentView.backgroundColor = highlight ? CC_RGBA(240, 240, 240, 1) : CC_ColorClear;
        CCExcelCell *lockCell = [cell excelCellAtColumn:0];
        [lockCell setSwitchOn:highlight];
    }
}

- (CCExcelCell *)cellAtMatrix:(CCMatrix *)matrix
{
    if (matrix == nil) {
        return nil;
    }
    if (matrix.row < 0 || matrix.column < 0) {
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

- (CCMatrix *)matrixOfCell:(CCExcelCell *)cell
{
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

- (BOOL)isBottomRow:(NSInteger)row
{
    if (!showFooter) {
        return NO;
    }
    return row == [self.delegate numberOfRowsInExcelView:self] + 1;
}

#pragma mark- UITableViewDelegate & UITableViewDataSource
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
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
    if (scrollView.superview && scrollView.panGestureRecognizer) {
        CGPoint point =  [scrollView.panGestureRecognizer translationInView:scrollView.superview];
        if ( point.y < 0 ) {
            [self loadNextPage];
        }
    } else {
        [self loadNextPage];
//        if (!scrollView.decelerating) {
//            [self loadNextPage];
//        }
    }
    // footer 的阴影控制
    footerShadowImageView.hidden = CCCGFloatLessThanOrEqualToFloat(scrollView.contentSize.height + scrollView.contentInset.top, scrollView.size.height) || CCCGFloatLessThanOrEqualToFloat(scrollView.contentSize.height, scrollView.contentOffset.y + scrollView.size.height);
}

- (void)loadNextPage
{
    static BOOL canLoad = YES;
    if (canLoad && !self.loading && table.contentSize.height - table.contentOffset.y - table.height <= excelViewLoadMoreOffset) {
        BOOL shouldLoadMore = NO;
        if ([self.delegate respondsToSelector:@selector(shouldLoadMore:)]) {
            shouldLoadMore = [self.delegate shouldLoadMore:self];
        }
        if (shouldLoadMore) {
            if ([self.delegate respondsToSelector:@selector(loadNextPage:)]) {
                [self.delegate loadNextPage:self];
            }
        }
        canLoad = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            canLoad = YES;
        });
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    dragging = YES;
    currentOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(excelViewDidEndScroll:)]) {
        [self.delegate excelViewDidEndScroll:self];

    }
//    [self loadNextPage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(excelViewDidEndScroll:)]) {
        [self.delegate excelViewDidEndScroll:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    dragging = NO;
    if (!decelerate) {
        if ([self.delegate respondsToSelector:@selector(excelViewDidEndScroll:)]) {
            [self.delegate excelViewDidEndScroll:self];
        }
//        [self loadNextPage];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.delegate numberOfRowsInExcelView:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCExcelRowCell *cell = [tableView dequeueReusableCellWithIdentifier:cc_reuseIdentifier];
    if (cell == nil) {
        cell = [[CCExcelRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cc_reuseIdentifier];
        cell.delegate = self;
    }
    [self resetRowCell:cell atRow:indexPath.row+1];

    if ([self.delegate respondsToSelector:@selector(excelView:bottomLineColorAtRow:)]) {
        cell.line.backgroundColor = [self.delegate excelView:self bottomLineColorAtRow:indexPath.row+1];
    }

    UIColor *color = CC_ColorClear;
    if ([self.delegate respondsToSelector:@selector(excelView:backgroundColorAtRow:)]) {
        color = [self.delegate excelView:self backgroundColorAtRow:indexPath.row + 1];
        if (color == nil) {
            color = CC_ColorClear;
        }
    }
    BOOL highlight = NO;
    if ([self.delegate respondsToSelector:@selector(excelView:shouldHighlightAtRow:)]) {
        highlight = [self.delegate excelView:self shouldHighlightAtRow:indexPath.row + 1];
        CCExcelCell *lockCell = [cell excelCellAtColumn:0];
        [lockCell setSwitchOn:highlight];
    }
    if (highlight) {
        color = CC_RGBA(240, 240, 240, 1);
    }
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(excelView:rowCell:cellAtMatrix:)]) {
        return;
    }
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
    [rowCell removeAllItems];
    [rowCell clearReuseCell];
    [rowCell setLockItems:nil scrollItems:nil rightLockItems:nil];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark-
- (void)resetRowCell:(CCExcelRowCell*)cell atRow:(NSInteger)row
{
    NSMutableArray *lockExcelCells = [NSMutableArray array];
    NSMutableArray *scrollCells = [NSMutableArray array];
    NSMutableArray *rightLockExcelCells = [NSMutableArray array];
    for (int i = 0; i < columnNum; i++) {
        CCExcelCell *excelCell;
        if ([self.delegate respondsToSelector:@selector(excelView:rowCell:cellAtMatrix:)]) {
            excelCell = [self.delegate excelView:self rowCell:cell cellAtMatrix:[CCMatrix matrixWithColumn:i row:row]];
        } else {
            [cell removeAllItems];
            excelCell = [self.delegate excelView:self cellAtMatrix:[CCMatrix matrixWithColumn:i row:row]];
        }
        CGFloat excelCellWidth = [self.delegate excelView:self widthAtColumn:i];
        CGFloat height = rowHeight;
        if (row == 0) {
            height = topRowHeight;
        }
        if ([self isBottomRow:row]) {
            height = bottomRowHeight;
        }
        excelCell.frame = CC_rectZP(excelCellWidth, height);
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
    if (footerCell == cell) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->footerShadowImageView.hidden = CCCGFloatLessThanOrEqualToFloat(self.table.contentSize.height + self.table.contentInset.top, self.table.size.height) || CCCGFloatLessThanOrEqualToFloat(self.table.contentSize.height, self.table.contentOffset.y + self.table.size.height);
        });
    }
}

#pragma mark- CCExcelRowCellDelegate
- (void)excelRowCell:(CCExcelRowCell *)cell didScrollViewAtOffset:(CGPoint)offset
{
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

- (void)excelRowCellDidBeginDragging:(CCExcelRowCell *)cell atOffest:(CGPoint)offset
{
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

- (BOOL)excelRowCellShouldControlSrcoll:(CCExcelRowCell *)cell
{
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

- (void)resetControlScroll
{
    for (CCExcelRowCell *c in table.visibleCells) {
        c.shouldSendScrollNotification = NO;
    }
    headerCell.shouldSendScrollNotification = NO;
    footerCell.shouldSendScrollNotification = NO;
}

- (void)resetAllRowCellsContentOffset:(CCExcelRowCell *)cell
{
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

- (void)excelRowCell:(CCExcelRowCell *)cell didSelectAtColumn:(NSInteger)column
{
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

+ (CCMatrix *)matrixWithColumn:(NSInteger)column row:(NSInteger)row
{
    CCMatrix *matrix = [[CCMatrix alloc] init];
    matrix.column = column;
    matrix.row = row;
    return matrix;
}

- (NSString *)genIndexString
{
    NSString *str = [NSString stringWithFormat:@"%ld", self.row];
    if (self.row < 10) {
        str = [NSString stringWithFormat:@"0%ld", self.row];
    }
    return str;
}

- (BOOL)isHeader
{
    return self.row == 0;
}

- (BOOL)isLeader
{
    return self.column == 0;
}

- (BOOL)isHeaderAndLeader
{
    return self.row == 0 && self.column == 0;
}

- (BOOL)notHeaderLeader
{
    return self.row > 0 && self.column > 0;
}

- (NSString *)description
{
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


