//
//  WithdrawalModel.h
//  Project
//
//  Created by mini on 2018/8/15.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WithdrawalModel : NSObject

@property (nonatomic ,copy) NSString *upayRegion;
@property (nonatomic ,copy) NSString *upayNo;
@property (nonatomic ,copy) NSString *upayBankname;
@property (nonatomic ,assign) NSInteger upaytId;
@property (nonatomic ,copy) NSString *upayUser;
@property (nonatomic ,assign) NSInteger upayCreateTime;
@property (nonatomic ,copy) NSString *wId;
@property (nonatomic ,copy) NSString *upayTargetId;

//@property (nonatomic ,copy) NSString *accAreaName;
//@property (nonatomic ,copy) NSString *accNo;
//@property (nonatomic ,copy) NSString *accTargetName;
//@property (nonatomic ,assign) NSInteger accType;
//@property (nonatomic ,copy) NSString *accUser;
//@property (nonatomic ,assign) NSInteger create_time;
//@property (nonatomic ,copy) NSString *wId;
//@property (nonatomic ,copy) NSString *userId;
@end
