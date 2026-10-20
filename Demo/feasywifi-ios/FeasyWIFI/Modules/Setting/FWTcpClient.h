//
//  FWTcpClient.h
//  FeasyWIFI
//
//  Created by app on 2023/6/29.
//  Copyright © 2023 Feasycom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@protocol FWTcpClientDelegate <NSObject>

@optional
- (void)socket:(GCDAsyncSocket *_Nonnull)sock didConnectToHost:(NSString *_Nonnull)host port:(uint16_t)port;
- (void)socket:(GCDAsyncSocket *_Nonnull)sock didReadData:(NSData *_Nullable)data withTag:(long)tag;
- (void)socketDidDisconnect:(GCDAsyncSocket *_Nonnull)sock withError:(NSError *_Nullable)err;

@end

NS_ASSUME_NONNULL_BEGIN

@interface FWTcpClient : NSObject

@property (nonatomic, weak) id<FWTcpClientDelegate> delegate;

+ (instancetype)shareFWTcpClient;
- (instancetype)initWithDelegateQueue:(nullable dispatch_queue_t)dq;
- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError **)errPtr;
- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port withTimeout:(NSTimeInterval)timeout error:(NSError *__autoreleasing  _Nullable * _Nullable)errPtr;
- (void)disconnect;
- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;

@end

NS_ASSUME_NONNULL_END
