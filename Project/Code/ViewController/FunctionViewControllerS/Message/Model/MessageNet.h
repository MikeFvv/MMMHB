//
//  MessageNet.h
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageNet : NSObject

#define MESSAGE_NET [MessageNet shareInstance]//我加入的群组用单例

@property (nonatomic ,strong) NSMutableArray *dataList;
@property (nonatomic ,assign) NSInteger page; ///< 页数(从1开始，默认值1)           可选
@property (nonatomic ,assign) NSInteger total;
@property (nonatomic ,assign) NSInteger pageSize; ///< 页大小(默认值15)                可选

@property (nonatomic ,assign) BOOL isEmpty;///<空
@property (nonatomic ,assign) BOOL isMost;///<没有更多
@property (nonatomic ,assign) BOOL isNetError;///

+ (MessageNet *)shareInstance;

//- (void)getGroupObj:(id)obj
//            Success:(void (^)(NSDictionary *))success
//            Failure:(void (^)(NSError *))failue;

- (void)checkGroupId:(NSString *)groupId
           Completed:(void (^)(BOOL complete))completed;

- (void)joinGroup:(NSString *)groupId
          success:(void (^)(NSDictionary *))success
          failure:(void (^)(NSError *))failue;

- (void)quitGroup:(NSString *)groupId
          success:(void (^)(NSDictionary *))success
          failure:(void (^)(NSError *))failue;


-(void)requestGroupListWithSuccess:(void (^)(NSDictionary *))success
                        Failure:(void (^)(NSError *))failue;

-(void)requestMyJoinedGroupListWithSuccess:(void (^)(NSDictionary *))success
                                Failure:(void (^)(NSError *))failue;

@end
