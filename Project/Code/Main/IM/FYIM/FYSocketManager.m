//
//  FYSocketManager.m
//  
//
//  Created by Mike on 2019/3/30.
//  Copyright © 2019 Mike. All rights reserved.
//

#import "FYSocketManager.h"
#import "SRWebSocket.h"


#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


@interface FYSocketManager ()<SRWebSocketDelegate>

@property(nonatomic,assign) int index;
@property(nonatomic,strong) NSTimer *heartBeat;
@property(nonatomic,assign) NSTimeInterval reConnectTime;


@property (nonatomic,strong)SRWebSocket *webSocket;
@property (nonatomic,weak)NSTimer *timer;
@property (nonatomic,copy)NSString *urlString;

@end

@implementation FYSocketManager


+ (instancetype)shareManager{
    static FYSocketManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.overtime = 1;
    });
    return instance;
}

- (void)fy_open:(NSString *)urlStr connect:(FYSocketDidConnectBlock)connect receive:(FYSocketDidReceiveBlock)receive failure:(FYSocketDidFailBlock)failure{
    [FYSocketManager shareManager].connect = connect;
    [FYSocketManager shareManager].receive = receive;
    [FYSocketManager shareManager].failure = failure;
    self.urlString = urlStr;
    [self fy_open:urlStr];
}

- (void)fy_close:(FYSocketDidCloseBlock)close{
    [FYSocketManager shareManager].close = close;
    [self fy_close];
}




#pragma mark -- private method
- (void)fy_open:(id)params{
//    NSLog(@"params = %@",params);
    NSString *urlStr = nil;
    if ([params isKindOfClass:[NSString class]]) {
        urlStr = (NSString *)params;
    }
    else if([params isKindOfClass:[NSTimer class]]){
        NSTimer *timer = (NSTimer *)params;
        urlStr = [timer userInfo];
    }
    
    [self.webSocket close];
    self.webSocket.delegate = nil;
    
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    self.webSocket.delegate = self;
    
    
    //  设置代理线程queue
    NSOperationQueue * queue=[[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount=1;
    [self.webSocket setDelegateOperationQueue:queue];
    
    
    [self.webSocket open];
}

- (void)fy_close {
    
    [self.webSocket close];
    self.webSocket = nil;
    [self.timer invalidate];
    self.timer = nil;
    //断开连接时销毁心跳
    [self destoryHeartBeat];
}

#define WeakSelf(ws) __weak __typeof(&*self)weakSelf = self
- (void)fy_sendData:(id)data {
//    NSLog(@"socketSendData --------------- %@",data);
    
    WeakSelf(ws);
    dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);
    
    dispatch_async(queue, ^{
        if (weakSelf.webSocket != nil) {
            if (weakSelf.webSocket.readyState == SR_OPEN) {
                [weakSelf.webSocket send:data];
                
            } else if (weakSelf.webSocket.readyState == SR_CONNECTING) {
                NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
                [self reConnect];
                
            } else if (weakSelf.webSocket.readyState == SR_CLOSING || weakSelf.webSocket.readyState == SR_CLOSED) {
                NSLog(@"重连");
                [self reConnect];
            }
        } else {
            NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
        }
    });
}

#pragma mark - **************** private mothodes
//重连机制
- (void)reConnect {
    [self fy_close];
    
    //超过一分钟就不再重连 所以只会重连5次 2^5 = 64
    if (self.reConnectTime > 64) {
        //您的网络状况不是很好，请检查网络后重试
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.webSocket = nil;
        [self fy_open:self.urlString];
        NSLog(@"重连");
    });
    
    //重连时间2的指数级增长
    if (self.reConnectTime == 0) {
        self.reConnectTime = 2;
    } else {
        self.reConnectTime *= 2;
    }
}


//取消心跳
- (void)destoryHeartBeat {
    dispatch_main_async_safe(^{
        if (self.heartBeat) {
            if ([self.heartBeat respondsToSelector:@selector(isValid)]){
                if ([self.heartBeat isValid]){
                    [self.heartBeat invalidate];
                    self.heartBeat = nil;
                }
            }
        }
    })
}

//初始化心跳
- (void)initHeartBeat {
    dispatch_main_async_safe(^{
        [self destoryHeartBeat];
        //心跳设置为3分钟，NAT超时一般为5分钟
        self.heartBeat = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(sentheart) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.heartBeat forMode:NSRunLoopCommonModes];
    })
}

- (void)sentheart {
    
    NSDictionary *parameters = @{
                                 @"hbbyte":@"-127",   // 群ID
                                 @"cmd":@"13"      // 聊天命令
                                 };
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&parseError];

    [self fy_sendData:jsonData];
}

//pingPong
- (void)pingaaaa {
    if (self.webSocket.readyState == SR_OPEN) {
        [self.webSocket sendPing:nil];
    }
}








#pragma mark -- SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    //    NSLog(@"Websocket Connected");
    //每次正常连接的时候清零重连时间
    self.reConnectTime = 0;
    //开启心跳
    [self initHeartBeat];

    [FYSocketManager shareManager].connect ? [FYSocketManager shareManager].connect() : nil;

}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    if (webSocket == self.webSocket) {
        NSLog(@"************************** 🔴socket 连接失败************************** ");
        _webSocket = nil;
        //    NSLog(@":( Websocket Failed With Error %@", error);
        [FYSocketManager shareManager].failure ? [FYSocketManager shareManager].failure(error) : nil;
        //连接失败就重连
        [self reConnect];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    
    if (webSocket == self.webSocket) {   // nil 主动
        NSLog(@"************************** 🔴socket连接断开************************** ");
        NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",(long)code,reason,wasClean);
        [self fy_close];
        [FYSocketManager shareManager].close ? [FYSocketManager shareManager].close(code,reason,wasClean) : nil;
        [self reConnect];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    NSLog(@"reply===%@",reply);
    [FYSocketManager shareManager].receive ? [FYSocketManager shareManager].receive(pongPayload,FYSocketReceiveTypeForPong) : nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    
    if (webSocket == self.webSocket) {
//        NSLog(@"************************** socket收到数据了************************** ");
//        NSLog(@"message:%@",message);
        //    NSLog(@":( Websocket Receive With message %@", message);
        [FYSocketManager shareManager].receive ? [FYSocketManager shareManager].receive(message,FYSocketReceiveTypeForMessage) : nil;
    }
}


- (void)dealloc{
    // Close WebSocket
    [self fy_close];
}

@end
