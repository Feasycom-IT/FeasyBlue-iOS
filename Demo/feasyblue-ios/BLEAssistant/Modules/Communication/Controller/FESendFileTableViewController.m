//
//  FESendFileTableViewController.m
//  BLEAssistant
//
//  Created by yumingyue on 2016/11/20.
//  Copyright © 2016年 feasycom. All rights reserved.
//

#import "FESendFileTableViewController.h"

#define BTN1  1000*10
#define BTN2  1000*50
#define BTN3  1000*100
#define BTN4  1000*200
#define BTN5  1000*500
#define BTN6  1000*1000
#define BTN7  1000*1000*2
#define BTN8  1000*1000*5
#define BTN9  1000*1000*10
#define BTN10 1000*1000*20

@interface FESendFileTableViewController ()<UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate ,UIDocumentPickerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *byteCountTF;
@property (weak, nonatomic) IBOutlet UISegmentedControl *byteTypeSC;

@end

@implementation FESendFileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LS(@"sendFile");
}

- (void)sendDataWithLength:(const NSUInteger)length {
    NSMutableData *data = [[NSMutableData alloc] initWithLength:length];
    
    generateTestFileData(0, (unsigned char*)[data mutableBytes], (unsigned int)length);
    
    [self.delegate sendData:data];
}

unsigned int generateTestFileData(unsigned int index,
                                  unsigned char *buffer,
                                  unsigned int buffer_size)
{
    unsigned char *buffw = buffer;
    char char_table[17] = "0123456789ABCDEF";
    unsigned int i;
    
    if (!buffw) { return 0; }
    if (buffer_size % 10 != 0) { return 0; }
    
    for (i = 0; i < buffer_size; i += 10)
    {
        buffw[i] = '[';
        buffw[i+8] = char_table[(index >> 0) & 0x0000000F];
        buffw[i+7] = char_table[(index >> 4) & 0x0000000F];
        buffw[i+6] = char_table[(index >> 8) & 0x0000000F];
        buffw[i+5] = char_table[(index >> 12) & 0x0000000F];
        buffw[i+4] = char_table[(index >> 16) & 0x0000000F];
        buffw[i+3] = char_table[(index >> 20) & 0x0000000F];
        buffw[i+2] = char_table[(index >> 24) & 0x0000000F];
        buffw[i+1] = char_table[(index >> 28) & 0x0000000F];
        buffw[i+9] = ']';
        index += 1;
    }
    
    return index;
}

// 10进制转为16进制
- (NSString *)turnStringToSignedHex:(int)number {
    if (number == 0) {
        return @"0";
    } else {
        char hexChar[20];
        sprintf(hexChar, "%x", number);
        NSString *hexStr = [NSString stringWithCString:hexChar encoding:NSUTF8StringEncoding];
        for (int i = 0; i < hexStr.length; i++) {
            UniChar s1 = [hexStr characterAtIndex:i];
            if (s1 >= 'a' && s1 <= 'z') {
                hexStr = (NSMutableString *)[hexStr stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithFormat:@"%c",s1-32]];
            }
        }
        return hexStr;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.byteCountTF.text = [FEUserDefaultCache getSf_byteCount];
    
    self.byteCountTF.delegate = self;
    if ([self.byteCountTF.text isEqualToString:@""]) {
        self.byteCountTF.text = [NSString stringWithFormat:@"%d", 50];
    }
    self.byteTypeSC.selectedSegmentIndex = [FEUserDefaultCache getSf_byteTypeSC];
    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    [self.byteTypeSC addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    if (selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:animated];
    }
}

- (void)segmentAction:(UISegmentedControl *)segmentedControl {
    NSInteger index = segmentedControl.selectedSegmentIndex;
    if (index == 2 && [self.byteCountTF.text integerValue]*1000*1000 > 50*1000*1000) {
        [self.byteCountTF setText:@"50"];
    } else if (index == 1 && [self.byteCountTF.text integerValue]*1000 > 50*1000*1000) {
        [self.byteCountTF setText:@"50000"];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger multiple = 1;
    switch (self.byteTypeSC.selectedSegmentIndex) {
        case 0:
            multiple = 1;
            break;
        case 1:
            multiple = 1000;
            break;
        case 2:
            multiple = 1000*1000;
            break;
    }
    if ([textField.text integerValue]*multiple*10 >= 50*1000*1000) {
        if ([string isEqual:@""]) {
            return YES;
        } else if (([textField.text integerValue]*multiple*10 + [string integerValue]) > 50*1000*1000){
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [FEUserDefaultCache saveSf_byteCount:self.byteCountTF.text];
    [FEUserDefaultCache saveSf_byteTypeSC:self.byteTypeSC.selectedSegmentIndex];
}

- (IBAction)OKBtn:(UIButton *)sender {
    NSInteger number = [self.byteCountTF.text integerValue];
    NSInteger multiple;
    switch (self.byteTypeSC.selectedSegmentIndex) {
        case 0:
            multiple = 1;
            break;
        case 1:
            multiple = 1000;
            break;
        case 2:
            multiple = 1000*1000;
            break;
        default:
            multiple = 1000;
            break;
    }
    number = number*multiple;
    if (number == 0) {
        [self showAlertControllerWithTitle:LS(@"Unable to send 0 bytes of data")];
        return ;
    }
    //加载数据
    [self.navigationController popViewControllerAnimated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendDataWithLength:number];
    });
}

- (IBAction)clickBtn:(UIButton *)sender {
    NSInteger stringSendLength = 0;
    switch (sender.tag) {
        case 1001:
            stringSendLength = BTN1;
            break;
        case 1002:
            stringSendLength = BTN2;
            break;
        case 1003:
            stringSendLength = BTN3;
            break;
        case 1004:
            stringSendLength = BTN4;
            break;
        case 1005:
            stringSendLength = BTN5;
            break;
        case 1006:
            stringSendLength = BTN6;
            break;
        case 1007:
            stringSendLength = BTN7;
            break;
        case 1008:
            stringSendLength = BTN8;
            break;
        case 1009:
            stringSendLength = BTN9;
            break;
        case 1010:
            stringSendLength = BTN10;
            break;
        default:
            break;
    }
    
    //加载数据
    [self.navigationController popViewControllerAnimated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendDataWithLength:stringSendLength];
    });
}

- (IBAction)fileSelect:(UIButton *)sender {
    if (2000 == sender.tag) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        [imagePicker setDelegate:self];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self.navigationController presentViewController:imagePicker animated:YES completion:NULL];
    } else if (2001 == sender.tag){
        NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code ", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
        
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
        documentPicker.delegate = self;
        documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:documentPicker animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    const NSInteger row = indexPath.row;
    if (6 == row) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    BOOL canAccessingResource = [url startAccessingSecurityScopedResource];
    if(canAccessingResource) {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
            NSData *fileData = [NSData dataWithContentsOfURL:newURL];
            [self dismissViewControllerAnimated:YES completion:^{
                [self.navigationController popViewControllerAnimated:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate sendData:fileData];
                });
            }];
         }];
        if (error) {
             
         }
     } else {
      // startAccessingSecurityScopedResource fail
     }
     [url stopAccessingSecurityScopedResource];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(image, 0.19);
    
    [self.delegate sendData:data];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
