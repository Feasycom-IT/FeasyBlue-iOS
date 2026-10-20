//
//  FWMacro.h
//  FeasyWIFI
//
//  Created by chenchanghua on 2021/12/6.
//  Copyright © 2021 Feasycom. All rights reserved.
//

#ifndef FWMacro_h
#define FWMacro_h

#define kStatusBar_Height ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define kNavBar_Height ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 88 : 64)
#define kTabBar_Height ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 83 : 49)
#define kTabBar_Safe_Height ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 34 : 0)
#define kScreen_Height   ([UIScreen mainScreen].bounds.size.height)
#define kScreen_Width    ([UIScreen mainScreen].bounds.size.width)
#define KScreen_Scale    ([UIScreen mainScreen].scale)

#endif /* FWMacro_h */
