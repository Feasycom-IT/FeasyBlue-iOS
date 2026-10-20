//
//  FERSSIWhileConnectedVC.m
//  BLEAssistant
//
//  Created by chenchanghua on 2023/3/16.
//  Copyright © 2023 feasycom. All rights reserved.
//

#import "FERSSIWhileConnectedVC.h"

@interface FERSSIWhileConnectedVC ()

@property (nonatomic, strong) NSMutableArray *RSSIReceivedArray;
@property (nonatomic, strong) UITextView *rssiTextView;
@property (nonatomic, strong) UIButton *flagRSSIDataBtn;
@property (nonatomic, strong) UIButton *clearRSSIDataBtn;
@property (nonatomic, strong) UIButton *exportRSSIDataBtn;

@property (nonatomic, strong) NSFileHandle *fileHandler;// 文件句柄
@property (nonatomic, copy) NSString *filePath;// 接收数据的文件地址

@end

@implementation FERSSIWhileConnectedVC

- (void)dealloc {
    // 清空记录接受数据的文件
    [self.fileHandler truncateFileAtOffset:0];
}

- (instancetype)init {
    if (self = [super init]) {
        
        // 以当前时间为名称的fsc文件地址
        NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSDate *dateNow = [[NSDate alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *fileName = [NSString stringWithFormat:@"RSSI %@", [[dateFormatter stringFromDate:dateNow] stringByAppendingString:@".txt"]];
        self.filePath = [folderPath stringByAppendingPathComponent:fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:_filePath]) {
            [fileManager createFileAtPath:_filePath contents:nil attributes:nil];
        }
        self.fileHandler = [NSFileHandle fileHandleForWritingAtPath:_filePath];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViewContent];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.rssiTextView.text = [NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:nil];
}

- (void)setupViewContent {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.rssiTextView = [[UITextView alloc] init];
    self.rssiTextView.backgroundColor = [UIColor lightGrayColor];
    self.rssiTextView.editable = NO;
    [self.view addSubview:self.rssiTextView];
    [self.rssiTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(100);
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-200);
    }];
    
    self.flagRSSIDataBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flagRSSIDataBtn.backgroundColor = [UIColor systemBlueColor];
    [self.flagRSSIDataBtn setTitle:@"🌟做个标记🌟" forState:UIControlStateNormal];
    [self.flagRSSIDataBtn addTarget:self action:@selector(flagRSSIDataBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flagRSSIDataBtn];
    [self.flagRSSIDataBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.rssiTextView.mas_bottom).offset(15);
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
    }];
    
    self.clearRSSIDataBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.clearRSSIDataBtn.backgroundColor = [UIColor systemBlueColor];
    [self.clearRSSIDataBtn setTitle:@"清空数据" forState:UIControlStateNormal];
    [self.clearRSSIDataBtn addTarget:self action:@selector(clearRSSIDataBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clearRSSIDataBtn];
    [self.clearRSSIDataBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.flagRSSIDataBtn.mas_bottom).offset(15);
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
    }];
    
    self.exportRSSIDataBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.exportRSSIDataBtn.backgroundColor = [UIColor systemBlueColor];
    [self.exportRSSIDataBtn setTitle:@"导出数据" forState:UIControlStateNormal];
    [self.exportRSSIDataBtn addTarget:self action:@selector(exportRSSIDataBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exportRSSIDataBtn];
    [self.exportRSSIDataBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.clearRSSIDataBtn.mas_bottom).offset(30);
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
    }];
    
}

- (NSMutableArray *)RSSIReceivedArray {
    if (!_RSSIReceivedArray) {
        _RSSIReceivedArray = [NSMutableArray array];
    }
    return _RSSIReceivedArray;
}

- (void)flagRSSIDataBtnAction {
    
    NSMutableString *text = self.rssiTextView.text.mutableCopy;
    [text appendString:@"🌟做个标记🌟\n"];
    self.rssiTextView.text = text;
    
    [self.fileHandler seekToEndOfFile];
    [self.fileHandler writeData:[@"🌟做个标记🌟\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)clearRSSIDataBtnAction {
    [self.fileHandler truncateFileAtOffset:0];
    self.rssiTextView.text = [NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:nil];
}

- (void)exportRSSIDataBtnAction {
    
    UIActivityViewController *viewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:_filePath]] applicationActivities:nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        viewController.popoverPresentationController.sourceView = self.view;
        viewController.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width/2.f, self.view.frame.size.height/2.f, 1.f, 1.f);
        viewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    
    [self.navigationController presentViewController:viewController animated:YES completion:NULL];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)valueForRSSIChanged:(NSNumber *)rssi {
    
    [self.RSSIReceivedArray addObject:rssi];
    
    NSDate *dateNow = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSMutableString *text = self.rssiTextView.text.mutableCopy;
    [text appendString:[NSString stringWithFormat:@"%@  %ld\n", [dateFormatter stringFromDate:dateNow], rssi.integerValue]];
    self.rssiTextView.text = text;
    
    [self.fileHandler seekToEndOfFile];
    [self.fileHandler writeData:[[NSString stringWithFormat:@"%@  %ld\n", [dateFormatter stringFromDate:dateNow], rssi.integerValue] dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
