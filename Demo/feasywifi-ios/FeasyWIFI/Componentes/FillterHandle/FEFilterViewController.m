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

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) FEMinimumRSSITableViewCell *cell;
@property (nonatomic, strong) UISwitch *filterEnabledSwitch;
@property (nonatomic, strong) UISlider *rssiSlider;

@property (nonatomic, strong) FEFilterModel *beforeFilter;
@property (nonatomic, strong) FEFilterModel *currentFilter;

@end

@implementation FEFilterModel
- (instancetype)init {
    if (self = [super init]) {
        self.isFilterName = NO;
        self.filterName = @"";
        self.filterMinimumRSSI = -100;
    }
    return self;
}

- (void)setFilterMinimumRSSI:(float)filterMinimumRSSI {
    _filterMinimumRSSI = filterMinimumRSSI;
    if (filterMinimumRSSI < -100.f) {
        _filterMinimumRSSI = -100.f;
    }
    if (filterMinimumRSSI > -30.f) {
        _filterMinimumRSSI = -30.f;
    }
}
@end

@implementation FEFilterViewController

- (instancetype)initWithFilterModel:(FEFilterModel *)beforeFilter didChangedFilter:(DidChangedFilterBlock )didChangedFilterBlock {
    if (self = [super init]) {
        _beforeFilter = beforeFilter;
        _currentFilter = beforeFilter;
        _didChangedFilterBlock = didChangedFilterBlock;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.didChangedFilterBlock) {
        self.didChangedFilterBlock(self.currentFilter);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LS(@"Filter");
    self.hidesBottomBarWhenPushed = YES;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.tableFooterView = [UIView new];
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
        filterCell.filterEnableSwitch.on = self.beforeFilter.isFilterName;
        filterCell.nameTextField.text = self.beforeFilter.filterName;
        filterCell.nameTextField.delegate = self;
        self.filterEnabledSwitch = filterCell.filterEnableSwitch;
        return filterCell;
    } else {
        FEMinimumRSSITableViewCell *minimumCell = [[[NSBundle mainBundle] loadNibNamed:@"FEMinimumRSSITableViewCell" owner:self options:nil] firstObject];
        [minimumCell.minimumRSSISlider addTarget:self action:@selector(settingRSSI:) forControlEvents:UIControlEventValueChanged];
        minimumCell.minimumRSSILabel.text = [NSString stringWithFormat:@"%.f dB", self.beforeFilter.filterMinimumRSSI];
        self.rssiSlider = minimumCell.minimumRSSISlider;
        self.rssiSlider.value = self.beforeFilter.filterMinimumRSSI;
        self.cell = minimumCell;
        return minimumCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 44.0;
    } else {
        return 88.0;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string rangeOfString:@"\n"].location != NSNotFound || [string rangeOfString:@"\x20"].location != NSNotFound) {
        return NO;
    }
    self.currentFilter.filterName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

- (void)filterSwitchTaped:(UISwitch *)sender {
    self.currentFilter.isFilterName = sender.isOn;
}

- (void)settingRSSI:(UISlider *)slider {
    self.currentFilter.filterMinimumRSSI = slider.value;
    self.cell.minimumRSSILabel.text = [NSString stringWithFormat:@"%.f dB", slider.value];
}

@end
