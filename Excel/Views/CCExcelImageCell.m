//
//  CCExcelImageCell.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "CCExcelImageCell.h"
#import "CCUtil.h"

@implementation CCExcelImageCell
@synthesize imageView;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    imageView.frame = rect(self.imageInsets.left, self.imageInsets.top, (self.bounds.size.width - self.imageInsets.left-self.imageInsets.right), (self.bounds.size.height-self.imageInsets.top-self.imageInsets.bottom));
}

@end
