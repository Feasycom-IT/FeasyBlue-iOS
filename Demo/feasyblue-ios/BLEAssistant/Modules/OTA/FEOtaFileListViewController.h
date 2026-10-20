//
//  FEOtaFileListViewController.h
//  BLEAssistant
//
//  Created by chenchanghua on 2026/2/27.
//  Copyright © 2026 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FEOtaFileListViewController : UITableViewController

@property (nonatomic, copy, nullable) NSArray<NSString *> *allowedExtensions;

@property (nonatomic, copy, nullable) NSString *pageTitle;

@end

NS_ASSUME_NONNULL_END
