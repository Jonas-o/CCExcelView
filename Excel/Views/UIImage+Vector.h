//
//  UIImage+Vector.h
//  CCExcelView
//
//  Created by luo on 2017/10/19.
//  Copyright © 2017年 luo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Vector)

/**
 *  根据名称获取pdf格式的矢量图，返回一个UIImage对象
 *
 *  @param name      矢量图名称
 *  @param size      设置返回图片的大小，如果传CGSizeZero将使用原图大小
 */
+ (UIImage *)vectorImageWithName:(NSString *)name size:(CGSize)size;

/**
 *  根据名称获取pdf格式的矢量图，返回一个UIImage对象
 *
 *  @param name      矢量图名称
 *  @param size      设置返回图片的大小，如果传CGSizeZero将使用原图大小
 *  @param stretch   是否拉伸图片，拉伸图片将忽略原图宽高比
 */
+ (UIImage *)vectorImageWithName:(NSString *)name size:(CGSize)size stretch:(BOOL)stretch;

@end
