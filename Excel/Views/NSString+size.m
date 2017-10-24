//
//  NSString+size.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "NSString+size.h"
#import "CCUtil.h"

@implementation NSString (size)

-(CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize {
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

- (CGFloat)heightWithFont:(UIFont *)font width:(CGFloat)width {
    CGSize maxSize = size(width, MAXFLOAT);
    return [self sizeWithFont:font maxSize:maxSize].height;
}

- (CGFloat)widthWithFont:(UIFont *)font height:(CGFloat)height {
    CGSize maxSize = size(MAXFLOAT, height);
    return [self sizeWithFont:font maxSize:maxSize].width;
}

- (NSInteger)getDecimalPlace {
    if (![self containsString:@"."]) {
        return 0;
    }
    NSArray *ar = [self componentsSeparatedByString:@"."];
    if (ar.count < 2) {
        return 0;
    }
    NSString *sub = ar[1];
    return sub.length;
}

@end
