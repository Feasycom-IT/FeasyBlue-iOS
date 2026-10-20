//
//  FWPeripheralsTableViewCell.m
//  FeasyWIFI
//
//  Created by ericj on 2018/8/28.
//  Copyright © 2018年 Feasycom. All rights reserved.
//

#import "FWPeripheralsTableViewCell.h"

@interface FWPeripheralsTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *RSSILabel;
@property (weak, nonatomic) IBOutlet UIProgressView *RSSIProgerssView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end   
@implementation FWPeripheralsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)reflashName:(NSString *)name{
    self.nameLabel.text = 0 < name.length ? name : LS(@"Unkown");
}

- (void)reflashRSSI:(NSInteger)RSSI {
    self.RSSILabel.text = [NSString stringWithFormat:@"%ld", RSSI];
    [self.RSSIProgerssView setProgress:(100+RSSI) / 100.0 animated:YES];

}


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
