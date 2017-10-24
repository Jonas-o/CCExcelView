//
//  UIImage+Vector.m
//  CCExcelView
//
//  Created by luo on 2017/10/19.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "UIImage+Vector.h"

@implementation UIImage (Vector)

+ (UIImage *)vectorImageWithName:(NSString *)name size:(CGSize)size {
    return [self vectorImageWithName:name size:size stretch:NO];
}

+ (UIImage *)vectorImageWithName:(NSString *)name size:(CGSize)size stretch:(BOOL)stretch {
    //图片资源存放路径
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"CCExcelView")];
    NSString *filePath = [bundle pathForResource: @"CCExcelResources" ofType :@"bundle"];
    NSString *pdfPath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",name]];
    if (!pdfPath) return nil;
    return [self vectorImageWithURL:[NSURL fileURLWithPath:pdfPath] size:size stretch:stretch];
}

+ (UIImage *)vectorImageWithURL:(NSURL *)url size:(CGSize)size stretch:(BOOL)stretch {
    
    CGFloat screenScale = UIScreen.mainScreen.scale;
    CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    CGPDFPageRef imagePage = CGPDFDocumentGetPage(pdfRef, 1);
    CGRect pdfRect = CGPDFPageGetBoxRect(imagePage, kCGPDFCropBox);
    // 判断设置的图片大小
    CGSize contextSize = (size.width <= 0 || size.height <= 0) ? pdfRect.size : size;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 contextSize.width * screenScale,
                                                 contextSize.height * screenScale,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGContextScaleCTM(context, screenScale, screenScale);
    
    if (size.width > 0 && size.height > 0) {
        CGFloat widthScale = size.width / pdfRect.size.width;
        CGFloat heightScale = size.height / pdfRect.size.height;
        
        if (!stretch) {
            heightScale = MIN(widthScale, heightScale);
            widthScale = heightScale;
            CGFloat currentRatio = size.width / size.height;
            CGFloat realRatio = pdfRect.size.width / pdfRect.size.height;
            if (currentRatio < realRatio) {
                CGContextTranslateCTM(context, 0, (size.height - size.width / realRatio) / 2);
            } else {
                CGContextTranslateCTM(context, (size.width - size.height * realRatio) / 2, 0);
            }
        }
        CGContextScaleCTM(context, widthScale, heightScale);
        
    } else {
        CGAffineTransform drawingTransform = CGPDFPageGetDrawingTransform(imagePage, kCGPDFCropBox, pdfRect, 0, true);
        CGContextConcatCTM(context, drawingTransform);
    }
    CGContextDrawPDFPage(context, imagePage);
    CGPDFDocumentRelease(pdfRef);
    // 创建 UIImage
    CGImageRef image = CGBitmapContextCreateImage(context);
    UIImage *pdfImage = [[UIImage alloc] initWithCGImage:image scale:screenScale orientation:UIImageOrientationUp];
    // Release
    CGImageRelease(image);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return pdfImage;
}

@end
