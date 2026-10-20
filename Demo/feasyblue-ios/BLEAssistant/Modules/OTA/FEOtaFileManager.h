//
//  FEOtaFileManager.h
//  BLEAssistant
//
//  Created by chenchanghua on 2026/2/27.
//  Copyright © 2026 feasycom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FEOtaFileManager : NSObject

/// Documents/OTA
+ (NSString *)otaRootDir;
+ (BOOL)ensureOtaRootDir:(NSError * _Nullable * _Nullable)error;

/// 统一导入：把任意来源的文件 URL 落到 OTA 目录，返回最终路径（绝对路径）
+ (void)importFileURL:(NSURL *)srcURL
            sourceTag:(NSString *)sourceTag
           completion:(void(^)(NSString * _Nullable finalPath, NSError * _Nullable error))completion;

/// 列出 OTA 文件（返回绝对路径数组，按修改时间倒序）
+ (NSArray<NSString *> *)listOtaFiles;

/// 删除 OTA 文件（传绝对路径）
+ (BOOL)deleteFileAtPath:(NSString *)path error:(NSError * _Nullable * _Nullable)error;

/// 读取文件属性（size/date）
+ (NSDictionary<NSFileAttributeKey, id> * _Nullable)attributesOfItemAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
