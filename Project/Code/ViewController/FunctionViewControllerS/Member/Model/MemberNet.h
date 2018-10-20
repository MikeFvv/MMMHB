//
//  MemberNet.h
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemberNet : NSObject

@property (nonatomic ,strong) NSMutableArray *dataList;


+ (void)TopupObj:(id)obj
         Success:(void (^)(NSDictionary *))success
         Failure:(void (^)(NSError *))failue;


//签到
+ (void)SignObj:(id)obj
         Success:(void (^)(NSDictionary *))success
         Failure:(void (^)(NSError *))failue;


@end
