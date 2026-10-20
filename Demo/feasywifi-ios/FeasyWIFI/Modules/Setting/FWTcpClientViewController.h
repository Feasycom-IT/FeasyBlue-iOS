//
//  FWTcpClientViewController.h
//  FeasyWIFI
//
//  Created by app on 2023/6/29.
//  Copyright © 2023 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FWTcpClientViewController : UIViewController

- (instancetype)initWithServer:(NSString*)server port:(NSString*)port;

@end

NS_ASSUME_NONNULL_END
