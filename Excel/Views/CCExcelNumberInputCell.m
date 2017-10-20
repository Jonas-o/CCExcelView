//
//  CCNumberInputCell.m
//  CCExcelView
//
//  Created by luo on 2017/10/16.
//  Copyright © 2017年 luo. All rights reserved.
//

#import "CCExcelNumberInputCell.h"
#import "CCUtil.h"

@interface CCExcelNumberInputCell() <UITextFieldDelegate>

@end

@implementation CCExcelNumberInputCell
@synthesize contentField, detailLabel;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier style:CCExcelCellStyleDefault]) {
        contentField = [CCTextField new];
        contentField.delegate = self;
        contentField.font = kExcelCellLabelFont;
        contentField.textAlignment = NSTextAlignmentRight;
        contentField.returnKeyType = UIReturnKeyDone;
        contentField.textColor = RGB(102, 102, 102);
        contentField.background = [CCImage(@"order_input_normal") resizableImageWithCapInsets:UIEdgeInsetsMake(14, 20, 14, 20) resizingMode:UIImageResizingModeStretch];
        [contentField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        
        contentField.disabledBackground = [CCImage(@"order_input_disabled") resizableImageWithCapInsets:UIEdgeInsetsMake(14, 20, 14, 20) resizingMode:UIImageResizingModeStretch];
        [self addSubview:contentField];
        
        detailLabel = [UILabel new];
        detailLabel.font = sysFont(12);
        detailLabel.textColor = ColorLightGreen;
        [self addSubview:detailLabel];
        
        self.control.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setDetailLabelText:(NSString *)str {
    detailLabel.text = str;
    if (isPositiveDecimal(decimalWithString(str))) {
        detailLabel.textColor = ColorLightGreen;
    } else {
        detailLabel.textColor = ColorRed;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    contentField.background = [CCImage(@"order_input_focus") resizableImageWithCapInsets:UIEdgeInsetsMake(14, 20, 14, 20) resizingMode:UIImageResizingModeStretch];
    if (self.editAction) {
        self.editAction(self);
    }
    return YES;
}

- (void)textChanged:(id)sender {
    if (!self.inputAction) {
        return;
    }
    NSDecimalNumber *number = [NSDecimalNumber zero];
    NSString *text = contentField.text;
    if ((![text containsString:@"-"] && text.length > 0) || ([text containsString:@"-"] && text.length > 1)) {
        number = decimalWithString(contentField.text);
    }
    self.inputAction(self, number);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    contentField.background = [CCImage(@"order_input_normal") resizableImageWithCapInsets:UIEdgeInsetsMake(14, 20, 14, 20) resizingMode:UIImageResizingModeStretch];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.returnAction) {
        self.returnAction(self);
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    contentField.frame = self.bounds;
    detailLabel.frame = rect(12, 4, self.bounds.size.width-24, 16);
}


+ (CGFloat)cellWidthWithTitle:(NSString *)title {
    CGFloat width = [title widthWithFont:kExcelCellLabelFont height:MAXFLOAT];
    return width + 12*2;
}

@end
