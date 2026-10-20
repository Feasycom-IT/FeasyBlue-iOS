//
//  NSString+FscKit.m
//  BLEAssistant
//
//  Created by ericj on 2018/1/13.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import "NSString+FscKit.h"

@implementation NSString (FscKit)

//十进制转十六进制
+ (NSString *)stringToHexString:(uint32_t)number {
    NSString *hexString;
    switch (number) {
        case 10:
            hexString = @"A";
            break;
        case 11:
            hexString = @"B";
            break;
        case 12:
            hexString = @"C";
            break;
        case 13:
            hexString = @"D";
            break;
        case 14:
            hexString = @"E";
            break;
        case 15:
            hexString = @"F";
            break;
        default:
            hexString = [NSString stringWithFormat:@"%d",number];
            break;
    }
    return hexString;
}

// 十六进制数据转字符串
+ (NSString *)fan_dataToHexString:(NSData *)data{
    Byte *bytehex =(Byte *) data.bytes;
    NSMutableString *hexString=[[NSMutableString alloc]init];
    for (int i=0; i<data.length; i++) {
        Byte b=bytehex[i];
        [hexString appendFormat:@"%02x",b];
    }
    return hexString;
}
// 转换地址头部
+ (NSString *)transformAddressHandString:(NSString *)string {
    if ([string hasPrefix:@"https://"]) {
        if ([string hasPrefix:@"https://www."]) {
            return @"01";
        }
        return @"03";
    } else if ([string hasPrefix:@"http://"]) {
        if ([string hasPrefix:@"http://www."]) {
            return @"00";
        }
        return @"02";
    }
    return nil;
}
// 地址解析
+ (NSString *)getAddress:(NSString *)string {
    NSString *handStr = [self getAddressHandString:string];
    NSString *bodyStr = [self getAddressFromHexString:string];
    NSString *tailStr = [self tailStringToHexString:string];
    if (!tailStr) {
        return [NSString stringWithFormat:@"%@%@",handStr,bodyStr];
    }
    return [NSString stringWithFormat:@"%@%@%@",handStr,bodyStr,tailStr];
}
// 反转地址头部
+ (NSString *)getAddressHandString:(NSString *)string {
    if ([string hasPrefix:@"03"]) {
        return @"https://";
    } else if ([string hasPrefix:@"02"]) {
        return @"http://";
    } else if ([string hasPrefix:@"01"]) {
        return @"https://www.";
    } else if ([string hasPrefix:@"00"]) {
        return @"http://www.";
    }
    return nil;
}
// 后缀->16进制
+ (NSString *)tailStringToHexString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        return nil;
    }
    NSString *lastStr = [string substringWithRange:NSMakeRange(string.length-2, 2)];
    if ([lastStr isEqualToString:@"00"]) {
        return @".com/";
    } else if ([lastStr isEqualToString:@"01"]) {
        return @".org/";
    } else if ([lastStr isEqualToString:@"02"]) {
        return @".edu/";
    } else if ([lastStr isEqualToString:@"03"]) {
        return @".net/";
    } else if ([lastStr isEqualToString:@"04"]) {
        return @".info/";
    } else if ([lastStr isEqualToString:@"05"]) {
        return @".biz/";
    } else if ([lastStr isEqualToString:@"06"]) {
        return @".gov/";
    } else if ([lastStr isEqualToString:@"07"]) {
        return @".com";
    } else if ([lastStr isEqualToString:@"08"]) {
        return @".org";
    } else if ([lastStr isEqualToString:@"09"]) {
        return @".edu";
    } else if ([lastStr isEqualToString:@"0A"]) {
        return @".net";
    } else if ([lastStr isEqualToString:@"0B"]) {
        return @".info";
    } else if ([lastStr isEqualToString:@"0C"]) {
        return @".biz";
    } else if ([lastStr isEqualToString:@"0D"]) {
        return @".gov";
    } else {
        return nil;
    }
}
// 16进制字符串->网址
+ (NSString *)getAddressFromHexString:(NSString *)string {
    NSString *str = @"";
    NSString *newStr = @"";
    for (int i = 0; i < string.length/2; i++) {
        str = [string substringWithRange:NSMakeRange(i*2, 2)];
        str = [NSString stringWithFormat:@"%ld",strtoul([str UTF8String],0,16)];
        str = [NSString stringWithFormat:@"%c",[str intValue]];
        newStr = [newStr stringByAppendingString:str];
    }
    return newStr;
}
// 网址->16进制字符串
+ (NSString *)HexConvertToASCII:(NSString *)hexString{
    NSString *str = @"";
    NSString *numStr = @"";
    NSString *hexStr = @"";
    NSArray *array = [hexString componentsSeparatedByString:@"//"];
    if (array.count<2) {
        return nil;
    }
    if ([array[1] hasPrefix:@"www"]) {
        hexString = [array[1] substringFromIndex:4];
    } else {
        hexString = array[1];
    }
    NSArray *newArray = [hexString componentsSeparatedByString:@"."];
    if ([self getAddressTailString:[NSString stringWithFormat:@".%@",newArray.lastObject]]) {
        hexString = [hexString substringToIndex:hexString.length-([newArray.lastObject length]+1)];
    }
    for (int i = 0; i < hexString.length; i++) {
        str = [hexString substringWithRange:NSMakeRange(i, 1)];
        unichar theChar = [str characterAtIndex:0];
        numStr = [NSString stringWithFormat:@"%d",theChar];
        numStr = [self getHexByDecimal:(unsigned int)[numStr integerValue]];
        hexStr = [hexStr stringByAppendingString:numStr];
    }
    if (hexStr.length%2) {
        hexStr = [hexStr substringToIndex:hexStr.length-1];
        return hexStr;
    }
    return hexStr;
}
/**
 十进制转换十六进制
 */
