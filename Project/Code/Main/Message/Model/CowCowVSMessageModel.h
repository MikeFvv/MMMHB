//
//  CowCowVSMessageModel.h
//  Project
//
//  Created by Mike on 2019/1/28.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>



@interface CowCowVSMessageModel : RCMessageContent

- (instancetype)initWithObj:(id)obj;
@property (nonatomic, copy) NSString *content;

@end

