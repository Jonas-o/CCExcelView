//
//  CCExcelDiscountCell.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "CCExcelDiscountCell.h"
#import "CCUtil.h"

@interface CCExcelDiscountCell() <UITextFieldDelegate>

@end

@implementation CCExcelDiscountCell
@synthesize discountField, button;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier style:CCExcelCellStyleHeader]) {
        self.label.font = kExcelCellLabelHeaderFont;
        discountField = [CCTextField new];
        discountField.font = sysFont(12);
        discountField.textColor = RGB(162, 162, 162);
        discountField.delegate = self;
        discountField.text = @"1";
        [self addSubview:discountField];
        
        button = [UIButton new];
        [button setImage:CCImage(@"discount_edit") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        self.control.userInteractionEnabled = NO;
    }
    return self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length == 0) {
        return;
    }
    NSDecimalNumber *number = decimalWithString(textField.text);
    if (number.doubleValue > 1 || number.doubleValue <= 0) {
        textField.text = @"1";
    }
    if (self.inputAction) {
        self.inputAction(number);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([newString containsString:@"-"]) {
        return NO;
    }
    if (newString.length > 0 && ![self isPureDouble:newString]) {
        return NO;
    }
    return YES;
}

- (BOOL)isPureDouble:(NSString*)string {
    NSScanner* scan = [NSScanner scannerWithString:string];
    double val;
    return[scan scanDouble:&val] && [scan isAtEnd];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.editAction) {
        self.editAction(self);
    }
}

- (void)buttonAction:(id)sender {
    [discountField becomeFirstResponder];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.label.frame;
    frame.size.height = self.bounds.size.height / 2;
    frame.origin.y = 5;
    self.label.frame = frame;
    frame.origin.y = self.bounds.size.height/2;
    self.discountField.frame = frame;
    
    button.frame = rect(self.bounds.size.width-16-10, (self.bounds.size.height-16)/2, 16, 16);
}

@end
