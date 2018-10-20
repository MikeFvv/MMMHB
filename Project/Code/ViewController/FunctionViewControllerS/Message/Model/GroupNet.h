//
//  GroupNet.h
//  Project
//
//  Created by mini on 2018/8/16.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupNet : NSObject

@property (nonatomic ,strong) NSMutableArray *dataList;
@property (nonatomic ,assign) NSInteger page; ///< 页数(从1开始，默认值1)           可选
@property (nonatomic ,assign) NSInteger total;

@property (nonatomic ,assign) BOOL isEmpty;///<空
@property (nonatomic ,assign) BOOL isMost;///<没有更多
@property(nonatomic,copy)NSString *groupId;

-(void)getUserListWithSuccess:(void (^)(NSDictionary *))success
                      failure:(void (^)(id))failue;
//- (void)queryUserObj:(id)obj
//             Success:(void (^)(NSDictionary *))success
//             Failure:(void (^)(NSError *))failue;
@end
