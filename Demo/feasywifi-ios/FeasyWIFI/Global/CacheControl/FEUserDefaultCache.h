//
//  FEUserDefaultCache.h
//  BLEAssistant
//
//  Created by chenchanghua on 2021/9/20.
//  Copyright © 2021 feasycom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FEUserDefaultCache : NSObject

+ (NSString *)getUpgradeFilePath;
+ (void)saveUpgradeFilePath:(NSString *)upgradeFilePath;


+ (NSData *)getSendData;
+ (void)saveSendData:(NSData *)sendData;


+ (NSString *)getIntervalTime;
+ (void)saveIntervalTime:(NSString *)intervalTime;


+ (BOOL)getHexSendSwitch;
+ (void)saveHexSendSwitch:(BOOL)hexSendSwitch;


+ (NSString *)getSf_byteCount;
+ (void)saveSf_byteCount:(NSString *)sf_byteCount;


+ (NSInteger)getSf_byteTypeSC;
+ (void)saveSf_byteTypeSC:(NSInteger)sf_byteTypeSC;


+ (BOOL)getSync;
+ (void)saveSync:(BOOL)sync;


+ (NSInteger)getMtu;
+ (void)saveMtu:(NSInteger)mtu;


+ (BOOL)getFilterEnabled_parameter;
+ (void)saveFilterEnabled_parameter:(BOOL)filterEnabled_parameter;


+ (float)getMinimumRSSI_parameter;
+ (void)saveMinimumRSSI_parameter:(float)minimumRSSI_parameter;


+ (NSString *)getName_prefix_parameter;
+ (void)saveName_prefix_parameter:(NSString *)name_prefix_parameter;


+ (BOOL)getFilterEnabled_update;
+ (void)saveFilterEnabled_update:(BOOL)filterEnabled_update;


+ (float)getMinimumRSSI_update;
+ (void)saveMinimumRSSI_update:(float)minimumRSSI_update;


+ (NSString *)getName_prefix_update;
+ (void)saveName_prefix_update:(NSString *)name_prefix_update;


+ (BOOL)getFilterEnabled;
+ (void)saveFilterEnabled:(BOOL)filterEnabled;


+ (float)getMinimumRSSI;
+ (void)saveMinimumRSSI:(float)minimumRSSI;


+ (NSString *)getName_prefix;
+ (void)saveName_prefix:(NSString *)name_prefix;


+ (NSString *)getUserPassword;
+ (void)saveUserPassword:(NSString *)userPassword;


+ (NSString *)geUserLanguage;
+ (void)saveUserLanguage:(NSString *)userLanguage;


+ (NSInteger)getModifiedCount;
+ (void)saveModifiedCount:(NSInteger)modifiedCount;


+ (NSURL *)getDfu_selectedUrl;
+ (void)saveDfu_selectedUrl:(NSURL *)dfu_selectedUrl;


+ (NSString *)getLanchad;
+ (void)saveLanchad:(NSString *)lanchad;

@end

NS_ASSUME_NONNULL_END
