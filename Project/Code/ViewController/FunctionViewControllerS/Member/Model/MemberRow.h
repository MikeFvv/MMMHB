//
//  MemberRow.h
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemberRow : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *subValue;
@property (nonatomic, copy) NSString *vcName;

@end
