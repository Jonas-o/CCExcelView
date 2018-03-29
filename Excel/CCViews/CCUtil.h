//
//  CCUtil.h
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#ifndef CCUtil_h
#define CCUtil_h

//Color
#define CC_RGB(r,g,b)      [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define CC_RGBA(r,g,b,a)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define CC_ColorClear    [UIColor clearColor]
#define CC_ColorWhite    [UIColor whiteColor]

#define CC_ColorRed      CC_RGBA(228, 102, 102, 1)

//Font
#define CC_sysFont(fontSize)       [UIFont systemFontOfSize:fontSize]
#define CC_boldSysFont(fontSize)   [UIFont boldSystemFontOfSize:fontSize]
#define CC_defaultFont       [UIFont systemFontOfSize:16]
#define CC_defaultBoldFont       [UIFont boldSystemFontOfSize:16]

//Rect, Point, Size, Insets
#define CC_rect(x,y,w,h)   CGRectMake(x,y,w,h)
#define CC_rectZP(w,h)     CGRectMake(0,0,w,h)
#define CC_rectFromSize(x,y,size) CGRectMake(x,y,size.width, size.height)
#define CC_rectZPFromSize(size) CGRectMake(0,0,size.width, size.height)

#define CC_point(x,y)      CGPointMake(x,y)
#define CC_size(w,h)       CGSizeMake(w,h)

#define CC_ScreenWidth    [UIScreen mainScreen].bounds.size.width
#define CC_ScreenHeight   [UIScreen mainScreen].bounds.size.height

// Decimal
#define CC_decimalWithString(s) (s.length > 0 ? [NSDecimalNumber decimalNumberWithString:s] : [NSDecimalNumber zero])
#define CC_isNegativeDecimal(d) ([d compare:[NSDecimalNumber zero]] == NSOrderedAscending)

#endif /* CCUtil_h */
