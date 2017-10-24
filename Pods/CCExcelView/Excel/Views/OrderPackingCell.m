//
//  OrderPackingCell.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "OrderPackingCell.h"
#import "CCUtil.h"

@implementation OrderPackingCell
@synthesize detailLabel, imageView;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier style:CCExcelCellStyleDefault]) {
        detailLabel = [UILabel new];
        detailLabel.font = sysFont(12);
        detailLabel.textColor = RGB(162, 162, 162);
        detailLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:detailLabel];

        imageView = [UIImageView new];
        imageView.image = CCImage(@"edit_arrow");
        imageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
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
    self.label.textAlignment = NSTextAlignmentRight;
    self.label.frame = rect(0, 0, self.bounds.size.width-16, self.bounds.size.height);

    detailLabel.frame = rect(kExcelCellLabelMarginX, 4, self.bounds.size.width - kExcelCellLabelMarginX * 2, 16);
    imageView.frame = rect(self.bounds.size.width-16, (self.bounds.size.height-16)/2, 16, 16);
}
@end
