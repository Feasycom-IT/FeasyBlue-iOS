//
//  FWAboutTView.m
//  FeasyWIFI
//
//  Created by chenchanghua on 2021/12/7.
//  Copyright © 2021 Feasycom. All rights reserved.
//

#import "FWAboutTView.h"
#import "FWAboutCell.h"
#import "FWAboutModel.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <MessageUI/MessageUI.h>
#import "UIView+FWGetCurrentVC.h"
#import "FWCompanyMessageVC.h"
#import "FWWeChatVC.h"

@interface FWAboutTView () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@end

@implementation FWAboutTView
@synthesize aboutModelArray = _aboutModelArray;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        
        self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.backgroundColor = [UIColor whiteColor];
        self.delegate = self;
        self.dataSource = self;
        self.estimatedRowHeight = 44;
        self.rowHeight = 44;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
        headerView.image = [UIImage imageNamed:@"小鸟"];
        self.tableHeaderView = headerView;
    }
    return self;
}

- (void)setAboutModelArray:(NSArray<FWAboutModel *> *)aboutModelArray {
    _aboutModelArray = aboutModelArray;
    [self reloadData];
}

#pragma mark - tableViewDataSource,UITableViewDelegate
// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.aboutModelArray.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FWAboutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FWAboutCell"];
    if (!cell) {
        cell = [[FWAboutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FWAboutCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    FWAboutModel *cellModel = [self.aboutModelArray objectAtIndex:indexPath.row];
    cell.aboutModel = cellModel;
    
    return cell;
}

// 区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

//当已经点击cell时
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 0) {
        
    } else if (indexPath.row == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://075527924639"]];
    } else if (indexPath.row == 2) {
        if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] <= AFNetworkReachabilityStatusNotReachable) {
            [self createAlertController:LS(@"NETWORK_NOT_REACHABLE")];
            return;
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.feasycom.com"]];
    } else if (indexPath.row == 3) {
        if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] <= AFNetworkReachabilityStatusNotReachable) {
            [self createAlertController:LS(@"NETWORK_NOT_REACHABLE")];
            return;
        }
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailCon = [MFMailComposeViewController new];
            [mailCon setSubject:LS(@"question")];
            [mailCon setToRecipients:@[@"support@feasycom.com"]];
            // 设置发邮件的代理
            [mailCon setMailComposeDelegate:self];
            [self.viewController presentViewController:mailCon animated:YES completion:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://support@feasycom.com"]];
        }
    } else if (indexPath.row == 4) {
        FWWeChatVC *weChatVC = [[FWWeChatVC alloc] init];
        weChatVC.hidesBottomBarWhenPushed = YES;
        [self.viewController.navigationController pushViewController:weChatVC animated:YES];
    } else if (indexPath.row == 5) {
        FWCompanyMessageVC *companyMessageVC = [[FWCompanyMessageVC alloc] init];
        companyMessageVC.hidesBottomBarWhenPushed = YES;
        [self.viewController.navigationController pushViewController:companyMessageVC animated:YES];
    } else if (indexPath.row == 6) {
        
    }
}

#pragma MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultSent:
//            DDLogInfo(@"发送邮件成功");
            break;
        case MFMailComposeResultFailed:
//            DDLogInfo(@"发送邮件失败");
            break;
        case MFMailComposeResultCancelled:
//            DDLogInfo(@"取消邮件发送");
            break;
        default:
            break;
    }
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)createAlertController:(NSString *)string {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:string message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:okAction];
    [self.viewController.navigationController presentViewController:alertController animated:YES completion:NULL];
}

#pragma mark - lazyLoad
- (NSArray<FWAboutModel *> *)aboutModelArray {
    if (!_aboutModelArray) {
        _aboutModelArray = [[NSArray<FWAboutModel *> alloc] init];
    }
    return _aboutModelArray;
}

@end
