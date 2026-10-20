//
//  FECommunicationTableViewCell.h
//  FeasycomLE
//
//  Created by 余明悦 on 16/7/20.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface FECommunicationTableViewCell : UITableViewCell


@property (unsafe_unretained, nonatomic) IBOutlet UILabel *UUIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceUUIDsLabel;
@property (nonatomic, assign) BOOL isConnectable;
@property (nonatomic, assign) NSInteger txPower;
- (void)refreshName:(NSString *)name;
- (void)refreshRSSI:(NSInteger)RSSI;
- (void)showProgress;
- (void)progressPersend:(CGFloat)persend;
- (void)hideProgress;
@end
