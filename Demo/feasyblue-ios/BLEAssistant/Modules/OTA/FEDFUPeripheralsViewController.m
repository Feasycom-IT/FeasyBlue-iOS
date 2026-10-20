//
//  FEDFUPeripheralsViewController.m
//  BLEAssistant
//
//  Created by LiDong on 2021/4/21.
//  Copyright © 2021 feasycom. All rights reserved.
//

#import "FEDFUPeripheralsViewController.h"
#import "FEDFUUpdateDetailViewController.h"

@interface FEDFUPeripheralsViewController ()
@end

@implementation FEDFUPeripheralsViewController

- (void)dealloc {
    NSLog(@"dealloc_FEDFUPeripheralsViewController");
}

- (instancetype)init {
    if (self = [super initWithPageType:FEDFUPage]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FEPeripheral *peripheral = self.peripherals[indexPath.row];
    FEDFUUpdateDetailViewController *viewController = [[FEDFUUpdateDetailViewController alloc] initWithPeripheral:peripheral peripherals:self.peripherals];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
