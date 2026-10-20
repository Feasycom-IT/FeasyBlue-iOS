//
//  FEDFUFileTableViewController.m
//  BLEAssistant
//
//  Created by ericj on 2018/4/10.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import "FEDFUFileTableViewController.h"
#import "FEDFUDownloadViewController.h"
#import "FEOtaFileManager.h"

@interface FEDFUFileTableViewController ()  <UIDocumentPickerDelegate>
@property (nonatomic, strong) NSArray *typeArray;
@end

@implementation FEDFUFileTableViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"dealloc_FEDFUFileTableViewController");
}

- (instancetype)init {
    if (self = [super init]) {
        [self setHidesBottomBarWhenPushed:YES];
        self.typeArray = @[
            LS(@"Get from QQ"),
            LS(@"Get from WeChat"),
            LS(@"Get from WeCom"),
            LS(@"Get from Documents folder"),
            LS(@"Download from web")
        ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setRowHeight:60.f];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    UITableViewHeaderFooterView *footView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.typeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = self.typeArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mqq://"] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mqq://"]];
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else if (indexPath.row == 1) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else if (indexPath.row == 2) {
        NSURL *url = [NSURL URLWithString:@"wxwork://"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else if (indexPath.row == 3) {
        [self onSelectFile];
    } else if (indexPath.row == 4) {
        FEDFUDownloadViewController *viewController = [[FEDFUDownloadViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)filePathDidUpdate {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)onSelectFile {
    UIDocumentPickerViewController* picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:picker animated:true completion:nil];
    });
}

- (void)documentPicker:(UIDocumentPickerViewController*)controller didPickDocumentAtURL:(NSURL*)url {
    __weak typeof(self) weakSelf = self;
    [FEOtaFileManager importFileURL:url sourceTag:@"DocumentPicker" completion:^(NSString * _Nullable finalPath, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (error) {
            [controller dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        [controller dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:FENotificationUrlNotification
                                                                object:nil
                                                              userInfo:@{@"url":finalPath}];
            [strongSelf.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

@end
