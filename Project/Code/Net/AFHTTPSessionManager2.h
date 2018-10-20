//
//  AFHTTPSessionManager2.h
//  Project
//
//  Created by mac on 2018/10/12.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "AFHTTPSessionManager.h"
typedef void (^ResponseBlock)(id object);

@interface AFHTTPSessionManager2 : AFHTTPSessionManager
/**
 请求参数
 */
@property(nonatomic,strong)id requestParameters;

/**
 返回block
 */
@property(nonatomic,copy)ResponseBlock successBlock;
@property(nonatomic,copy)ResponseBlock failBlock;


/**
 额外的数据 一般不会用到
 */
@property(nonatomic,strong)NSDictionary *extraData;


/**
 接口action
 */
@property(nonatomic,assign)NSInteger action;

@end
