//
//  FEOtaFileManager.m
//  BLEAssistant
//
//  Created by chenchanghua on 2026/2/27.
//  Copyright © 2026 feasycom. All rights reserved.
//

#import "FEOtaFileManager.h"

@implementation FEOtaFileManager

+ (NSString *)otaRootDir {
    NSString *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [doc stringByAppendingPathComponent:@"OTA"];
}

+ (BOOL)ensureOtaRootDir:(NSError **)error {
    NSString *dir = [self otaRootDir];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:dir]) return YES;
    return [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:error];
}

+ (NSString *)_safeFileNameFromURL:(NSURL *)url {
    NSString *name = url.lastPathComponent ?: @"ota.bin";
    name = [name stringByRemovingPercentEncoding] ?: name;
    if (name.length == 0) name = @"ota.bin";
    return name;
}

+ (NSString *)_uniqueDestPathForFileName:(NSString *)fileName {
    NSString *dir = [self otaRootDir];
    NSString *base = [fileName stringByDeletingPathExtension];
    NSString *ext  = [fileName pathExtension];
    
    NSString *candidate = [dir stringByAppendingPathComponent:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:candidate]) return candidate;
    
    for (NSInteger i = 1; i < 10000; i++) {
        NSString *newName = ext.length > 0 ? [NSString stringWithFormat:@"%@(%ld).%@", base, (long)i, ext]
        : [NSString stringWithFormat:@"%@(%ld)", base, (long)i];
        candidate = [dir stringByAppendingPathComponent:newName];
        if (![fm fileExistsAtPath:candidate]) return candidate;
    }
    
    NSString *uuid = NSUUID.UUID.UUIDString;
    NSString *fallback = ext.length > 0 ? [NSString stringWithFormat:@"%@_%@.%@", base, uuid, ext]
    : [NSString stringWithFormat:@"%@_%@", base, uuid];
    return [dir stringByAppendingPathComponent:fallback];
}

+ (void)importFileURL:(NSURL *)srcURL
            sourceTag:(NSString *)sourceTag
           completion:(void(^)(NSString * _Nullable finalPath, NSError * _Nullable error))completion {
    
    if (!srcURL) {
        if (completion) completion(nil, [NSError errorWithDomain:@"FEOta" code:-100 userInfo:@{NSLocalizedDescriptionKey:@"srcURL is nil"}]);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSError *err = nil;
        if (![self ensureOtaRootDir:&err]) {
            dispatch_async(dispatch_get_main_queue(), ^{ if (completion) completion(nil, err); });
            return;
        }
        
        BOOL needStop = NO;
        if (srcURL.isFileURL) {
            needStop = [srcURL startAccessingSecurityScopedResource];
        }
        
        @try {
            NSString *fileName = [self _safeFileNameFromURL:srcURL];
            NSString *destPath = [self _uniqueDestPathForFileName:fileName];
            NSURL *destURL = [NSURL fileURLWithPath:destPath];
            
            NSFileManager *fm = [NSFileManager defaultManager];
            
            if ([fm fileExistsAtPath:destPath]) {
                [fm removeItemAtPath:destPath error:nil];
            }
            
            BOOL ok = [fm copyItemAtURL:srcURL toURL:destURL error:&err];
            
            if (!ok || err) {
                err = nil;
                NSData *data = [NSData dataWithContentsOfURL:srcURL options:0 error:&err];
                if (data && !err) {
                    ok = [data writeToURL:destURL options:NSDataWritingAtomic error:&err];
                }
            }
            
            if (!ok || err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(nil, err ?: [NSError errorWithDomain:@"FEOta" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Import failed"}]);
                });
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(destPath, nil);
            });
            
        } @finally {
            if (needStop) {
                [srcURL stopAccessingSecurityScopedResource];
            }
        }
    });
}

+ (NSArray<NSString *> *)listOtaFiles {
    NSError *err = nil;
    [self ensureOtaRootDir:&err];
    
    NSString *dir = [self otaRootDir];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *names = [fm contentsOfDirectoryAtPath:dir error:nil] ?: @[];
    
    NSMutableArray<NSString *> *paths = [NSMutableArray arrayWithCapacity:names.count];
    for (NSString *n in names) {
        [paths addObject:[dir stringByAppendingPathComponent:n]];
    }
    
    // 按修改时间倒序
    [paths sortUsingComparator:^NSComparisonResult(NSString *p1, NSString *p2) {
        NSDictionary *a = [fm attributesOfItemAtPath:p1 error:nil];
        NSDictionary *b = [fm attributesOfItemAtPath:p2 error:nil];
        NSDate *da = a.fileModificationDate ?: [NSDate distantPast];
        NSDate *db = b.fileModificationDate ?: [NSDate distantPast];
        return [db compare:da];
    }];
    
    return paths;
}

+ (BOOL)deleteFileAtPath:(NSString *)path error:(NSError **)error {
    if (path.length == 0) return NO;
    return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

+ (NSDictionary<NSFileAttributeKey, id> *)attributesOfItemAtPath:(NSString *)path {
    if (path.length == 0) return nil;
    return [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
}

@end
