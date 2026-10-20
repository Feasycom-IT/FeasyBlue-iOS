//
//  FEChangeATCommandsViewController.m
//  BLEAssistant
//
//  Created by ericj on 2018/2/9.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import "FEChangeATCommandsViewController.h"
#import "FECommandPeripheralsViewController.h"
#import <SVProgressHUD.h>

@interface FEChangeATCommandsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *changeNameTF;
@property (weak, nonatomic) IBOutlet UITextField *changePinTF;
@property (weak, nonatomic) IBOutlet UITextField *changeBaudTF;
@property (weak, nonatomic) IBOutlet UISwitch *changeNameSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *changePinSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *changeBaudSwitch;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_1_1;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_1_2;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_2_1;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_2_2;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_3_1;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_3_2;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_4_1;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_4_2;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_5_1;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_5_2;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_6_1;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_6_2;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_7_1;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_7_2;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_8_1;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_8_2;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_9_1;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField_9_2;
@property (weak, nonatomic) IBOutlet UISwitch *changeSwitch_1;
@property (weak, nonatomic) IBOutlet UISwitch *changeSwitch_2;
@property (weak, nonatomic) IBOutlet UISwitch *changeSwitch_3;
@property (weak, nonatomic) IBOutlet UISwitch *changeSwitch_4;
@property (weak, nonatomic) IBOutlet UISwitch *changeSwitch_5;
@property (weak, nonatomic) IBOutlet UISwitch *changeSwitch_6;
@property (weak, nonatomic) IBOutlet UISwitch *changeSwitch_7;
@property (weak, nonatomic) IBOutlet UISwitch *changeSwitch_8;
@property (weak, nonatomic) IBOutlet UISwitch *changeSwitch_9;

@property (nonatomic, strong) NSMutableArray *infoArrayM;
@property (nonatomic, assign) BOOL shouldChange;

@end

@implementation FEChangeATCommandsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationContent];
    [self setupUI];
    self.infoArrayM = [NSMutableArray array];
}

