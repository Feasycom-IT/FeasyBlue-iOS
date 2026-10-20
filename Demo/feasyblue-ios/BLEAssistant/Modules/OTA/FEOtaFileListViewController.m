//
//  FEOtaFileListViewController.m
//  BLEAssistant
//
//  Created by chenchanghua on 2026/2/27.
//  Copyright © 2026 feasycom. All rights reserved.
//

#import "FEOtaFileListViewController.h"
#import "FEOtaFileManager.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface FEOtaFileListViewController ()
@property (nonatomic, strong) NSMutableArray<NSString *> *dataSource;
@end

@implementation FEOtaFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.pageTitle ?: @"OTA Files";
    self.dataSource = [NSMutableArray array];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = 60.0;
    
    UIRefreshControl *rc = [UIRefreshControl new];
    [rc addTarget:self action:@selector(onPullToRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
    
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [self.tableView addGestureRecognizer:lp];
    
    [self reloadDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadDataSource];
}

#pragma mark - Actions

- (void)onPullToRefresh {
    [self reloadDataSource];
    [self.refreshControl endRefreshing];
}

- (void)onLongPress:(UILongPressGestureRecognizer *)gr {
    if (gr.state != UIGestureRecognizerStateBegan) return;
    
    CGPoint p = [gr locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (!indexPath) return;
    
    NSString *path = self.dataSource[indexPath.row];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    avc.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *pop = avc.popoverPresentationController;
    if (pop) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        pop.sourceView = cell;
        pop.sourceRect = cell.bounds;
    }
    
    [self presentViewController:avc animated:YES completion:nil];
}

#pragma mark - Data

- (BOOL)_isAllowedByExtension:(NSString *)path {
    if (self.allowedExtensions.count == 0) return YES;
    
    NSString *ext = path.pathExtension.lowercaseString ?: @"";
    for (NSString *allow in self.allowedExtensions) {
        if ([ext isEqualToString:allow.lowercaseString]) return YES;
    }
    return NO;
}

- (void)reloadDataSource {
    NSArray<NSString *> *all = [FEOtaFileManager listOtaFiles];
    [self.dataSource removeAllObjects];
    
    for (NSString *p in all) {
        if ([self _isAllowedByExtension:p]) {
            [self.dataSource addObject:p];
        }
    }
    
    [self.tableView reloadData];
    
    if (self.dataSource.count == 0) {
        self.tableView.backgroundView = [self _emptyView];
    } else {
        self.tableView.backgroundView = nil;
    }
}

- (UIView *)_emptyView {
    UILabel *lb = [[UILabel alloc] initWithFrame:self.tableView.bounds];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.numberOfLines = 0;
    lb.textColor = [UIColor secondaryLabelColor];
    lb.text = @"No OTA files.";
    return lb;
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSString *path = self.dataSource[indexPath.row];
    NSString *name = path.lastPathComponent ?: @"(unknown)";
    
    NSDictionary *attr = [FEOtaFileManager attributesOfItemAtPath:path];
    unsigned long long size = [attr[NSFileSize] unsignedLongLongValue];
    NSDate *mtime = attr[NSFileModificationDate];
    
    cell.textLabel.text = name;
    cell.textLabel.numberOfLines = 1;
    
    if (@available(iOS 14.0, *)) {
        UIListContentConfiguration *cfg = [UIListContentConfiguration subtitleCellConfiguration];
        cfg.text = name;
        
        NSString *sizeStr = [self _humanSize:size];
        NSString *dateStr = [self _formatDate:mtime];
        cfg.secondaryText = [NSString stringWithFormat:@"%@ · %@", sizeStr, dateStr];
        
        cell.contentConfiguration = cfg;
    } else {
        cell.textLabel.text = name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ · %@", [self _humanSize:size], [self _formatDate:mtime]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *path = self.dataSource[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:FENotificationUrlNotification object:nil userInfo:@{ @"url" : path }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    
    NSString *path = self.dataSource[indexPath.row];
    NSError *err = nil;
    BOOL ok = [FEOtaFileManager deleteFileAtPath:path error:&err];
    if (!ok) {
        [self _showAlertTitle:@"Delete Failed" message:err.localizedDescription ?: @"Unknown error"];
        return;
    }
    
    [self.dataSource removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (self.dataSource.count == 0) {
        self.tableView.backgroundView = [self _emptyView];
    }
}

#pragma mark - Helpers

- (NSString *)_humanSize:(unsigned long long)bytes {
    double b = (double)bytes;
    if (b < 1024) return [NSString stringWithFormat:@"%.0f B", b];
    b /= 1024;
    if (b < 1024) return [NSString stringWithFormat:@"%.1f KB", b];
    b /= 1024;
    if (b < 1024) return [NSString stringWithFormat:@"%.1f MB", b];
    b /= 1024;
    return [NSString stringWithFormat:@"%.2f GB", b];
}

- (NSString *)_formatDate:(NSDate *)date {
    if (!date) return @"-";
    static NSDateFormatter *fmt = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fmt = [NSDateFormatter new];
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
    });
    return [fmt stringFromDate:date];
}

- (void)_showAlertTitle:(NSString *)title message:(NSString *)msg {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title
                                                                message:msg ?: @""
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

@end
