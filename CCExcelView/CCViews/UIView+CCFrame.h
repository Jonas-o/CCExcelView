//
//  UIView+CCFrame.h
//  CCExcelView
//
//  Created by luo on 2018/3/29.
//  Copyright © 2018年 luo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CCFrame)

@property(nonatomic,readwrite) CGFloat x,y,width,height;

@property (nonatomic,readwrite) CGPoint origin;
@property (nonatomic,readwrite) CGSize size;

@property (nonatomic, readwrite) CGFloat centerX;
@property (nonatomic, readwrite) CGFloat centerY;

@property CGFloat bottom;
@property CGFloat right;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;
@property (readonly) CGPoint topLeft;

@end
