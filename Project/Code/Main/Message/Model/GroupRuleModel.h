//
//  GroupRuleModel.h
//  Project
//
//  Created by Mike on 2019/1/2.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupRuleModel : NSObject

// ID
@property (nonatomic,copy) NSString *ruleBombId;
// 包个数
@property (nonatomic,assign) NSInteger ruleBombCount;
// 倍数
@property (nonatomic,copy) NSString *ruleBombHandicap;
// 最大金额
@property (nonatomic,copy) NSString *ruleBombMaxMoney;
// 最小金额
@property (nonatomic,copy) NSString *ruleBombMinMoney;
// 红包描述
@property (nonatomic,copy) NSString *ruleBombName;

@end

