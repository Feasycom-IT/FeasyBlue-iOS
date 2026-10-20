//
//  UIViewController+NavigationHeight.m
//  BLEAssistant
//
//  Created by chenchanghua on 2026/1/8.
//  Copyright © 2026 feasycom. All rights reserved.
//

#import "UIViewController+NavigationHeight.h"

@implementation UIViewController (NavigationHeight)

- (CGFloat)safeAreaTopHeight {
    return self.view.safeAreaInsets.top;
}

- (CGFloat)safeNavigationBarHeight {
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        // 导航栏可见
        CGRect navBarFrame = self.navigationController.navigationBar.frame;
        return navBarFrame.origin.y + navBarFrame.size.height;
    } else {
        // 导航栏隐藏或不存在
        return [self safeAreaTopHeight];
    }
}

@end
