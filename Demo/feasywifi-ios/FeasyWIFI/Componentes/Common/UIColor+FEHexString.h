//
//  UIColor+FEHexString.h
//  BLEAssistant
//
//  Created by chenchanghua on 2021/9/10.
//  Copyright © 2021 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (FEHexString)

+ (UIColor*) colorWithHexString:(NSString*)color;

+ (UIColor*) colorWithHexString:(NSString*)color alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
