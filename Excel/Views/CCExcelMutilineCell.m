//
//  CCExcelMutilineCell.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "CCExcelMutilineCell.h"
#import "CCUtil.h"
#import "NSString+size.h"

@implementation CCExcelMutilineCell
@synthesize mutilineLabel;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier style:CCExcelCellStyleHeader]) {
        mutilineLabel = [UILabel new];
        mutilineLabel.textAlignment = NSTextAlignmentRight;
        mutilineLabel.font = kExcelCellLabelHeaderFont;
        mutilineLabel.textColor = RGB(102, 102, 102);
        mutilineLabel.numberOfLines = 0;
        [self addSubview:mutilineLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    mutilineLabel.frame = rect(12,0,self.bounds.size.width-24,self.bounds.size.height);
}

+ (CGFloat)cellHeightWithTitle:(NSString *)title {
    CGFloat titleHeight = [title heightWithFont:kExcelCellLabelHeaderFont width:MAXFLOAT];
    return titleHeight;
}

+ (CGFloat)cellWidthWithTitle:(NSString *)title {
    CGFloat width = [title widthWithFont:kExcelCellLabelHeaderFont height:MAXFLOAT];
    return width + 12*2;
}

@end