- (void)setupNavigationContent {
    self.navigationItem.title = LS(@"parametricModify");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Back") style:UIBarButtonItemStylePlain target:nil action:nil];
    // 开始按钮
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [btn setTitle:LS(@"start") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn addTarget:self action:@selector(clickSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * button = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = button;
}

- (void)setupUI {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //赋值
    self.changeNameTF.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"change_name"];
    self.changePinTF.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"change_pin"];
    self.changeBaudTF.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"change_baud"];
    self.changeTextField_1_1.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_1_1"];
    self.changeTextField_1_2.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_1_2"];
    self.changeTextField_2_1.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_2_1"];
    self.changeTextField_2_2.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_2_2"];
    self.changeTextField_3_1.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_3_1"];
    self.changeTextField_3_2.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_3_2"];
    self.changeTextField_4_1.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_4_1"];
    self.changeTextField_4_2.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_4_2"];
    self.changeTextField_5_1.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_5_1"];
    self.changeTextField_5_2.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_5_2"];
    self.changeTextField_6_1.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_6_1"];
    self.changeTextField_6_2.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_6_2"];
    self.changeTextField_7_1.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_7_1"];
    self.changeTextField_7_2.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_7_2"];
    self.changeTextField_8_1.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_8_1"];
    self.changeTextField_8_2.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_8_2"];
    self.changeTextField_9_1.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_9_1"];
    self.changeTextField_9_2.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"changeTextField_9_2"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.shouldChange = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //保存
    [[NSUserDefaults standardUserDefaults] setValue:self.changeNameTF.text forKey:@"change_name"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changePinTF.text forKey:@"change_pin"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeBaudTF.text forKey:@"change_baud"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_1_1.text forKey:@"changeTextField_1_1"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_1_2.text forKey:@"changeTextField_1_2"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_2_1.text forKey:@"changeTextField_2_1"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_2_2.text forKey:@"changeTextField_2_2"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_3_1.text forKey:@"changeTextField_3_1"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_3_2.text forKey:@"changeTextField_3_2"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_4_1.text forKey:@"changeTextField_4_1"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_4_2.text forKey:@"changeTextField_4_2"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_5_1.text forKey:@"changeTextField_5_1"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_5_2.text forKey:@"changeTextField_5_2"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_6_1.text forKey:@"changeTextField_6_1"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_6_2.text forKey:@"changeTextField_6_2"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_7_1.text forKey:@"changeTextField_7_1"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_7_2.text forKey:@"changeTextField_7_2"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_8_1.text forKey:@"changeTextField_8_1"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_8_2.text forKey:@"changeTextField_8_2"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_9_1.text forKey:@"changeTextField_9_1"];
    [[NSUserDefaults standardUserDefaults] setValue:self.changeTextField_9_2.text forKey:@"changeTextField_9_2"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - AT指令配置

- (void)clickSelectBtn:(UIButton *)sender {
    [self.infoArrayM removeAllObjects];
    if (self.changeNameSwitch.on) {
        self.shouldChange = YES;
        NSString *name1 = [NSString stringWithFormat:@"AT+NAME=%@\r\n",self.changeNameTF.text];
        [self.infoArrayM addObject:name1];
        NSString *name2 = [NSString stringWithFormat:@"AT+NAME\r\n"];
        [self.infoArrayM addObject:name2];
    }
    if (self.changePinSwitch.on) {
        self.shouldChange = YES;
        NSString *pin1 = [NSString stringWithFormat:@"AT+PIN=%@\r\n",self.changePinTF.text];
        [self.infoArrayM addObject:pin1];
        NSString *pin2 = [NSString stringWithFormat:@"AT+PIN\r\n"];
        [self.infoArrayM addObject:pin2];
    }
    if (self.changeBaudSwitch.on) {
        self.shouldChange = YES;
        NSString *baud1 = [NSString stringWithFormat:@"AT+BAUD=%@\r\n",self.changeBaudTF.text];
        [self.infoArrayM addObject:baud1];
        NSString *baud2 = [NSString stringWithFormat:@"AT+BAUD\r\n"];
        [self.infoArrayM addObject:baud2];
    }
    if (self.changeSwitch_1.on) {
        self.shouldChange = YES;
        if (self.changeTextField_1_2.text.length == 0) {
            NSString *str1_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_1_1.text];
            [self.infoArrayM addObject:str1_1];
        } else {
            NSString *str1_2 = [NSString stringWithFormat:@"AT+%@=%@\r\n",self.changeTextField_1_1.text,self.changeTextField_1_2.text];
            [self.infoArrayM addObject:str1_2];
            NSString *str1_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_1_1.text];
            [self.infoArrayM addObject:str1_1];
        }
    }
    if (self.changeSwitch_2.on) {
        self.shouldChange = YES;
        if (self.changeTextField_2_2.text.length == 0) {
            NSString *str2_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_2_1.text];
            [self.infoArrayM addObject:str2_1];
        } else {
            NSString *str2_2 = [NSString stringWithFormat:@"AT+%@=%@\r\n",self.changeTextField_2_1.text,self.changeTextField_2_2.text];
            [self.infoArrayM addObject:str2_2];
            NSString *str2_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_2_1.text];
            [self.infoArrayM addObject:str2_1];
        }
    }
    if (self.changeSwitch_3.on) {
        self.shouldChange = YES;
        if (self.changeTextField_3_2.text.length == 0) {
            NSString *str3_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_3_1.text];
            [self.infoArrayM addObject:str3_1];
        } else {
            NSString *str3_2 = [NSString stringWithFormat:@"AT+%@=%@\r\n",self.changeTextField_3_1.text,self.changeTextField_3_2.text];
            [self.infoArrayM addObject:str3_2];
            NSString *str3_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_3_1.text];
            [self.infoArrayM addObject:str3_1];
        }
    }
    if (self.changeSwitch_4.on) {
        self.shouldChange = YES;
        if (self.changeTextField_4_2.text.length == 0) {
            NSString *str4_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_4_1.text];
            [self.infoArrayM addObject:str4_1];
        } else {
            NSString *str4_2 = [NSString stringWithFormat:@"AT+%@=%@\r\n",self.changeTextField_4_1.text,self.changeTextField_4_2.text];
            [self.infoArrayM addObject:str4_2];
            NSString *str4_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_4_1.text];
            [self.infoArrayM addObject:str4_1];
        }
    }
    if (self.changeSwitch_5.on) {
        self.shouldChange = YES;
        if (self.changeTextField_5_2.text.length == 0) {
            NSString *str5_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_5_1.text];
            [self.infoArrayM addObject:str5_1];
        } else {
            NSString *str5_2 = [NSString stringWithFormat:@"AT+%@=%@\r\n",self.changeTextField_5_1.text,self.changeTextField_5_2.text];
            [self.infoArrayM addObject:str5_2];
            NSString *str5_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_5_1.text];
            [self.infoArrayM addObject:str5_1];
        }
    }
    if (self.changeSwitch_6.on) {
        self.shouldChange = YES;
        if (self.changeTextField_6_2.text.length == 0) {
            NSString *str6_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_6_1.text];
            [self.infoArrayM addObject:str6_1];
        } else {
            NSString *str6_2 = [NSString stringWithFormat:@"AT+%@=%@\r\n",self.changeTextField_6_1.text,self.changeTextField_6_2.text];
            [self.infoArrayM addObject:str6_2];
            NSString *str6_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_6_1.text];
            [self.infoArrayM addObject:str6_1];
        }
    }
    if (self.changeSwitch_7.on) {
        self.shouldChange = YES;
        if (self.changeTextField_7_2.text.length == 0) {
            NSString *str7_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_7_1.text];
            [self.infoArrayM addObject:str7_1];
        } else {
            NSString *str7_2 = [NSString stringWithFormat:@"AT+%@=%@\r\n",self.changeTextField_7_1.text,self.changeTextField_7_2.text];
            [self.infoArrayM addObject:str7_2];
            NSString *str7_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_7_1.text];
            [self.infoArrayM addObject:str7_1];
        }
    }
    if (self.changeSwitch_8.on) {
        self.shouldChange = YES;
        if (self.changeTextField_8_2.text.length == 0) {
            NSString *str8_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_8_1.text];
            [self.infoArrayM addObject:str8_1];
        } else {
            NSString *str8_2 = [NSString stringWithFormat:@"AT+%@=%@\r\n",self.changeTextField_8_1.text,self.changeTextField_8_2.text];
            [self.infoArrayM addObject:str8_2];
            NSString *str8_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_8_1.text];
            [self.infoArrayM addObject:str8_1];
        }
    }
    if (self.changeSwitch_9.on) {
        self.shouldChange = YES;
        if (self.changeTextField_9_2.text.length == 0) {
            NSString *str9_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_9_1.text];
            [self.infoArrayM addObject:str9_1];
        } else {
            NSString *str9_2 = [NSString stringWithFormat:@"AT+%@=%@\r\n",self.changeTextField_9_1.text,self.changeTextField_9_2.text];
            [self.infoArrayM addObject:str9_2];
            NSString *str9_1 = [NSString stringWithFormat:@"AT+%@\r\n",self.changeTextField_9_1.text];
            [self.infoArrayM addObject:str9_1];
        }
    }
    if (self.shouldChange) {
        FECommandPeripheralsViewController *viewController = [[FECommandPeripheralsViewController alloc] initWithCommands:self.infoArrayM];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [SVProgressHUD showInfoWithStatus:LS(@"Not Selected")];
    }
}

