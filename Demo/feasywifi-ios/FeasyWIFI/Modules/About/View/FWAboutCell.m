//
//  FWAboutCell.m
//  FeasyWIFI
//
//  Created by chenchanghua on 2021/12/7.
//  Copyright © 2021 Feasycom. All rights reserved.
//

#import "FWAboutCell.h"
#import "FWAboutModel.h"

@interface FWAboutCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *messageImageView;
@end

@implementation FWAboutCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupContentView];
    }
    return self;
}

- (void)setAboutModel:(FWAboutModel *)aboutModel {
    _aboutModel = aboutModel;
    self.titleLabel.text = self.aboutModel.name;
    self.messageLabel.text = self.aboutModel.message;
    self.messageImageView.image = [UIImage imageNamed:self.aboutModel.imageName];
}

- (void)setupContentView {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = [UIColor systemBlueColor];
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.width.mas_equalTo(100);
        make.centerY.equalTo(self);
    }];
    
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.font = [UIFont systemFontOfSize:14];
    self.messageLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.messageLabel];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(10);
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.centerY.equalTo(self);
    }];
    
    self.messageImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.messageImageView];
    [self.messageImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.centerY.equalTo(self);
    }];
}

@end
