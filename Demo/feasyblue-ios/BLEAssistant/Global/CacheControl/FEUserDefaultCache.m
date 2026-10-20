//
//  FEUserDefaultCache.m
//  BLEAssistant
//
//  Created by chenchanghua on 2021/9/20.
//  Copyright © 2021 feasycom. All rights reserved.
//

#import "FEUserDefaultCache.h"

#define PathUserDefaults [NSUserDefaults standardUserDefaults]

@implementation FEUserDefaultCache

+ (NSString *)getUpgradeFilePath {
    return [PathUserDefaults objectForKey:@"upgradeFilePath"];
}
+ (void)saveUpgradeFilePath:(NSString *)upgradeFilePath {
    [PathUserDefaults setObject:upgradeFilePath forKey:@"upgradeFilePath"];
    [PathUserDefaults synchronize];
}


+ (NSData *)getSendData {
    return [PathUserDefaults objectForKey:@"sendData"];
}
+ (void)saveSendData:(NSData *)sendData {
    [PathUserDefaults setObject:sendData forKey:@"sendData"];
    [PathUserDefaults synchronize];
}


+ (NSString *)getIntervalTime {
    return [PathUserDefaults objectForKey:@"intervalTime"];
}
+ (void)saveIntervalTime:(NSString *)intervalTime {
    [PathUserDefaults setObject:intervalTime forKey:@"intervalTime"];
    [PathUserDefaults synchronize];
}


+ (BOOL)getHexSendSwitch {
    return [PathUserDefaults boolForKey:@"hexSendSwitch"];
}
+ (void)saveHexSendSwitch:(BOOL)hexSendSwitch {
    [PathUserDefaults setBool:hexSendSwitch forKey:@"hexSendSwitch"];
    [PathUserDefaults synchronize];
}

+ (BOOL)getnewlineSendSwitch {
    return [PathUserDefaults boolForKey:@"newlineSendSwitch"];
}
+ (void)saveNewlineSendSwitch:(BOOL)newlineSendSwitch {
    [PathUserDefaults setBool:newlineSendSwitch forKey:@"newlineSendSwitch"];
    [PathUserDefaults synchronize];
}

+ (NSString *)getSf_byteCount {
    return [PathUserDefaults objectForKey:@"sf_byteCount"];
}
+ (void)saveSf_byteCount:(NSString *)sf_byteCount {
    [PathUserDefaults setObject:sf_byteCount forKey:@"sf_byteCount"];
    [PathUserDefaults synchronize];
}


+ (NSInteger)getSf_byteTypeSC {
    return [PathUserDefaults integerForKey:@"sf_byteTypeSC"];
}
+ (void)saveSf_byteTypeSC:(NSInteger)sf_byteTypeSC {
    [PathUserDefaults setInteger:sf_byteTypeSC forKey:@"sf_byteTypeSC"];
    [PathUserDefaults synchronize];
}


+ (BOOL)getSync {
    return [PathUserDefaults boolForKey:@"sync"];
}
+ (void)saveSync:(BOOL)sync {
    [PathUserDefaults setBool:sync forKey:@"sync"];
    [PathUserDefaults synchronize];
}


+ (NSInteger)getMtu {
    return [PathUserDefaults integerForKey:@"mtu"];
}
+ (void)saveMtu:(NSInteger)mtu {
    [PathUserDefaults setInteger:mtu forKey:@"mtu"];
    [PathUserDefaults synchronize];
}


+ (BOOL)getFilterEnabled_parameter {
    return [PathUserDefaults boolForKey:@"filterEnabled_parameter"];
}
+ (void)saveFilterEnabled_parameter:(BOOL)filterEnabled_parameter {
    [PathUserDefaults setBool:filterEnabled_parameter forKey:@"filterEnabled_parameter"];
    [PathUserDefaults synchronize];
}


+ (float)getMinimumRSSI_parameter {
    return [PathUserDefaults floatForKey:@"minimumRSSI_parameter"];
}
+ (void)saveMinimumRSSI_parameter:(float)minimumRSSI_parameter {
    [PathUserDefaults setFloat:minimumRSSI_parameter forKey:@"minimumRSSI_parameter"];
    [PathUserDefaults synchronize];
}


+ (NSString *)getName_prefix_parameter {
    return [PathUserDefaults objectForKey:@"name_prefix_parameter"];
}
+ (void)saveName_prefix_parameter:(NSString *)name_prefix_parameter {
    [PathUserDefaults setObject:name_prefix_parameter forKey:@"name_prefix_parameter"];
    [PathUserDefaults synchronize];
}


+ (BOOL)getFilterEnabled_update {
    return [PathUserDefaults boolForKey:@"filterEnabled_update"];
}
+ (void)saveFilterEnabled_update:(BOOL)filterEnabled_update {
    [PathUserDefaults setBool:filterEnabled_update forKey:@"filterEnabled_update"];
    [PathUserDefaults synchronize];
}


+ (float)getMinimumRSSI_update {
    return [PathUserDefaults floatForKey:@"minimumRSSI_update"];
}
+ (void)saveMinimumRSSI_update:(float)minimumRSSI_update {
    [PathUserDefaults setFloat:minimumRSSI_update forKey:@"minimumRSSI_update"];
    [PathUserDefaults synchronize];
}


