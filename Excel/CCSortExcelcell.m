//
//  CCSortExcelcell.m
//  ecloud-ios
//
//  Created by luo on 2017/9/19.
//  Copyright © 2017年 ecloud. All rights reserved.
//

#import "CCSortExcelcell.h"
#import "CCUtil.h"

@implementation CCSortExcelcell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.sortImageView = [[UIImageView alloc] initWithImage:CCImage(@"order_arrow")];
        [self.sortImageView sizeToFit];
        [self addSubview:self.sortImageView];
    }
    return self;
}

- (void)setSortType:(CCSortType)sortType {
    _sortType = sortType;
    if (sortType == CCSortTypeAscending) {
        self.sortImageView.image = CCImage(@"order_arrow_asc");
    } else if (sortType == CCSortTypeDescending) {
        self.sortImageView.image = CCImage(@"order_arrow_desc");
    } else {
        self.sortImageView.image = CCImage(@"order_arrow");
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGPoint center = self.sortImageView.center;
    center.y = self.frame.size.height/2;
    self.sortImageView.center = center;
    CGFloat delta = self.frame.size.width - 5 - (self.sortImageView.frame.origin.x + self.sortImageView.frame.size.width);
    CGRect newframe = self.sortImageView.frame;
    newframe.origin.x += delta;
    self.sortImageView.frame = newframe;
}

@end