+ (NSString *)getHexByDecimal:(unsigned int)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", (long)number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
}
//将uint32_t转换成十六进制的字符串
+ (NSString *)stringWithHexNumber:(uint32_t)hexNumber {
    char hexChar[20];
    sprintf(hexChar, "%x", (int)hexNumber);
    NSString *hexString = [NSString stringWithCString:hexChar encoding:NSUTF8StringEncoding];
    return hexString;
}

// 转换地址尾部
+ (NSString *)getAddressTailString:(NSString *)string {
    if ([string hasSuffix:@".com/"]) {
        return @"00";
    } else if ([string hasSuffix:@".org/"]) {
        return @"01";
    } else if ([string hasSuffix:@".edu/"]) {
        return @"02";
    } else if ([string hasSuffix:@".net/"]) {
        return @"03";
    } else if ([string hasSuffix:@".info/"]) {
        return @"04";
    } else if ([string hasSuffix:@".biz/"]) {
        return @"05";
    } else if ([string hasSuffix:@".gov/"]) {
        return @"06";
    } else if ([string hasSuffix:@".com"]) {
        return @"07";
    } else if ([string hasSuffix:@".org"]) {
        return @"08";
    } else if ([string hasSuffix:@".edu"]) {
        return @"09";
    } else if ([string hasSuffix:@".net"]) {
        return @"0A";
    } else if ([string hasSuffix:@".info"]) {
        return @"0B";
    } else if ([string hasSuffix:@".biz"]) {
        return @"0C";
    } else if ([string hasSuffix:@".gov"]) {
        return @"0D";
    }
    return @"";
}
// 模块型号
+ (NSString *)moduleFromIndex:(int)index {
    NSString *moduleTypes[] = {
        @"",
        @"BT401",
        @"BT405",
        @"BT426N",
        @"BT501",
        @"BT502",
        @"BT522",
        @"BT616",
        @"BT625",
        @"BT626",
        @"BT803",
        @"BT813D",
        @"BT816S",
        @"BT821",
        @"BT822",
        @"BT826",
        @"BT826N",
        @"BT836",
        @"BT836N",
        @"BT906",
        @"BT909",
        @"BP102",
        @"BT816S3",
        @"BT926",
        @"BT901",
        @"BP109",
        @"BP103",
        @"BP104",
        @"BP201",
        @"BP106",
        @"BP101",
        @"BP671",
        @"BT826H",
        @"BT826NH",
        @"BT826E",
        @"BT826EH",
        @"BT836B",
        @"BT826B",
        @"BT736",
        @"BT926B",
        @"BT966"
    };
    
    if ((sizeof(moduleTypes) / sizeof(id)) <= index) {
        return @"";
    }
    
    return moduleTypes[index];
}
//获取bundle版本
+ (NSString *)getLocalAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
//时间戳
+ (NSString *)getNowTimeTimestamp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"HH:mm:ss.SSS"]; // ---------hh与HH的区别:分别表示12小时制,24小时制
    //设置时区
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *datenow = [NSDate date];//现在时间
    NSString *timeSp = [formatter stringFromDate:datenow];
    return timeSp;
}

- (NSInteger)integerFromHexString {
    const char *str = [self UTF8String];
    const int len = (int)strlen(str);
    
    NSLog(@"%s", str);
    
    if (0 >= len) {
        return 0;
    }
    
    NSInteger weight = 1;
    NSInteger result = 0;
    
    for (int i = len - 1; i >= 0; i --) {
        char v = str[i];
        
        if ('0' <= v && v <= '9') {
            v -= '0';
        } else if ('a' <= v && v <= 'f') {
            v = v - 'a' + 0xa;
        } else if ('A' <= v && v <= 'F') {
            v = v - 'A' + 0xa;
        } else {
            result = 0;
            break;
        }
        result += (NSInteger)v * weight;
        weight *= 16;
    }
    return result;
}

- (NSInteger)integerFromReverseString {
    if (4 != self.length) {
        return 0;
    }
    NSRange range = { 2, 2 };
    NSString *highString = [self substringWithRange:range];
    
    range.location = 0;
    
    NSString *lowString = [self substringWithRange:range];
    NSString *number = [highString stringByAppendingString:lowString];
    
    return [number integerFromHexString];
}

- (NSString *)decryptVersion {
    if (4 != self.length) {
        return nil;
    }
    NSInteger value = [self integerFromReverseString];
    
    NSLog(@"value = %d", (int)value);
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    while (value > 0) {
        int tmp = value % 10;
        NSString *v = [[NSString alloc] initWithFormat:@"%d", tmp];
        
        NSLog(@"v = %@", v);
        
        [result insertString:v atIndex:0];
        
        value /= 10;
        
        if (value > 0) {
            [result insertString:@"." atIndex:0];
        }
    }
    
    return result;
}

- (NSString *)moduleFromHexString {
    const NSInteger value = [self integerFromReverseString];
    
    return [NSString moduleFromIndex:(int)value];
}

@end


