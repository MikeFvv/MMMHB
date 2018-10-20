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
@property (nonatomic ,assign) NSInteger page; ///< 页数(从1开始，默认值1)           可选
@property (nonatomic ,assign) NSInteger total;
@property (nonatomic ,assign) NSInteger pageSize; ///< 页大小(默认值15)                可选

@property (nonatomic ,copy) NSString *mids;
@property (nonatomic ,strong) NSDictionary *user;

@property (nonatomic ,assign) CGFloat maxMoney;

@property (nonatomic ,assign) BOOL IsEnd;

@property (nonatomic ,assign) BOOL IsEmpty;///<空
@property (nonatomic ,assign) BOOL IsMost;///<没有更多
@property (nonatomic ,assign) BOOL IsNetError;///<没有更多

- (void)getListObj:(id)obj
           Success:(void (^)(NSDictionary *))success
           Failure:(void (^)(NSError *))failue;

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
