//
//  CCCustomControlCell.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "CCCustomControlCell.h"
#import "CCUtil.h"

@implementation CCCustomControlCell
@synthesize detailLabel, imageView;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier style:CCExcelCellStyleHeader]) {
        detailLabel = [UILabel new];
        detailLabel.font = sysFont(12);
        detailLabel.textColor = RGB(162, 162, 162);
        detailLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:detailLabel];
        
        imageView = [UIImageView new];
        imageView.image = CCImage(@"edit_arrow");
        [self addSubview:imageView];
        
        [self bringSubviewToFront:self.control];
    }
    return self;
}

- (void)updateDetail:(NSString *)detail {
    detailLabel.text = detail;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = rect(kExcelCellLabelMarginX, 0, self.bounds.size.width - kExcelCellLabelMarginX * 2, self.bounds.size.height);
    frame.size.height = self.bounds.size.height / 2;
    frame.origin.y = 5;
    self.label.frame = frame;
    frame.origin.y = self.bounds.size.height/2;
    detailLabel.frame = frame;
    
    imageView.frame = rect(self.bounds.size.width-16-11, (self.bounds.size.height-10-16)/2, 16, 16);
    
    self.label.textAlignment = NSTextAlignmentRight;
    self.label.frame = rect(kExcelCellLabelMarginX, 0, self.bounds.size.width - 10 - 16-11, self.bounds.size.height-10);
}

@end
