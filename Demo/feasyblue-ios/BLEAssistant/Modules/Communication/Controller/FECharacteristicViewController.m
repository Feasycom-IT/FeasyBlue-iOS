//
//  FECharacteristicViewController.m
//  BLEAssistant
//
//  Created by ericj on 2018/1/8.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#define cellID @"cellID"

#import "FECharacteristicViewController.h"
#import "FEPeripheral.h"

extern BOOL _sendWithResponse;

@interface FECharacteristicViewController ()

@property (nonatomic, strong) FEPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, strong) NSMutableArray *properties;
@property (nonatomic, strong) UILabel *characteristicValueLabel;

@end

@implementation FECharacteristicViewController

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
    if (self = [super init]) {
        _peripheral = peripheral;
        _characteristic = characteristic;
        _properties = [[NSMutableArray alloc] init];
        
        const CBCharacteristicProperties properties = _characteristic.properties;
        
        if (properties & CBCharacteristicPropertyNotify){
            [_properties addObject:@"Notify"];
        }
        if (properties & CBCharacteristicPropertyIndicate) {
            [_properties addObject:@"Indicate"];
        }
        if (properties & CBCharacteristicPropertyWrite){
            [_properties addObject:@"Write"];
        }
        if (properties & CBCharacteristicPropertyWriteWithoutResponse){
            [_properties addObject:@"Write Without Response"];
        }
        if (properties & CBCharacteristicPropertyRead){
            [_properties addObject:@"Read"];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _peripheral.displayName;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
    self.tableView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    const CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    
    // 表头
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 120)];
    headerView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    
    UILabel *uuidLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, screenWidth-16, 120)];
    [uuidLabel setNumberOfLines:0];
    uuidLabel.font = [UIFont systemFontOfSize:15];
    uuidLabel.text = [NSString stringWithFormat:@"%@\n ↳ %@\n      ↳ %@", _peripheral.identifier.UUIDString, _characteristic.service.UUID.UUIDString, _characteristic.UUID.UUIDString];
    [headerView addSubview:uuidLabel];
    self.tableView.tableHeaderView = headerView;
    
    // 表尾
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, screenWidth - 16, 50)];
    dataLabel.text = @"";
    dataLabel.numberOfLines = 0;
    [footerView addSubview:dataLabel];
    _characteristicValueLabel = dataLabel;
    self.tableView.tableFooterView = footerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.peripheral updateDescriptors];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return _characteristic.descriptors.count;
    return _properties.count;  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *descCellID = @"descCellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:descCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:descCellID];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        CBDescriptor *descriptor = _characteristic.descriptors[indexPath.row];
        
        id v = descriptor.value;
        cell.textLabel.text = v ? [NSString stringWithFormat:@"%@", v] : @"(null)";
        cell.detailTextLabel.text = descriptor.UUID.UUIDString;
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSString *property = _properties[indexPath.row];
    cell.textLabel.text = property;
    
    if ([property isEqualToString:@"Notify"]) {
        if ([_characteristic isNotifying]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if ([property isEqualToString:@"Indicate"]) {
        if ([_characteristic isNotifying]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if ([property isEqualToString:@"Write"]) {
        if (_sendWithResponse && [[_peripheral writeCharacteristic] isEqual:_characteristic]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if ([property isEqualToString:@"Write Without Response"]) {
        if (!_sendWithResponse && [[_peripheral writeWithoutResponseCharacteristic] isEqual:_characteristic]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }
    
    const NSInteger row = indexPath.row;
    NSString *property = _properties[row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    const UITableViewCellAccessoryType accessoryType = cell.accessoryType;
    
    if ([property isEqualToString:@"Notify"]) {
        if (UITableViewCellAccessoryNone == accessoryType) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [_peripheral setupNotifyValue:YES forCharacteristic:_characteristic];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [_peripheral setupNotifyValue:NO forCharacteristic:_characteristic];
        }
    } else if ([property isEqualToString:@"Indicate"]) {
        if (UITableViewCellAccessoryNone == accessoryType) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [_peripheral setupNotifyValue:YES forCharacteristic:_characteristic];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [_peripheral setupNotifyValue:NO forCharacteristic:_characteristic];
        }
    } else if ([property isEqualToString:@"Write"]) {
        if (UITableViewCellAccessoryNone == accessoryType) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            [_peripheral setupWriteCharacteristic:_characteristic];
            _sendWithResponse = YES;
            
            const NSInteger propertiesCount = _properties.count;
            
            for (NSInteger i = 0; i < propertiesCount; i ++) {
                if ([_properties[i] isEqualToString:@"Write Without Response"]) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
    } else if ([property isEqualToString:@"Write Without Response"]) {
        if (UITableViewCellAccessoryNone == accessoryType) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            [_peripheral setupWriteWithoutResponseCharacteristic:_characteristic];
            _sendWithResponse = NO;
            
            const NSInteger propertiesCount = _properties.count;
            
            for (NSInteger i = 0; i < propertiesCount; i ++) {
                if ([_properties[i] isEqualToString:@"Write"]) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
    } else {
        [_peripheral readValueForCharacteristic:_characteristic];
        _characteristicValueLabel.text = [NSString stringWithFormat:@"%@",_characteristic.value];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0) ? @"DESCRIPTORS" : @"PROPERTIES";
}

@end


