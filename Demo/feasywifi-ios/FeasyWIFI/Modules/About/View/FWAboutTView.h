//
//  FWAboutTView.h
//  FeasyWIFI
//
//  Created by chenchanghua on 2021/12/7.
//  Copyright © 2021 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FWAboutModel;

NS_ASSUME_NONNULL_BEGIN

@interface FWAboutTView : UITableView

@property (nonatomic, copy) NSArray<FWAboutModel *> *aboutModelArray;

@end

NS_ASSUME_NONNULL_END
