//
//  CCExcelRowCell.h
//  CCExcelView
//
//  Created by luo on 2017/5/5.
//  Copyright © 2017年 CCExcelView. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CCExcelViewCellSelectionStyleNone,
    CCExcelViewCellSelectionStyleRow,
    CCExcelViewCellSelectionStyleCell,
} CCExcelViewCellSelectionStyle;

@class CCExcelCell;

@protocol CCExcelRowCellDelegate;

@interface CCExcelRowCell : UITableViewCell

@property (nonatomic, weak) id<CCExcelRowCellDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *line;

@property (nonatomic, assign) BOOL shouldSendScrollNotification;

@property (nonatomic, strong, readonly) NSArray *lockCells;

@property (nonatomic, strong, readonly) NSArray *scrollCells;

@property (nonatomic, strong, readonly) NSArray *farrightLockCells;

@property (nonatomic, strong, readonly) UIScrollView *lockScrollView;
@property (nonatomic, strong, readonly) UIScrollView *contentScrollView;
@property (nonatomic, strong, readonly) UIScrollView *farrightLockScrollView;

- (void)resetCellContentViewSize;

- (void)controlScrollOffset:(CGPoint)offset;

- (void)setLockItems:(NSArray *)lockItems scrollItems:(NSArray *)scrollItems rightLockItems:(NSArray *)rightLockItems;

- (CCExcelCell *)excelCellAtColumn:(NSInteger)column;

@end

@protocol CCExcelRowCellDelegate <NSObject>

- (void)excelRowCell:(CCExcelRowCell *)cell didScrollViewAtOffset:(CGPoint)offset;

- (void)excelRowCellDidBeginDragging:(CCExcelRowCell *)cell atOffest:(CGPoint)offset;

- (void)excelRowCell:(CCExcelRowCell *)cell didSelectAtColumn:(NSInteger)column;

- (CCExcelViewCellSelectionStyle)excelRowCell:(CCExcelRowCell *)cell highlightStyleAtColumn:(NSInteger)column;

- (BOOL)excelRowCellShouldControlSrcoll:(CCExcelRowCell *)cell;

- (void)resetControlScroll;

- (void)resetAllRowCellsContentOffset:(CCExcelRowCell *)cell;

@end
