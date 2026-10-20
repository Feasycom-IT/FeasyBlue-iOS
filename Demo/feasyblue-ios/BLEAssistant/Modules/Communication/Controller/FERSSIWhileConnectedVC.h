//
//  FERSSIWhileConnectedVC.h
//  BLEAssistant
//
//  Created by chenchanghua on 2023/3/16.
//  Copyright © 2023 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FERSSIWhileConnectedVC : UIViewController

- (void)valueForRSSIChanged:(NSNumber *)rssi;

@end

NS_ASSUME_NONNULL_END
