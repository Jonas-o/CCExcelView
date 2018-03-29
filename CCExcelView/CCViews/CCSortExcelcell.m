//
//  CCSortExcelcell.m
//  CCExcelView
//
//  Created by luo on 2017/9/19.
//  Copyright © 2017年 CCExcelView. All rights reserved.
//

#import "CCSortExcelcell.h"
#import "CCHelper.h"

@implementation CCSortExcelcell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        UIImage *sortImage = [CCHelper imageWithName:@"CC_order_arrow"];
        self.sortImageView = [[UIImageView alloc] initWithImage:sortImage];
        [self.sortImageView sizeToFit];
        [self addSubview:self.sortImageView];
    }
    return self;
}

- (void)setSortType:(CCSortType)sortType {
    _sortType = sortType;
    if (sortType == CCSortTypeAscending) {
        self.sortImageView.image = [CCHelper imageWithName:@"CC_order_arrow_asc"];
    } else if (sortType == CCSortTypeDescending) {
        self.sortImageView.image = [CCHelper imageWithName:@"CC_order_arrow_desc"];
    } else {
        self.sortImageView.image = nil;//[CCHelper imageWithName:@"CC_order_arrow"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.sortImageView.centerY = self.height/2;
    self.sortImageView.right = self.width - 5;
}

@end
