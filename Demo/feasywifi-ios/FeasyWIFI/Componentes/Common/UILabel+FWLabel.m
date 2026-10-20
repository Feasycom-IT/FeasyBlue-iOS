//
//  UILabel+FWLabel.m
//  FeasyWIFI
//
//  Created by ericj on 2018/7/17.
//  Copyright © 2018年 Feasycom. All rights reserved.
//

#import "UILabel+FWLabel.h"

@implementation UILabel (FWLabel)

+ (UILabel *)createLabelWithText:(NSString *)text withFont:(CGFloat)font {
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor blackColor];
    label.text = text;
    label.font = [UIFont systemFontOfSize:font];
    return label;
}

@end
