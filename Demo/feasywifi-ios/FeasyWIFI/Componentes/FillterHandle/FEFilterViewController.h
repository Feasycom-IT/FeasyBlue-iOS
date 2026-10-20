//
//  FEFilterViewController.h
//  BLEAssistant
//
//  Created by ericj on 2018/6/5.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FEFilterModel : NSObject
@property (nonatomic, assign) BOOL isFilterName;
@property (nonatomic, copy) NSString *filterName;
@property (nonatomic, assign) float filterMinimumRSSI;
@end

typedef void(^DidChangedFilterBlock)(FEFilterModel *currentFilter);

/// 过滤设置VC
@interface FEFilterViewController : UIViewController

@property (nonatomic, copy) DidChangedFilterBlock didChangedFilterBlock;
- (instancetype)initWithFilterModel:(FEFilterModel *)beforeFilter didChangedFilter:(DidChangedFilterBlock)didChangedFilterBlock;

@end
