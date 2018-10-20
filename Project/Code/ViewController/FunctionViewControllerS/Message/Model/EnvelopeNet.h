//
//  EnvelopeNet.h
//  Project
//
//  Created by mac on 2018/8/20.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnvelopeNet : NSObject

+ (EnvelopeNet *)shareInstance;

@property (nonatomic ,strong) NSMutableArray *dataList;

@property (nonatomic ,strong) NSDictionary *user;

@property (nonatomic ,assign) CGFloat maxMoney;

@property (nonatomic ,assign) BOOL isEmpty;///<空
@property (nonatomic ,assign) BOOL isNetError;///<没有更多

-(void)getListWithPacketId:(NSString *)packetId success:(void (^)(NSDictionary *))success
                   failure:(void (^)(NSError *))failue;

+ (void)sendEnvelop:(id)obj
            Success:(void (^)(NSDictionary *))success
            Failure:(void (^)(NSError *))failue;

+ (void)getEnvelop:(id)obj
           Success:(void (^)(NSDictionary *))success
           Failure:(void (^)(NSError *))failue;

+ (void)getEnvelopInfo:(id)obj
               Success:(void (^)(NSDictionary *))success
               Failure:(void (^)(NSError *))failue;

@end
