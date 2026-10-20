//
//  FEPeripheralsViewController.h
//  FeasycomLE
//
//  Created by 余明悦 on 16/7/20.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FEPeripheral;

typedef NS_ENUM(NSInteger, FEPageType) {
    FEHomePage = 0,
    FECommandPage,
    FEDFUPage
};

@interface FEPeripheralsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readonly) NSMutableArray<FEPeripheral *> *peripherals;

- (instancetype)initWithPageType:(const FEPageType)pageType;

- (void)refresh;

@end
