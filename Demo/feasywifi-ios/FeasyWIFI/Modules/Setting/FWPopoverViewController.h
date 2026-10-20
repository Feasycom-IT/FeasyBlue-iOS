//
//  FWPopoverViewController.h
//  FeasyWIFI
//
//  Created by app on 2023/6/19.
//  Copyright © 2023 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FWPopoverViewController : UITableViewController

@property (nonatomic, copy) void(^selectionHandler)(NSString *result);

- (instancetype)initWithItems:(NSArray*)items sourceView:(UIView*)sourceView;

@end

NS_ASSUME_NONNULL_END