+ (NSString *)getName_prefix_update {
    return [PathUserDefaults objectForKey:@"name_prefix_update"];
}
+ (void)saveName_prefix_update:(NSString *)name_prefix_update {
    [PathUserDefaults setObject:name_prefix_update forKey:@"name_prefix_update"];
    [PathUserDefaults synchronize];
}


+ (BOOL)getFilterEnabled {
    return [PathUserDefaults boolForKey:@"filterEnabled"];
}
+ (void)saveFilterEnabled:(BOOL)filterEnabled {
    [PathUserDefaults setBool:filterEnabled forKey:@"filterEnabled"];
    [PathUserDefaults synchronize];
}


+ (float)getMinimumRSSI {
    return [PathUserDefaults floatForKey:@"minimumRSSI"];
}
+ (void)saveMinimumRSSI:(float)minimumRSSI {
    [PathUserDefaults setFloat:minimumRSSI forKey:@"minimumRSSI"];
    [PathUserDefaults synchronize];
}


+ (NSString *)getName_prefix {
    return [PathUserDefaults objectForKey:@"name_prefix"];
}
+ (void)saveName_prefix:(NSString *)name_prefix {
    [PathUserDefaults setObject:name_prefix forKey:@"name_prefix"];
    [PathUserDefaults synchronize];
}


+ (NSString *)getUserPassword {
    return [PathUserDefaults objectForKey:@"userPassword"];
}
+ (void)saveUserPassword:(NSString *)userPassword {
    [PathUserDefaults setObject:userPassword forKey:@"userPassword"];
    [PathUserDefaults synchronize];
}


+ (NSString *)geUserLanguage {
    return [PathUserDefaults objectForKey:@"userLanguage"];
}
+ (void)saveUserLanguage:(NSString *)userLanguage {
    [PathUserDefaults setObject:userLanguage forKey:@"userLanguage"];
    [PathUserDefaults synchronize];
}


+ (NSInteger)getModifiedCount {
    return [PathUserDefaults integerForKey:@"modifiedCount"];
}
+ (void)saveModifiedCount:(NSInteger)modifiedCount {
    [PathUserDefaults setInteger:modifiedCount forKey:@"modifiedCount"];
    [PathUserDefaults synchronize];
}


+ (NSDictionary *)getLanchad {
    return [PathUserDefaults objectForKey:@"advertisement"];
}

+ (void)saveLanchad:(NSDictionary *)lanchad {
    [PathUserDefaults setObject:lanchad forKey:@"advertisement"];
    [PathUserDefaults synchronize];
    
    if ([PathUserDefaults objectForKey:@"lanchad"]) {
        [PathUserDefaults removeObjectForKey:@"lanchad"];
        [PathUserDefaults synchronize];
    }
}

+ (NSString *)getLastInputDfuPath {
    return [PathUserDefaults objectForKey:@"lastInputDfuPath"];
}
+ (void)saveLastInputDfuPath:(NSString *)dfuPath {
    [PathUserDefaults setObject:dfuPath forKey:@"lastInputDfuPath"];
    [PathUserDefaults synchronize];
}

+ (BOOL *)getIsUseFacp {
    return [PathUserDefaults boolForKey:@"isUseFacp"];
}
+ (void)saveIsUseFacp:(BOOL)isUseFacp {
    [PathUserDefaults setBool:isUseFacp forKey:@"isUseFacp"];
    [PathUserDefaults synchronize];
}

+ (BOOL *)getIsUseScanLog {
    return [PathUserDefaults boolForKey:@"isUseScanLog"];
}
+ (void)saveIsUseScanLog:(BOOL)isUseFacp {
    [PathUserDefaults setBool:isUseFacp forKey:@"isUseScanLog"];
    [PathUserDefaults synchronize];
}

+ (BOOL *)getIsGroupCommunication {
    return [PathUserDefaults boolForKey:@"isGroupCommunication"];
}
+ (void)saveIsGroupCommunication:(BOOL)isGroupCommunication {
    [PathUserDefaults setBool:isGroupCommunication forKey:@"isGroupCommunication"];
    [PathUserDefaults synchronize];
}

+ (BOOL *)getIsUseL2CAPChannel {
    return [PathUserDefaults boolForKey:@"IsUseL2CAPChannel"];
}
+ (void)saveIsUseL2CAPChannel:(BOOL)isUseL2CAPChannel {
    [PathUserDefaults setBool:isUseL2CAPChannel forKey:@"IsUseL2CAPChannel"];
    [PathUserDefaults synchronize];
}

+ (BOOL)getIsGetCompleteGATTStructure {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kIsGetCompleteGATTStructure"];
}
+ (void)saveIsGetCompleteGATTStructure:(BOOL)isGetCompleteGATTStructure {
    [PathUserDefaults setBool:isGetCompleteGATTStructure forKey:@"kIsGetCompleteGATTStructure"];
    [PathUserDefaults synchronize];
}

@end
