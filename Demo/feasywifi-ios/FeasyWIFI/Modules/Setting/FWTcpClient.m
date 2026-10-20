//
//  FWTcpClient.m
//  FeasyWIFI
//
//  Created by app on 2023/6/29.
//  Copyright © 2023 Feasycom. All rights reserved.
//

#import "FWTcpClient.h"

@interface FWTcpClient ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *clientSocket;

@end

@implementation FWTcpClient

+ (instancetype)shareFWTcpClient{
    static FWTcpClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[FWTcpClient alloc]init];
    });
    return client;
}

- (instancetype)init{
    self = [super init];
    if(self){
        _clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (instancetype)initWithDelegateQueue:(nullable dispatch_queue_t)dq{
    self = [super init];
    if(self){
        self.clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dq];
    }
    return self;
}

- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError *__autoreleasing  _Nullable * _Nullable)errPtr{
    return [_clientSocket connectToHost:host onPort:port error:errPtr];
}

- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port withTimeout:(NSTimeInterval)timeout error:(NSError *__autoreleasing  _Nullable * _Nullable)errPtr{
    return [_clientSocket connectToHost:host onPort:port withTimeout:timeout error:errPtr];
}

- (void)disconnect{
    [_clientSocket disconnect];
}

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag{
    [_clientSocket readDataWithTimeout:timeout tag:tag];
}

- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag{
    [_clientSocket writeData:data withTimeout:timeout tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    [_clientSocket readDataWithTimeout:-1 tag:0];
    if ([self.delegate respondsToSelector:@selector(socket:didConnectToHost:port:)]) {
        [self.delegate socket:sock didConnectToHost:host port:port];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@" disconnect socket:%@",err);  
    if([self.delegate respondsToSelector:@selector(socketDidDisconnect:withError:)]){
        [self.delegate socketDidDisconnect:sock withError:err];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *rcvData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"recvData:%@",rcvData);
    
    [_clientSocket readDataWithTimeout:-1 tag:0];
    if ([self.delegate respondsToSelector:@selector(socket:didReadData:withTag:)]) {
        [self.delegate socket:sock didReadData:data withTag:tag];
    }
}


@end
