//
//  FECommunicationTableViewCell.m
//  FeasycomLE
//
//  Created by 余明悦 on 16/7/20.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import "FECommunicationTableViewCell.h"


@interface FECommunicationTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *RSSILabel;
@property (weak, nonatomic) IBOutlet UIProgressView *RSSIProgerssView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end
@implementation FECommunicationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)refreshName:(NSString *)name{
    if (name) {
        if (self.isConnectable && self.txPower > 0) {
//            self.nameLabel.text = [NSString stringWithFormat:@"%@ [可连接,TxPower:%ld]", name, self.txPower];
            self.nameLabel.text = name;
        } else if (self.isConnectable && self.txPower < 0) {
//            self.nameLabel.text = [NSString stringWithFormat:@"%@ [可连接,TxPower:N/A]", name];
            self.nameLabel.text = name;
        } else if (!self.isConnectable && self.txPower > 0) {
//            self.nameLabel.text = [NSString stringWithFormat:@"%@ [不可连接,TxPower:%ld]", name, self.txPower];
            self.nameLabel.text = name;
        } else if (!self.isConnectable && self.txPower < 0) {
//            self.nameLabel.text = [NSString stringWithFormat:@"%@ [不可连接,TxPower:N/A]", name];
            self.nameLabel.text = name;
        }
    }else{
        if (self.isConnectable && self.txPower > 0) {
//            self.nameLabel.text = [NSString stringWithFormat:@"%@ [可连接,TxPower:%ld]", LS(@"unname"), self.txPower];
            self.nameLabel.text = LS(@"unname");
        } else if (self.isConnectable && self.txPower < 0) {
//            self.nameLabel.text = [NSString stringWithFormat:@"%@ [可连接,TxPower:N/A]", LS(@"unname")];
            self.nameLabel.text = LS(@"unname");
        } else if (!self.isConnectable && self.txPower > 0) {
//            self.nameLabel.text = [NSString stringWithFormat:@"%@ [不可连接,TxPower:%ld]", LS(@"unname"), self.txPower];
            self.nameLabel.text = LS(@"unname");
        } else if (!self.isConnectable && self.txPower < 0) {
//            self.nameLabel.text = [NSString stringWithFormat:@"%@ [不可连接,TxPower:N/A]", LS(@"unname")];
            self.nameLabel.text = LS(@"unname");
        }
    }
}

- (void)refreshRSSI:(NSInteger)RSSI {
    if (0 <= RSSI) {
        RSSI = -1;
    } else if (-100 > RSSI) {
        RSSI = -100;
    }
    self.RSSILabel.text = [NSString stringWithFormat:@"%ld", RSSI];
    [self.RSSIProgerssView setProgress:(100+RSSI) / 100.0 animated:YES];
}

//- (void)setIsConnectable:(BOOL)isConnectable {
//    if (isConnectable) {
//        self.nameLabel.textColor = [UIColor systemBlueColor];
//    } else {
//        self.nameLabel.textColor = [UIColor blackColor];
//    }
//}


-(void)showProgress{
    self.progressView.hidden = NO;
    self.progressLabel.hidden = NO;
}
-(void)hideProgress{
    self.progressView.hidden = YES;
    self.progressLabel.hidden = YES;
}
-(void)progressPersend:(CGFloat)persend{
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f %%", persend];
    self.progressView.progress = persend * 0.01;
}


@end
