//
//  MessageItem.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MessageItem.h"


@implementation MessageItem

MJCodingImplementation


- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (NSString *)whc_SqliteVersion{
    return @"1.0.2";
}

- (NSString *)path{
    NSString *path = [NSString stringWithFormat:@"%@_%@_%d",url_preix,APP_MODEL.user.userId,rongYunMode];
    return path;//[path MD5ForLower32Bate];
}

//+ (NSString *)whc_SqlitePath{

//}

@end
