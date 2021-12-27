//
//  CCExcelImageCell.m
//  CCExcelView
//
//  Created by luo on 2017/7/19.
//  Copyright © 2017年 CCExcelView. All rights reserved.
//

#import "CCExcelImageCell.h"
#import "CCHelper.h"

@implementation CCExcelImageCell
@synthesize imageView;

- (void)didInitialize {
    [super didInitialize];

    imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    imageView.frame = CC_rect(self.imageInsets.left, self.imageInsets.top, (self.bounds.size.width - self.imageInsets.left-self.imageInsets.right), (self.bounds.size.height-self.imageInsets.top-self.imageInsets.bottom));
}

@end
