//
//  FEPasswordViewController.m
//  BLEAssistant
//
//  Created by wenyewei on 2020/5/25.
//  Copyright © 2020 feasycom. All rights reserved.
//

#import "FEPasswordViewController.h"
#import "FEChangeATCommandsViewController.h"

@interface FEPasswordViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *passwordlabel;
@property (nonatomic, strong) UITextField *textfield;

@end

@implementation FEPasswordViewController

- (void)dealloc {
    NSLog(@"dealloc_FEPasswordViewController");
}

- (instancetype)init {
    if (self = [super init]) {
        [self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.passwordlabel  = [[UILabel alloc]init];
    self.passwordlabel.text = LS(@"Password");
    [self.passwordlabel sizeToFit];
    [self.view addSubview:self.passwordlabel];
    [self.passwordlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.top.mas_equalTo(self.view.mas_top).offset(120);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    self.textfield = [[UITextField alloc]init];
    self.textfield.layer.borderColor= [UIColor grayColor].CGColor;
    self.textfield.layer.borderWidth= 1.0f;
    self.textfield.keyboardType = UIKeyboardTypeNumberPad;
    self.textfield.delegate = self;
    [self.textfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.textfield];
    [self.textfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.passwordlabel.mas_right).offset(5);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.passwordlabel.mas_centerY);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length > 8) {
        [self showAlertControllerWithTitle:LS(@"Password is more than 8 numbers")];
        return NO;
    }
    return YES;
}
// 密码20138888
- (void)textFieldDidChange:(UITextField *)theTextField {
    
    if ([theTextField.text isEqualToString:@"20138888"]) {
    
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FEChangeATCommandsViewController" bundle:nil];
        FEChangeATCommandsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"sto_ATCommandsTV"];
        vc.hidesBottomBarWhenPushed = YES;
        NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
        const NSInteger count = viewControllers.count;
        
        if (0 < count) {
            [viewControllers replaceObjectAtIndex:count - 1 withObject:vc];
        }
        [self.navigationController setViewControllers:viewControllers animated:YES];
        // 存
        [FEUserDefaultCache saveUserPassword:theTextField.text];
    } else if (theTextField.text.length == 8) {
        [self showAlertControllerWithTitle:LS(@"Password error")];
    }
}

@end
