//
//  FWPeripheralsTableViewCell.h
//  FeasyWIFI
//
//  Created by ericj on 2018/8/28.
//  Copyright © 2018年 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FWPeripheralsTableViewCell : UITableViewCell

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *UUIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceUUIDsLabel;
@property (weak, nonatomic) IBOutlet UILabel *macLabel;
@property (nonatomic) BOOL isConnectable;

- (void)reflashName:(NSString *)name;
- (void)reflashRSSI:(NSInteger)RSSI;
- (void)showProgress;
- (void)progressPersend:(CGFloat)persend;
- (void)hideProgress;


@end
