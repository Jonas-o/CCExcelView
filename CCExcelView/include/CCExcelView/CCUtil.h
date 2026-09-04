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

#pragma mark - CGFloat
/**
 用于两个 CGFloat 值之间的比较运算，支持 ==、>、<、>=、<= 5种，内部会将浮点数转成整型，从而避免浮点数精度导致的判断错误。

 CCCGFloatEqualToFloatWithPrecision()
 CCCGFloatEqualToFloat()
 CCCGFloatMoreThanFloatWithPrecision()
 CCCGFloatMoreThanFloat()
 CCCGFloatMoreThanOrEqualToFloatWithPrecision()
 CCCGFloatMoreThanOrEqualToFloat()
 CCCGFloatLessThanFloatWithPrecision()
 CCCGFloatLessThanFloat()
 CCCGFloatLessThanOrEqualToFloatWithPrecision()
 CCCGFloatLessThanOrEqualToFloat()

 可通过参数 precision 指定要考虑的小数点后的精度，精度的定义是保证指定的那一位小数点不会因为浮点问题导致计算错误，例如当我们要获取一个 1.0 的浮点数时，有时候会得到 0.99999999，有时候会得到 1.000000001，所以需要对指定的那一位小数点的后一位数进行四舍五入操作。
 @code
 precision = 0，也即对小数点后0+1位四舍五入
 0.999 -> 0.9 -> round(0.9) -> 1
 1.011 -> 1.0 -> round(1.0) -> 1
 1.033 -> 1.0 -> round(1.0) -> 1
 1.099 -> 1.0 -> round(1.0) -> 1
 precision = 1，也即对小数点后1+1位四舍五入
 0.999 -> 9.9 -> round(9.9)   -> 10 -> 1.0
 1.011 -> 10.1 -> round(10.1) -> 10 -> 1.0
 1.033 -> 10.3 -> round(10.3) -> 10 -> 1.0
 1.099 -> 10.9 -> round(10.9) -> 11 -> 1.1
 precision = 2，也即对小数点后2+1位四舍五入
 0.999 -> 99.9 -> round(99.9)   -> 100 -> 1.00
 1.011 -> 101.1 -> round(101.1) -> 101 -> 1.01
 1.033 -> 103.3 -> round(103.3) -> 103 -> 1.03
 1.099 -> 109.9 -> round(109.9) -> 110 -> 1.1
 @endcode
 */
CG_INLINE NSInteger _CCRoundedIntegerFromCGFloat(CGFloat value, NSUInteger precision) {
    return (NSInteger)(round(value * pow(10, precision)));
}
#define _CCCGFloatCalcGenerator(_operatorName, _operator) CG_INLINE BOOL CCCGFloat##_operatorName##FloatWithPrecision(CGFloat value1, CGFloat value2, NSUInteger precision) {\
NSInteger a = _CCRoundedIntegerFromCGFloat(value1, precision);\
NSInteger b = _CCRoundedIntegerFromCGFloat(value2, precision);\
return a _operator b;\
}\
CG_INLINE BOOL CCCGFloat##_operatorName##Float(CGFloat value1, CGFloat value2) {\
return CCCGFloat##_operatorName##FloatWithPrecision(value1, value2, 0);\
}

_CCCGFloatCalcGenerator(EqualTo, ==)
_CCCGFloatCalcGenerator(LessThan, <)
_CCCGFloatCalcGenerator(LessThanOrEqualTo, <=)
_CCCGFloatCalcGenerator(MoreThan, >)
_CCCGFloatCalcGenerator(MoreThanOrEqualTo, >=)

#endif /* CCUtil_h */
