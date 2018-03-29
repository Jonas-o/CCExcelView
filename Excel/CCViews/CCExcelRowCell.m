//
//  CCExcelRowCell.m
//  CCExcelView
//
//  Created by luo on 2017/5/5.
//  Copyright © 2017年 CCExcelView. All rights reserved.
//

#import "CCExcelRowCell.h"
#import "CCExcelCell.h"
#import "CCHelper.h"

@interface CCExcelRowCell() <UIScrollViewDelegate>

@end

@implementation CCExcelRowCell
@synthesize shouldSendScrollNotification, lockCells, scrollCells, line, farrightLockCells;
@synthesize lockScrollView, contentScrollView, farrightLockScrollView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        lockScrollView = [UIScrollView new];
        lockScrollView.showsVerticalScrollIndicator = NO;
        lockScrollView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:lockScrollView];
        
        contentScrollView = [UIScrollView new];
        contentScrollView.delegate = self;
        contentScrollView.alwaysBounceHorizontal = YES;
        contentScrollView.showsVerticalScrollIndicator = NO;
        contentScrollView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:contentScrollView];
        
        farrightLockScrollView = [UIScrollView new];
        farrightLockScrollView.showsVerticalScrollIndicator = NO;
        farrightLockScrollView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:farrightLockScrollView];
        
        line = [UIView new];
        line.userInteractionEnabled = NO;
        line.backgroundColor = CC_RGB(240, 240, 240);
        [self.contentView addSubview:line];
        
        shouldSendScrollNotification = NO;
        UIView *selectedView = [UIView new];
        selectedView.backgroundColor = kExcelCellSelectedColor;
        self.selectedBackgroundView = selectedView;
    }
    return self;
}

- (void)resetCellContentViewSize
{
    lockScrollView.frame = CC_rectZP([self lockScrollViewContentWidth], self.bounds.size.height);
    lockScrollView.contentSize = lockScrollView.bounds.size;
    
    CGFloat rightWidth = [self rightScrollViewContentWidth];
    farrightLockScrollView.frame = CC_rect(self.bounds.size.width-rightWidth, 0, rightWidth, self.bounds.size.height);
    farrightLockScrollView.contentSize = farrightLockScrollView.bounds.size;
    
    CGFloat contentWidth = [self contentScrollViewContentWidth];
    contentScrollView.frame = CC_rect(lockScrollView.bounds.size.width, 0, self.bounds.size.width - lockScrollView.frame.size.width - farrightLockScrollView.bounds.size.width, self.bounds.size.height);
    contentScrollView.contentSize = CC_size(MAX(contentScrollView.bounds.size.width, contentWidth), self.bounds.size.height);
}

- (CGFloat)lockScrollViewContentWidth
{
    CGFloat width = 0;
    for (UIView *v in lockScrollView.subviews) {
        width += v.bounds.size.width;
    }
    return width;
}

- (CGFloat)contentScrollViewContentWidth
{
    CGFloat width = 0;
    for (UIView *v in contentScrollView.subviews) {
        width += v.bounds.size.width;
    }
    return width;
}

- (CGFloat)rightScrollViewContentWidth
{
    CGFloat width = 0;
    for (UIView *v in farrightLockScrollView.subviews) {
        width += v.bounds.size.width;
    }
    return width;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resetCellContentViewSize];
    line.frame = CC_rect(0, self.bounds.size.height - 1, self.bounds.size.width, 1);
}

- (void)controlScrollOffset:(CGPoint)offset
{
    shouldSendScrollNotification = NO;
    __weak typeof(self) weak_self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weak_self) {
            __strong typeof(self) strong_self = weak_self;
            [strong_self -> contentScrollView setContentOffset:offset animated:NO];
        }
    });
}

