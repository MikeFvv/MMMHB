//
//  CowCowVSMessageModel.m
//  Project
//
//  Created by 罗耀生 on 2019/1/28.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "CowCowVSMessageModel.h"

@implementation CowCowVSMessageModel

- (instancetype)initWithObj:(id)obj{
    self = [super init];
    if (self) {
        NSMutableDictionary *dic9 = [NSMutableDictionary dictionary];
        dic9 = obj;
        self.content = dic9.mj_JSONString;
        NSDictionary *dic = @{@"content":self.content};
        NSLog(@"%@",[dic mj_JSONString]);
    }
    return self;
}

@end
