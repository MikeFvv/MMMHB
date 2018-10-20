//
//  ModelHelper.h
//  Project
//
//  Created by mac on 2018/10/15.
//  Copyright © 2018年 CDJay. All rights reserved.
//新版本服务端把所有字段都改了，只能写这个类来一个个做赋值

#import <Foundation/Foundation.h>
#import "MessageItem.h"

#define MODEL_HELPER [ModelHelper sharedInstance]

@interface ModelHelper : NSObject
+(ModelHelper *)sharedInstance;
+(void)destroyInstance;

-(MessageItem *)getMessageItem:(NSDictionary *)dict;
@end
