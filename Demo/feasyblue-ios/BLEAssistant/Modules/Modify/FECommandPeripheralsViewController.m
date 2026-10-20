//
//  FECommandPeripheralsViewController.m
//  BLEAssistant
//
//  Created by LiDong on 2021/4/21.
//  Copyright © 2021 feasycom. All rights reserved.
//

#import "FECommandPeripheralsViewController.h"
#import "FEChangeDetailViewController.h"

@interface FECommandPeripheralsViewController () <UITextFieldDelegate>

@property (nonatomic, copy) NSArray *commands;
@property (nonatomic, strong) UILabel *modifiedCountLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) NSInteger modifiedCount;// 参数修改的完成数

@end

@implementation FECommandPeripheralsViewController

- (instancetype)initWithCommands:(NSArray *)commands {
    if (self = [super initWithPageType:FECommandPage]) {
        _commands = [commands copy];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupMonitor{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseModifiedCount) name:FEIncreaseModifiedCountNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupMonitor];
    [self setupNavigationView];
}

- (void)setupNavigationView {
    
    UIControl *titleView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
    [titleView addTarget:self action:@selector(clickToChangeCount) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 24)];
    titleLabel.text = LS(@"parametricModify");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:17];
    titleLabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titleLabel];
    
    self.modifiedCount = [FEUserDefaultCache getModifiedCount];
    
    self.modifiedCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, 160, 20)];
    self.modifiedCountLabel.text = [NSString stringWithFormat:@"%@%d", LS(@"modifiedCount"), (int)_modifiedCount];
    self.modifiedCountLabel.textAlignment = NSTextAlignmentCenter;
    self.modifiedCountLabel.font = [UIFont systemFontOfSize:11];
    self.modifiedCountLabel.textColor = [UIColor whiteColor];
    [titleView addSubview:self.modifiedCountLabel];
    
    self.navigationItem.titleView = titleView;
}

- (void)clickToChangeCount {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"Number of modifications completed") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    __weak __typeof(self) weakSelf = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.textField = textField;
        strongSelf.textField.delegate = strongSelf;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.modifiedCount = [strongSelf.textField.text integerValue];
        [strongSelf updateModifiedCount];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:OKAction];
    [self.navigationController presentViewController:alertController animated:YES completion:NULL];
}

- (void)updateModifiedCount {
    [FEUserDefaultCache saveModifiedCount:self.modifiedCount];
    self.modifiedCountLabel.text = [NSString stringWithFormat:@"%@%ld", LS(@"modifiedCount"), _modifiedCount];
}

- (void)increaseModifiedCount {
    self.modifiedCount++;
    [self updateModifiedCount];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FEPeripheral *peripheral = self.peripherals[indexPath.row];
    FEChangeDetailViewController *viewController = [[FEChangeDetailViewController alloc] initWithPeripheral:peripheral commands:self.commands];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSInteger count = [textField.text integerValue];
    if (count < 999999999) {
        return YES;
    } else if ([string isEqualToString:@""]) {
        return YES;
    } else {
        return NO;
    }
    
}

@end
