//
//  FEMinimumRSSITableViewCell.m
//  BLEAssistant
//
//  Created by ericj on 2018/6/5.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import "FEMinimumRSSITableViewCell.h"

@implementation FEMinimumRSSITableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.minimumRSSISlider.minimumValue = -100.f;
    self.minimumRSSISlider.maximumValue = -30.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