//填写的 设备信息 改变时
- (IBAction)changeNameTF:(UITextField *)sender {
    
}
//填写的 配对码信息 改变时
- (IBAction)changePinTF:(UITextField *)sender {
    
}
//填写的 波特率信息 改变时
- (IBAction)changeBaudTF:(UITextField *)sender {
    
}

#pragma mark - Switch 开关事件

- (IBAction)changNameSwitch:(UISwitch *)sender {
    if (self.changeNameSwitch.on) {
        self.changeNameTF.userInteractionEnabled = NO;
    } else {
        self.changeNameTF.userInteractionEnabled = YES;
    }
    if (self.changeNameTF.text.length == 0) {
        self.changeNameSwitch.on = NO;
        self.changeNameTF.userInteractionEnabled = YES;
        [SVProgressHUD showInfoWithStatus:LS(@"None")];
    }
}
- (IBAction)changePinSwitch:(UISwitch *)sender {
    if (self.changePinSwitch.on) {
        self.changePinTF.userInteractionEnabled = NO;
    } else {
        self.changePinTF.userInteractionEnabled = YES;
    }
    if (self.changePinTF.text.length == 0) {
        self.changePinSwitch.on = NO;
        self.changePinTF.userInteractionEnabled = YES;
        [SVProgressHUD showInfoWithStatus:LS(@"None")];
    }
}
- (IBAction)changeBaudSwitch:(UISwitch *)sender {
    if (self.changeBaudSwitch.on) {
        self.changeBaudTF.userInteractionEnabled = NO;
    } else {
        self.changeBaudTF.userInteractionEnabled = YES;
    }
    if (self.changeBaudTF.text.length == 0) {
        self.changeBaudSwitch.on = NO;
        self.changeBaudTF.userInteractionEnabled = YES;
        [SVProgressHUD showInfoWithStatus:LS(@"None")];
    }
}
- (IBAction)changeSwitch_1:(UISwitch *)sender {
    if (self.changeSwitch_1.on) {
        self.changeTextField_1_1.userInteractionEnabled = NO;
        self.changeTextField_1_2.userInteractionEnabled = NO;
    } else {
        self.changeTextField_1_1.userInteractionEnabled = YES;
        self.changeTextField_1_2.userInteractionEnabled = YES;
    }
    if (self.changeTextField_1_1.text.length == 0) {
        self.changeSwitch_1.on = NO;
        self.changeTextField_1_1.userInteractionEnabled = YES;
        self.changeTextField_1_2.userInteractionEnabled = YES;
        [SVProgressHUD showInfoWithStatus:LS(@"None")];
    }
}
- (IBAction)changeSwitch_2:(UISwitch *)sender {
    if (self.changeSwitch_2.on) {
        self.changeTextField_2_1.userInteractionEnabled = NO;
        self.changeTextField_2_2.userInteractionEnabled = NO;
    } else {
        self.changeTextField_2_1.userInteractionEnabled = YES;
        self.changeTextField_2_2.userInteractionEnabled = YES;
    }
    if (self.changeTextField_2_1.text.length == 0) {
        self.changeSwitch_2.on = NO;
        self.changeTextField_2_1.userInteractionEnabled = YES;
        self.changeTextField_2_2.userInteractionEnabled = YES;
        [SVProgressHUD showInfoWithStatus:LS(@"None")];
    }
}
- (IBAction)changeSwitch_3:(UISwitch *)sender {
    if (self.changeSwitch_3.on) {
        self.changeTextField_3_1.userInteractionEnabled = NO;
        self.changeTextField_3_2.userInteractionEnabled = NO;
    } else {
        self.changeTextField_3_1.userInteractionEnabled = YES;
        self.changeTextField_3_2.userInteractionEnabled = YES;
    }
    if (self.changeTextField_3_1.text.length == 0) {
        self.changeSwitch_3.on = NO;
        self.changeTextField_3_1.userInteractionEnabled = YES;
        self.changeTextField_3_2.userInteractionEnabled = YES;
        [SVProgressHUD showInfoWithStatus:LS(@"None")];
    }
}
- (IBAction)changeSwitch_4:(UISwitch *)sender {
    if (self.changeSwitch_4.on) {
        self.changeTextField_4_1.userInteractionEnabled = NO;
        self.changeTextField_4_2.userInteractionEnabled = NO;
    } else {
        self.changeTextField_4_1.userInteractionEnabled = YES;
        self.changeTextField_4_2.userInteractionEnabled = YES;
    }
    if (self.changeTextField_4_1.text.length == 0) {
        self.changeSwitch_4.on = NO;
        self.changeTextField_4_1.userInteractionEnabled = YES;
        self.changeTextField_4_2.userInteractionEnabled = YES;
        [SVProgressHUD showInfoWithStatus:LS(@"None")];
    }
}
- (IBAction)changeSwitch_5:(UISwitch *)sender {
    if (self.changeSwitch_5.on) {
        self.changeTextField_5_1.userInteractionEnabled = NO;
        self.changeTextField_5_2.userInteractionEnabled = NO;
    } else {
        self.changeTextField_5_1.userInteractionEnabled = YES;
        self.changeTextField_5_2.userInteractionEnabled = YES;
    }
    if (self.changeTextField_5_1.text.length == 0) {
        self.changeSwitch_5.on = NO;
        self.changeTextField_5_1.userInteractionEnabled = YES;
        self.changeTextField_5_2.userInteractionEnabled = YES;
        [SVProgressHUD showInfoWithStatus:LS(@"None")];
    }
}
- (IBAction)changeSwitch_6:(UISwitch *)sender {
    if (self.changeSwitch_6.on) {
        self.changeTextField_6_1.userInteractionEnabled = NO;
        self.changeTextField_6_2.userInteractionEnabled = NO;
    } else {
        self.changeTextField_6_1.userInteractionEnabled = YES;
        self.changeTextField_6_2.userInteractionEnabled = YES;
    }
    if (self.changeTextField_6_1.text.length == 0) {
        self.changeSwitch_6.on = NO;
        self.changeTextField_6_1.userInteractionEnabled = YES;
        self.changeTextField_6_2.userInteractionEnabled = YES;
        [SVProgressHUD showInfoWithStatus:LS(@"None")];
    }
}
- (IBAction)changeSwitch_7:(UISwitch *)sender {
    if (self.changeSwitch_7.on) {
        self.changeTextField_7_1.userInteractionEnabled = NO;
        self.changeTextField_7_2.userInteractionEnabled = NO;
    } else {
        self.changeTextField_7_1.userInteractionEnabled = YES;
        self.changeTextField_7_2.userInteractionEnabled = YES;
    }
    if (self.changeTextField_7_1.text.length == 0) {
        self.changeSwitch_7.on = NO;
        self.changeTextField_7_1.userInteractionEnabled = YES;
        self.changeTextField_7_2.userInteractionEnabled = YES;
        [SVProgressHUD showInfoWithStatus:LS(@"None")];
    }
}
- (IBAction)changeSwitch_8:(UISwitch *)sender {
    if (self.changeSwitch_8.on) {
        self.changeTextField_8_1.userInteractionEnabled = NO;
        self.changeTextField_8_2.userInteractionEnabled = NO;
    } else {
        self.changeTextField_8_1.userInteractionEnabled = YES;
        self.changeTextField_8_2.userInteractionEnabled = YES;
    }
    if (self.changeTextField_8_1.text.length == 0) {
        self.changeSwitch_8.on = NO;
        self.changeTextField_8_1.userInteractionEnabled = YES;
        self.changeTextField_8_2.userInteractionEnabled = YES;
        [SVProgressHUD showInfoWithStatus:LS(@"None")];
    }
}
- (IBAction)changeSwitch_9:(UISwitch *)sender {
    if (self.changeSwitch_9.on) {
        self.changeTextField_9_1.userInteractionEnabled = NO;
        self.changeTextField_9_2.userInteractionEnabled = NO;
    } else {
        self.changeTextField_9_1.userInteractionEnabled = YES;
        self.changeTextField_9_2.userInteractionEnabled = YES;
    }
    if (self.changeTextField_9_1.text.length == 0) {
        self.changeSwitch_9.on = NO;
        self.changeTextField_9_1.userInteractionEnabled = YES;
        self.changeTextField_9_2.userInteractionEnabled = YES;
        [SVProgressHUD showInfoWithStatus:LS(@"None")];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
