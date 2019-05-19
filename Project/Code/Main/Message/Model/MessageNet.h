//
//  MessageNet.h
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageNet : NSObject

#define MESSAGE_NET [MessageNet shareInstance] // 我加入的群组用单例

@property (nonatomic ,strong) NSMutableArray *dataList;   // 所有群组
@property (nonatomic ,strong) NSMutableArray *myJoinDataList;   // 我加入的群组
@property (nonatomic ,assign) NSInteger page; ///< 页数(从1开始，默认值1)           可选
@property (nonatomic ,assign) NSInteger total;
@property (nonatomic ,assign) NSInteger pageSize; ///< 页大小(默认值15)                可选

@property (nonatomic ,assign) BOOL isEmpty; ///<空
@property (nonatomic ,assign) BOOL isMost; ///<没有更多

@property (nonatomic ,assign) BOOL isEmptyMyJoin; ///<空
@property (nonatomic ,assign) BOOL isMostMyJoin; ///<没有更多

@property (nonatomic ,assign) BOOL isNetError; ///

+ (MessageNet *)shareInstance;

//- (void)getGroupObj:(id)obj
//            Success:(void (^)(NSDictionary *))success
//            Failure:(void (^)(NSError *))failue;



/**
 查询群组详情
 
 @param groupId 群ID
 @param successBlock 成功block
 @param failureBlock 失败block
 */
- (void)queryGroupDetails:(NSString *)groupId
          successBlock:(void (^)(NSDictionary *))successBlock
          failureBlock:(void (^)(NSError *))failureBlock;



- (void)checkGroupId:(NSString *)groupId
           Completed:(void (^)(BOOL complete))completed;



/**
 加入群组

 @param groupId 群ID
 @param successBlock 成功block
 @param failureBlock 失败block
 */
- (void)joinGroup:(NSString *)groupId
         password:(NSString *)password
          successBlock:(void (^)(NSDictionary *))successBlock
          failureBlock:(void (^)(NSError *))failureBlock;



/**
 获取我加入的群组列表

 @param successBlock 成功block
 @param failureBlock 失败block
 */
-(void)getMyJoinedGroupListSuccessBlock:(void (^)(NSDictionary *))successBlock
                       failureBlock:(void (^)(NSError *))failureBlock;

/**
 获取所有群组列表
 
 @param successBlock 成功block
 @param failureBlock 失败block
 */
-(void)getGroupListWithSuccessBlock:(void (^)(NSDictionary *))successBlock
                           failureBlock:(void (^)(NSError *))failureBlock;


@end
