//
//  CCExcelDeleteCell.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "CCExcelDeleteCell.h"
#import "CCUtil.h"

@implementation CCExcelDeleteCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier style:CCExcelCellStyleLeader|CCExcelCellStyleSwitch]) {
        self.switchImageView.image = CCImage(@"excel_delete");
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.control.frame = self.switchImageView.frame;
}

@end
