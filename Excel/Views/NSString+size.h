//
//  NSString+size.h
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (size)

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

- (CGFloat)heightWithFont:(UIFont *)font width:(CGFloat)width;

- (CGFloat)widthWithFont:(UIFont *)font height:(CGFloat)height;

- (NSInteger)getDecimalPlace;

@end
