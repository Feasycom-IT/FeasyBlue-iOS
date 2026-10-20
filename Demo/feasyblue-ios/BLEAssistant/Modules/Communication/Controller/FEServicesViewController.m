//
//  FEServicesViewController.m
//  BLEAssistant
//
//  Created by yumingyue on 2016/11/20.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import "FEServicesViewController.h"
#import "FECharacteristicViewController.h"
#import "NSString+FEString.h"
#import "FEPeripheral.h"
#import "Masonry.h"

extern BOOL _sendWithResponse;

@interface FEServicesViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) FEPeripheral *peripheral;
@property (nonatomic, copy) NSArray *services;
@property (nonatomic, weak) UITextField *mtuTextField;
@property (nonatomic, copy) NSArray *advertisementKeys;
@property (nonatomic, copy) NSArray *advertisementValues;
@property (nonatomic, strong) UISwitch *syncSwitch;
@property (nonatomic, assign) int mtu;

@end

@implementation FEServicesViewController

- (instancetype)initWithPeripheral:(FEPeripheral *)peripheral {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _peripheral = peripheral;
        //解析广播数据
        [self parseAdvertisementData];
        _services = _peripheral.allServices;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //读取用户偏好设置
    NSInteger value = [FEUserDefaultCache getMtu];
    
    if (_sendWithResponse) {
        //        _mtu = (int)[_peripheral.peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithResponse];
    } else {
        //        _mtu = (int)[_peripheral.peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse];
    }
    
    if (value < _mtu) {
        value = _mtu;
    }
    if (0 < value) {
        self.mtuTextField.text = [NSString stringWithFormat:@"%ld", (long)value];
    }
    self.mtuTextField.placeholder = [NSString stringWithFormat:@"20~%d", (int)_mtu];
    
    self.syncSwitch.on = [FEUserDefaultCache getSync];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _services.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return [_advertisementKeys count];
    }
    
    CBService *service = _services[section - 1];
    
    return service.characteristics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.numberOfLines = 0;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;
    
    if (0 == section) {
        cell.textLabel.text = _advertisementValues[row];
        cell.detailTextLabel.text = _advertisementKeys[row];
    } else {
        CBService *service = _services[section - 1];
        CBCharacteristic *characteristic = service.characteristics[row];
        NSString *UUIDString = service.UUID.UUIDString;
        
        if ([UUIDString isEqualToString:@"180A"]){
            cell.textLabel.text = [self nameForCharacteristic:characteristic];
            cell.detailTextLabel.text = [self stringValueForCharacteristic:characteristic];
        } else {
            NSMutableString *characteristicString = [[NSMutableString alloc] initWithString:LS(@"Properties: ")];
            
            if (characteristic.properties & CBCharacteristicPropertyRead){
                //拿到值可读的特征了
                [characteristicString appendString:LS(@"readValue")];
            }
            if (characteristic.properties & CBCharacteristicPropertyNotify){
                //拿到可读的无反馈特征了
                [characteristicString appendString:LS(@"readNoRe")];
            }
            if (characteristic.properties & CBCharacteristicPropertyIndicate){
                //拿到可读的特征了
                [characteristicString appendString:LS(@"readRe")];
            }
            if (characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse){
                //拿到可写WithoutResponse的特征了
                [characteristicString appendString:LS(@"writeNoRe")];
            }
            if (characteristic.properties & CBCharacteristicPropertyWrite){
                //拿到可写的特征了
                [characteristicString appendString:LS(@"writeRe")];
            }
            cell.textLabel.text = characteristic.UUID.UUIDString;
            cell.detailTextLabel.text = characteristicString;
        }
    }
    return cell;
}

// 自定义行高
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath{
    return 50;
}

// 设置分区头区域的高度
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

