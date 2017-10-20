//
//  CCExcelAcccssoryCell.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "CCExcelAcccssoryCell.h"
#import "CCTextButton.h"
#import "CCUtil.h"

@implementation CCExcelAcccssoryCell
@synthesize rightButton;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier rightText:(NSString *)rightText {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        rightButton = [[CCTextButton alloc] initWithText:rightText font:defaultFont];
        [self addSubview:rightButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = rect(kExcelCellLabelMarginX, 0, self.bounds.size.width - kExcelCellLabelMarginX * 2 - rightButton.bounds.size.width, self.bounds.size.height);
    rightButton.frame = rectFromSize(self.bounds.size.width-rightButton.bounds.size.width, (self.bounds.size.height-rightButton.bounds.size.height)/2, rightButton.frame.size);
}

@end
