//
//  UIButton+FWButton.m
//  FeasyWIFI
//
//  Created by ericj on 2018/7/17.
//  Copyright © 2018年 Feasycom. All rights reserved.
//

#import "UIButton+FWButton.h"

@implementation UIButton (FWButton)

+ (UIButton *)createView:(NSString *)string {
    UIButton *button = [[UIButton alloc] init];
    button.layer.cornerRadius = 8;
    button.layer.masksToBounds = YES;
    [button setTitle:string forState:UIControlStateNormal];
    return button;
}

@end
