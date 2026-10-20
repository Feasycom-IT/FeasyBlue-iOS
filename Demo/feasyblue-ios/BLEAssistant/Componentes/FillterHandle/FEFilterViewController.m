//
//  FEFilterViewController.m
//  BLEAssistant
//
//  Created by ericj on 2018/6/5.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import "FEFilterViewController.h"
#import "FEFilterRSSITableViewCell.h"
#import "FEMinimumRSSITableViewCell.h"

@interface FEFilterViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, assign) FEPageType pageType;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FEMinimumRSSITableViewCell *cell;
@property (nonatomic, assign) float minimumRSSI;
@property (nonatomic, assign) BOOL filterEnabled;
@property (nonatomic, copy) NSString *filterName;
@property (nonatomic, strong) UISwitch *filterEnabledSwitch;
@property (nonatomic, strong) UISlider *rssiSlider;

@end

@implementation FEFilterViewController

- (instancetype)initWithPageType:(const FEPageType)pageType {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.title = LS(@"Filter");
        self.hidesBottomBarWhenPushed = YES;
        
        _pageType = pageType;
        
        if (FECommandPage == _pageType) {
            _filterEnabled = [FEUserDefaultCache getFilterEnabled_parameter];
            _minimumRSSI = [FEUserDefaultCache getMinimumRSSI_parameter];
            _filterName = [FEUserDefaultCache getName_prefix_parameter];
        } else if (FEDFUPage == _pageType) {
            _filterEnabled = [FEUserDefaultCache getFilterEnabled_update];
            _minimumRSSI = [FEUserDefaultCache getMinimumRSSI_update];
            _filterName = [FEUserDefaultCache getName_prefix_update];
        } else {
            _filterEnabled = [FEUserDefaultCache getFilterEnabled];
            _minimumRSSI = [FEUserDefaultCache getMinimumRSSI];
            _filterName = [FEUserDefaultCache getName_prefix];
        }
        
        if (-100.f > _minimumRSSI || -30.f < _minimumRSSI) {
            _minimumRSSI = -100.f;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    headView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    self.tableView.tableHeaderView = headView;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    self.tableView.tableFooterView = footView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        FEFilterRSSITableViewCell *filterCell = [[[NSBundle mainBundle] loadNibNamed:@"FEFilterRSSITableViewCell" owner:self options:nil] firstObject];
        [filterCell.filterEnableSwitch addTarget:self action:@selector(filterSwitchTaped:) forControlEvents:UIControlEventValueChanged];
        filterCell.filterEnableSwitch.on = self.filterEnabled;
        filterCell.nameTextField.text = _filterName;
        filterCell.nameTextField.delegate = self;
        self.filterEnabledSwitch = filterCell.filterEnableSwitch;
        return filterCell;
    } else {
        FEMinimumRSSITableViewCell *minimumCell = [[[NSBundle mainBundle] loadNibNamed:@"FEMinimumRSSITableViewCell" owner:self options:nil] firstObject];
        [minimumCell.minimumRSSISlider addTarget:self action:@selector(settingRSSI:) forControlEvents:UIControlEventValueChanged];
        minimumCell.minimumRSSILabel.text = [NSString stringWithFormat:@"%.f dB", self.minimumRSSI];
        self.rssiSlider = minimumCell.minimumRSSISlider;
        self.rssiSlider.value = self.minimumRSSI;
        self.cell = minimumCell;
        return minimumCell;
    }
}

- (void)filterSwitchTaped:(UISwitch *)sender {
    _filterEnabled = sender.isOn;

    if (FECommandPage == _pageType) {
        [FEUserDefaultCache saveFilterEnabled_parameter:_filterEnabled];
    } else if (FEDFUPage == _pageType) {
        [FEUserDefaultCache saveFilterEnabled_update:_filterEnabled];
    } else {
        [FEUserDefaultCache saveFilterEnabled:_filterEnabled];
    }
}

- (void)settingRSSI:(UISlider *)slider {
    _minimumRSSI = slider.value;
    _cell.minimumRSSILabel.text = [NSString stringWithFormat:@"%.f dB", slider.value];

    if (FECommandPage == _pageType) {
        [FEUserDefaultCache saveMinimumRSSI_parameter:_minimumRSSI];
    } else if (FEDFUPage == _pageType) {
        [FEUserDefaultCache saveMinimumRSSI_update:_minimumRSSI];
    } else {
        [FEUserDefaultCache saveMinimumRSSI:_minimumRSSI];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        return 88.0;
    } else {
        return 44.0;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string rangeOfString:@"\n"].location != NSNotFound || [string rangeOfString:@"\x20"].location != NSNotFound) {
        return NO;
    }
    _filterName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (FECommandPage == _pageType) {
        [FEUserDefaultCache saveName_prefix_parameter:_filterName];
    } else if (FEDFUPage == _pageType) {
        [FEUserDefaultCache saveName_prefix_update:_filterName];
    } else {
        [FEUserDefaultCache saveName_prefix:_filterName];
    }
    
    return YES;
}

@end
