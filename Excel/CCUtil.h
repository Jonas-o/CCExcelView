//
//  CCUtil.h
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//
#import "UIImage+Vector.h"
#import "NSString+size.h"
#import "CCTextField.h"

#ifndef CCUtil_h
#define CCUtil_h

//Color
#define RGB(r,g,b)      [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r,g,b,a)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define ColorClear    [UIColor clearColor]
#define ColorWhite    [UIColor whiteColor]

#define ColorRed      RGBA(228, 102, 102, 1)
#define ColorBack     RGBA(136, 136, 136, 1)
#define ColorGreen    RGBA(33, 150, 107, 1)
#define ColorLightGreen    RGBA(64, 177, 136, 1)

//Font
#define sysFont(fontSize)       [UIFont systemFontOfSize:fontSize]
#define boldSysFont(fontSize)   [UIFont boldSystemFontOfSize:fontSize]
#define textFont(name,fontSize) [UIFont fontWithName:name size:fontSize]
#define defaultFont       [UIFont systemFontOfSize:16]
#define defaultBoldFont       [UIFont boldSystemFontOfSize:16]

//Rect, Point, Size, Insets
#define rect(x,y,w,h)   CGRectMake(x,y,w,h)
#define rectZP(w,h)     CGRectMake(0,0,w,h)
#define rectFromSize(x,y,size) CGRectMake(x,y,size.width, size.height)
#define rectZPFromSize(size) CGRectMake(0,0,size.width, size.height)
#define rightXFromRect(frame)    (frame.origin.x+frame.size.width)
#define bottomYFromRect(frame)   (frame.origin.y+frame.size.height)
#define centerFromRect(frame)   CGPointMake((frame.origin.x+frame.size.width)/2, (frame.origin.y+frame.size.height)/2)

#define point(x,y)      CGPointMake(x,y)

#define size(w,h)       CGSizeMake(w,h)

#define insets(t,l,b,r) UIEdgeInsetsMake(t,l,b,r)
#define insetsTop(t)    UIEdgeInsetsMake(t,0,0,0)
#define insetsBottom(b)    UIEdgeInsetsMake(0,0,b,0)
#define insetsLeft(l)    UIEdgeInsetsMake(0,l,0,0)
#define insetsRight(r)    UIEdgeInsetsMake(0,0,0,r)

//Image
//#define CCImage(image)  [UIImage imageNamed:image
#define CCImage(image) [UIImage vectorImageWithName:image size:CGSizeZero]

#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height

// Decimal
#define decimalWithString(s) (s.length > 0 ? [NSDecimalNumber decimalNumberWithString:s] : [NSDecimalNumber zero])
#define decimalWithInteger(i) [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%ld", i]]
#define decimalOne [NSDecimalNumber one]
#define decimalZero [NSDecimalNumber zero]
#define isDecimalZero(d)     ([d compare:[NSDecimalNumber zero]] == NSOrderedSame)
#define isPositiveDecimal(d) ([d compare:[NSDecimalNumber zero]] == NSOrderedDescending)
#define isNegativeDecimal(d) ([d compare:[NSDecimalNumber zero]] == NSOrderedAscending)
#define isDecimalSame(a,b)   ([a compare:b] == NSOrderedSame)
#define decimalSubtract(a,b) [a decimalNumberBySubtracting:b]
#define decimalAdd(a,b) [a decimalNumberByAdding:b]

#endif /* CCUtil_h */