// 设置分区头部
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 15, 40)];
    lab.font = [UIFont systemFontOfSize:15];
    lab.numberOfLines = 0;
    if (section == 0) {
        lab.text = @"Advertising Data";
    } else {
        CBService *service = _services[section - 1];
        
        if (![service.UUID.UUIDString isEqualToString:@"180A"]){
            NSString *serviceName = [NSString stringWithFormat:@"%@:%@",LS(@"service"), service.UUID.UUIDString];
            lab.text = serviceName;
        }else{
            lab.text = LS(@"deviceInformation");
        }
    }
    [view addSubview:lab];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.mtuTextField resignFirstResponder];
    
    const NSInteger section = indexPath.section;
    
    if (0 < section) {
        CBService *service = _services[section - 1];
        
        //不是设备信息才处理
        if (![service.UUID.UUIDString isEqualToString:@"180A"]){
            CBCharacteristic *characteristic = service.characteristics[indexPath.row];
            FECharacteristicViewController *viewController = [[FECharacteristicViewController alloc] initWithPeripheral:_peripheral characteristic:characteristic];
            
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

// 当前行是否可以编辑
-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath{
    const NSInteger section = indexPath.section;
    
    if (0 < section) {
        CBService *service = _services[section - 1];
        CBCharacteristic *characteristic = service.characteristics[indexPath.row];
        
        if (characteristic.properties & CBCharacteristicPropertyRead) {
            return YES;
        }
    }
    return NO;
}

// 当前行是什么编辑样式
-(UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath{
    if ([self tableView:tableView canEditRowAtIndexPath:indexPath]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

// 设置左滑按钮
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBService *service = _services[indexPath.section - 1];
    CBCharacteristic *characteristic = service.characteristics[indexPath.row];
    
    if (characteristic.properties & CBCharacteristicPropertyRead) {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:LS(@"read") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            NSData *data = characteristic.value;
            NSString *title = [NSString stringWithFormat:@"%@(%ld %@)\r\n0x%@", LS(@"hex"), data.length, LS(@"bytes"), [NSString dataToHex:data]];
            NSString *message =  [NSString stringWithFormat:@"UTF-8: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            
            [self showAlertControllerWithTitle:title message:message];
        }];
        
        action.backgroundColor = [UIColor blueColor];
        
        return @[action];
    }
    
    return nil;
}

- (NSString*)nameForCharacteristic:(CBCharacteristic*)characteristic{
    NSString *UUIDString = characteristic.UUID.UUIDString;
    
    if ([UUIDString isEqualToString:@"2A23"]) {
        return LS(@"systemID");
    } else if ([UUIDString isEqualToString:@"2A24"]) {
        return LS(@"modelNumber");
    } else if ([UUIDString isEqualToString:@"2A25"]) {
        return LS(@"serialNumber");
    } else if ([UUIDString isEqualToString:@"2A26"]) {
        return LS(@"firmwareRevision");
    } else if ([UUIDString isEqualToString:@"2A27"]) {
        return LS(@"hardwareRevision");
    } else if ([UUIDString isEqualToString:@"2A28"]) {
        return LS(@"softwareRevision");
    } else if ([UUIDString isEqualToString:@"2A29"]) {
        return LS(@"manufacturerName");
    } else {
        NSString *name = characteristic.description;
        NSRange range = [name rangeOfString:@"UUID = "];
        
        if (NSNotFound != range.location) {
            name = [name substringFromIndex:range.location + range.length];
            range = [name rangeOfString:@","];
            
            if (NSNotFound != range.location) {
                name = [name substringToIndex:range.location];
                name = [NSString stringWithFormat:@"%@(%@)", name, characteristic.UUID.UUIDString];
            }
        }
        return name;
    }
}


- (NSString*)stringValueForCharacteristic:(CBCharacteristic*)characteristic {
    NSString *UUIDString = characteristic.UUID.UUIDString;
    NSString *string = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    if ([UUIDString isEqualToString:@"2A25"]) {
        NSMutableString *stringTemp = [[NSMutableString alloc] initWithCapacity:(string.length * 3 + 1) / 2];
        
        if (string.length == 12) {
            for (NSInteger i = 0; i < 12; i += 2) {
                if (0 < i) {
                    [stringTemp appendString:@":"];
                }
                [stringTemp appendString:[string substringWithRange:NSMakeRange(i, 2)]];
            }
            string = [stringTemp copy];
        }
    }
    if (nil == string || [UUIDString isEqualToString:@"2A50"]) {
        return [NSString stringWithFormat:@"%@", characteristic.value];
    }
    return string;
}

- (void)parseAdvertisementData {
    NSDictionary *advertisementData = _peripheral.advertisementData;
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    
    if (![advertisementData isKindOfClass:[NSDictionary class]] || advertisementData.count == 0) {
        _advertisementKeys = @[];
        _advertisementValues = @[];
        return;
    }
    
    NSArray<NSString *> *sortedKeys =
    [[advertisementData allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [[obj1 description] compare:[obj2 description]];
    }];
    
    for (id rawKey in sortedKeys) {
        id rawValue = advertisementData[rawKey];
        
        NSString *keyStr = [self prettyAdvKey:rawKey];
        NSString *valueStr = [self prettyAdvValue:rawValue forKey:rawKey];
        
        if (keyStr.length == 0) keyStr = [rawKey description];
        if (valueStr.length == 0) valueStr = @"-";
        
        [keys addObject:keyStr];
        [values addObject:valueStr];
    }
    
    _advertisementKeys = [keys copy];
    _advertisementValues = [values copy];
}

#pragma mark - Pretty

- (NSString *)prettyAdvKey:(id)rawKey {
    NSString *k = [rawKey description];
    static NSDictionary *map;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{
            @"kCBAdvDataIsConnectable": @"Device Is Connectable",
            @"kCBAdvDataLocalName": @"Local Name",
            @"kCBAdvDataManufacturerData": @"Manufacturer Data",
            @"kCBAdvDataServiceUUIDs": @"Service UUIDs",
            @"kCBAdvDataServiceData": @"Service Data",
            @"kCBAdvDataTxPowerLevel": @"Tx Power Level",
            @"kCBAdvDataTimestamp": @"Timestamp",
            @"kCBAdvDataRxPrimaryPHY": @"Rx Primary PHY",
            @"kCBAdvDataRxSecondaryPHY": @"Rx Secondary PHY",
            @"kCBAdvDataSolicitedServiceUUIDs": @"Solicited Service UUIDs",
            @"kCBAdvDataOverflowServiceUUIDs": @"Overflow Service UUIDs",
        };
    });
    return map[k] ?: k;
}

- (NSString *)prettyAdvValue:(id)rawValue forKey:(id)rawKey {
    if (!rawValue || rawValue == [NSNull null]) return @"-";
    
    NSString *k = [rawKey description];
    
    if ([k isEqualToString:@"kCBAdvDataIsConnectable"]) {
        if ([rawValue respondsToSelector:@selector(integerValue)]) {
            return ([rawValue integerValue] == 1) ? @"YES" : @"NO";
        }
    }

    if ([k isEqualToString:@"kCBAdvDataManufacturerData"] && [rawValue isKindOfClass:[NSData class]]) {
        NSData *d = (NSData *)rawValue;
        NSString *hex = [self hexStringFromData:d maxBytes:32];
        return [NSString stringWithFormat:@"len=%lu, hex=%@", (unsigned long)d.length, hex];
    }
    
    if (([k hasSuffix:@"ServiceUUIDs"] || [k isEqualToString:@"kCBAdvDataServiceUUIDs"]) &&
        [rawValue isKindOfClass:[NSArray class]]) {
        NSArray *arr = (NSArray *)rawValue;
        return [[arr valueForKey:@"description"] componentsJoinedByString:@", "];
    }
    
    if ([k isEqualToString:@"kCBAdvDataServiceData"] && [rawValue isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)rawValue;
        NSMutableArray *parts = [NSMutableArray array];
        for (id kk in dict.allKeys) {
            id vv = dict[kk];
            NSString *vvStr = nil;
            if ([vv isKindOfClass:[NSData class]]) {
                vvStr = [NSString stringWithFormat:@"len=%lu, hex=%@",
                         (unsigned long)((NSData *)vv).length,
                         [self hexStringFromData:(NSData *)vv maxBytes:32]];
            } else {
                vvStr = [vv description];
            }
            [parts addObject:[NSString stringWithFormat:@"%@: %@", [kk description], vvStr]];
        }

        [parts sortUsingSelector:@selector(compare:)];
        return [parts componentsJoinedByString:@" | "];
    }
    
    if ([rawValue isKindOfClass:[NSData class]]) {
        NSData *d = (NSData *)rawValue;
        return [NSString stringWithFormat:@"len=%lu, hex=%@",
                (unsigned long)d.length,
                [self hexStringFromData:d maxBytes:32]];
    }
    
    if ([rawValue isKindOfClass:[NSNumber class]]) {
        return [rawValue description];
    }
    
    NSString *s = [rawValue description];
    if (s.length > 300) {
        s = [[s substringToIndex:300] stringByAppendingString:@"..."];
    }
    return s;
}

- (NSString *)hexStringFromData:(NSData *)data maxBytes:(NSUInteger)maxBytes {
    if (![data isKindOfClass:[NSData class]] || data.length == 0) return @"";
    NSUInteger len = MIN(data.length, maxBytes);
    const unsigned char *bytes = data.bytes;
    NSMutableString *hex = [NSMutableString stringWithCapacity:len * 3];
    for (NSUInteger i = 0; i < len; i++) {
        [hex appendFormat:@"%02X", bytes[i]];
        if (i + 1 < len) [hex appendString:@" "];
    }
    if (data.length > maxBytes) {
        [hex appendString:@" ..."];
    }
    return hex;
}

// 设置界面
- (void)setupUI {
    // 添加表头
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    self.tableView.tableHeaderView = headView;
    UILabel *mtuLabel = [[UILabel alloc] init];//WithFrame:CGRectMake(15, 8, 50, 34)];
    mtuLabel.font = [UIFont systemFontOfSize:13];
    mtuLabel.text = @"MTU:";
    [headView addSubview:mtuLabel];
    UITextField *mtuField = [[UITextField alloc] init];//WithFrame:CGRectMake(65, 10, self.view.frame.size.width-150, 30)];
    mtuField.borderStyle = UITextBorderStyleRoundedRect;
    mtuField.font = [UIFont systemFontOfSize:13];
    mtuField.keyboardType = UIKeyboardTypeNumberPad;
    [headView addSubview:mtuField];
    self.mtuTextField = mtuField;
    self.mtuTextField.delegate = self;
    
    UISwitch *sySwitch = [[UISwitch alloc] init];
    sySwitch.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [sySwitch addTarget:self action:@selector(clickSync:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:sySwitch];
    self.syncSwitch = sySwitch;
    
    UILabel *syLabel = [[UILabel alloc] init];
    syLabel.text = @"sync";
    syLabel.textAlignment = NSTextAlignmentRight;
    syLabel.font = [UIFont systemFontOfSize:15];
    [headView addSubview:syLabel];
    
    [sySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headView);
        make.right.equalTo(headView).offset(-15);
    }];
    
    [syLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sySwitch);
        make.width.mas_equalTo(40);
        make.right.equalTo(sySwitch.mas_left).offset(-5);
    }];
    
    [mtuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView).offset(15);
        make.width.mas_equalTo(40);
        make.centerY.equalTo(headView);
    }];
    
    [mtuField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(mtuLabel.mas_right).offset(5);
        make.centerY.equalTo(mtuLabel);
        make.height.mas_equalTo(30);
        make.right.equalTo(syLabel.mas_left).offset(-15);
    }];
    
    //    UILabel *adLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 40)];
    //    adLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //    adLabel.text = @"    ADVERTISEMENTDATA";
    //    adLabel.font = [UIFont systemFontOfSize:15];
    //    [headView addSubview:adLabel];
}

- (void)clickSync:(UISwitch *)sender {
    if (sender.isOn) {
        NSInteger value = [self.mtuTextField.text integerValue];
        if (value < 20 || value > _mtu) {
            [sender setOn:NO];
            [self showAlertControllerWithTitle:[NSString stringWithFormat:@"20~%d", (int)_mtu]];
            return;
        }
    }
    [FEUserDefaultCache saveSync:sender.on];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.mtuTextField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (newString.length > 3) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    const NSInteger value = [textField.text integerValue];
    [FEUserDefaultCache saveMtu:value];
}

// 16进制字符串转nadata
- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


