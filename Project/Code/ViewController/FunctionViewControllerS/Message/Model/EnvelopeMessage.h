//
//  EnvelopeMessage.h
//  Project
//
//  Created by mini on 2018/8/8.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>



@interface EnvelopeMessage : RCMessageContent<NSCoding>

@property (nonatomic, copy) NSString *content;


- (instancetype)initWithObj:(id)obj;

@end