- (void)setLockItems:(NSArray *)lockItems scrollItems:(NSArray *)scrollItems rightLockItems:(NSArray *)rightLockItems
{
    lockCells = lockItems;
    scrollCells = scrollItems;
    farrightLockCells = rightLockItems;
    CGFloat currentOffsetX = 0;
    for (int i = 0; i < lockItems.count; i++) {
        CCExcelCell *lockItem = lockItems[i];
        lockItem.control.tag = 100 + i;
        [lockItem.control removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [lockItem.control addTarget:self action:@selector(cellControlAction:) forControlEvents:UIControlEventTouchUpInside];
        [lockItem.control addTarget:self action:@selector(cellControlTouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [lockItem.control addTarget:self action:@selector(cellControlTouchCancelAction:) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchDragEnter|UIControlEventTouchDragOutside|UIControlEventTouchCancel];
        lockItem.frame = CC_rectFromSize(currentOffsetX, 0, lockItem.bounds.size);
        currentOffsetX += lockItem.bounds.size.width;
        [lockScrollView addSubview:lockItem];
    }
    contentScrollView.frame = CC_rect(currentOffsetX, 0, 0, 0);
    currentOffsetX = 0;
    for (int i = 0; i < scrollItems.count; i++) {
        CCExcelCell *scrollItem = scrollItems[i];
        scrollItem.control.tag = 100 + i + lockItems.count;
        [scrollItem.control removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [scrollItem.control addTarget:self action:@selector(cellControlAction:) forControlEvents:UIControlEventTouchUpInside];
        [scrollItem.control addTarget:self action:@selector(cellControlTouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [scrollItem.control addTarget:self action:@selector(cellControlTouchCancelAction:) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchDragEnter|UIControlEventTouchDragOutside|UIControlEventTouchCancel];
        scrollItem.frame = CC_rectFromSize(currentOffsetX, 0, scrollItem.bounds.size);
        [contentScrollView addSubview:scrollItem];
        currentOffsetX += scrollItem.bounds.size.width;
    }
    contentScrollView.contentSize = CC_size(currentOffsetX, 0);
    
    currentOffsetX = 0;
    for (int i = 0; i < rightLockItems.count; i++) {
        CCExcelCell *lockItem = rightLockItems[i];
        [lockItem.control removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        lockItem.control.tag = 100 + i + lockItems.count + scrollItems.count;
        [lockItem.control addTarget:self action:@selector(cellControlAction:) forControlEvents:UIControlEventTouchUpInside];
        [lockItem.control addTarget:self action:@selector(cellControlTouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [lockItem.control addTarget:self action:@selector(cellControlTouchCancelAction:) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchDragEnter|UIControlEventTouchDragOutside|UIControlEventTouchCancel];
        lockItem.frame = CC_rectFromSize(currentOffsetX, 0, lockItem.bounds.size);
        currentOffsetX += lockItem.bounds.size.width;
        [farrightLockScrollView addSubview:lockItem];
    }
    farrightLockScrollView.frame = CC_rectZP(currentOffsetX, 0);
    
    [self.contentView bringSubviewToFront:line];
    [self setNeedsLayout];
}

- (CCExcelCell *)excelCellAtColumn:(NSInteger)column
{
    if (column < self.lockCells.count) {
        return self.lockCells[column];
    } else if (column < (self.lockCells.count + self.scrollCells.count)) {
        return self.scrollCells[column - self.lockCells.count];
    } else if (column >= (self.lockCells.count + self.scrollCells.count)) {
        return self.farrightLockCells[column - self.lockCells.count - self.scrollCells.count];
    }
    return nil;
}

- (void)cellControlAction:(UIControl *)control
{
    control.userInteractionEnabled = NO;
    NSInteger tag = control.tag;
    NSInteger index = tag - 100;
    if ([self.delegate respondsToSelector:@selector(excelRowCell:didSelectAtColumn:)]) {
        [self.delegate excelRowCell:self didSelectAtColumn:index];
    }
    [self highlightCell:control.superview highlightStyle:CCExcelViewCellSelectionStyleNone];
    control.userInteractionEnabled = YES;
}

- (void)cellControlTouchDownAction:(UIControl *)control {
    CCExcelViewCellSelectionStyle highlightStyle = CCExcelViewCellSelectionStyleNone;
    if ([self.delegate respondsToSelector:@selector(excelRowCell:highlightStyleAtColumn:)]) {
        NSInteger tag = control.tag;
        NSInteger index = tag - 100;
        highlightStyle = [self.delegate excelRowCell:self highlightStyleAtColumn:index];
    }
    if (highlightStyle) {
        [self highlightCell:control.superview highlightStyle:highlightStyle];
    }
}

- (void)cellControlTouchCancelAction:(UIControl *)control {
    [self highlightCell:control.superview highlightStyle:CCExcelViewCellSelectionStyleNone];
}

- (void)highlightCell:(UIView *)cell highlightStyle:(CCExcelViewCellSelectionStyle)style {
    if ([cell isKindOfClass:[CCExcelCell class]]) {
        switch (style) {
            case CCExcelViewCellSelectionStyleRow:
                [self setHighlighted:YES animated:YES];
                break;
            case CCExcelViewCellSelectionStyleCell:
                [(CCExcelCell *)cell setHighlighted:YES animated:YES];
                break;
                
            default:
                [(CCExcelCell *)cell setHighlighted:NO animated:YES];
                [self setHighlighted:NO animated:YES];
                break;
        }
        
    }
}

#pragma mark- UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.delegate excelRowCellDidBeginDragging:self atOffest:scrollView.contentOffset];
    if (!self.shouldSendScrollNotification) {
        [self.delegate resetControlScroll];
    }
    self.shouldSendScrollNotification = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.shouldSendScrollNotification && !decelerate) {
        [self.delegate resetControlScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.shouldSendScrollNotification) {
        [self.delegate resetControlScroll];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (!self.shouldSendScrollNotification) {
        [self.delegate resetControlScroll];
    }
    [self.delegate resetAllRowCellsContentOffset:self];
    self.shouldSendScrollNotification = YES;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (shouldSendScrollNotification) {
        if ([self.delegate respondsToSelector:@selector(excelRowCell:didScrollViewAtOffset:)]) {
            [self.delegate excelRowCell:self didScrollViewAtOffset:scrollView.contentOffset];
        }
    }
    
}

@end
