//
//  EnvelopeNet.m
//  Project
//
//  Created by mac on 2018/8/20.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "EnvelopeNet.h"
#import "BANetManager_OC.h"

static EnvelopeNet *instance = nil;
static dispatch_once_t predicate;

@implementation EnvelopeNet

+ (EnvelopeNet *)shareInstance{
    
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc]init];
        _page = 0;
        _pageSize = 15;
        _isMost = NO;
        _isEmpty = NO;
    }
    return self;
}



/**
 获取红包详情
 
 @param successBlock 成功block
 @param failureBlock 失败block
 */
-(void)getRedPacketDetailsPacketId:(id)packetId successBlock:(void (^)(NSDictionary *))successBlock
                      failureBlock:(void (^)(NSError *))failureBlock {
    
    NSString *urlPath = nil;
    switch ([packetId integerValue]) {
        case 3:
        case 4:
        case 16:
        case 17:
            // 抢包ID
            urlPath = @"social/redpacket";
            
            break;
        case 5:
        case 6:
        case 18:
            // 发包
            urlPath = @"social/redpacket/getDetailByGrabId";
            
            break;
        default:
            break;
    }
    
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@/%@",APP_MODEL.serverUrl,urlPath, (NSString *)packetId];
    
    entity.needCache = NO;
    
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_GETWithEntity:entity successBlock:^(id response) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSLog(@"get 请求数据结果： *** %@", response);
        //        [weakSelf handleGroupListData:response[@"data"] andIsMyJoined:YES];
        //        successBlock(response);
        [strongSelf processingData:response];
        successBlock(response);
    } failureBlock:^(NSError *error) {
        failureBlock(error);
    } progressBlock:nil];
    
}


/**
 获取红包详情
 
 @param packetId 红包ID
 @param successBlock 成功block
 @param failureBlock 失败block
 */
-(void)getRedpDetSendId:(id)packetId successBlock:(void (^)(NSDictionary *))successBlock
           failureBlock:(void (^)(NSError *))failureBlock {
    self.isGrabId = NO;
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@/%@",APP_MODEL.serverUrl,@"social/redpacket", (NSString *)packetId];
    
    entity.needCache = NO;
    
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_GETWithEntity:entity successBlock:^(id response) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSLog(@"get 请求数据结果： *** %@", response);
        //        [weakSelf handleGroupListData:response[@"data"] andIsMyJoined:YES];
        //        successBlock(response);
        [strongSelf processingData:response];
        successBlock(response);
    } failureBlock:^(NSError *error) {
        failureBlock(error);
    } progressBlock:nil];
    
}



/**
 抢包id获取发包详情
 
 @param packetId 抢包ID
 @param successBlock 成功block
 @param failureBlock 失败block
 */
-(void)getRedpDetGrabId:(id)packetId successBlock:(void (^)(NSDictionary *))successBlock
           failureBlock:(void (^)(NSError *))failureBlock {
    
    self.isGrabId = YES;
    // 抢包ID
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@/%@",APP_MODEL.serverUrl,@"social/redpacket/getDetailByGrabId", (NSString *)packetId];
    
    entity.needCache = NO;
    
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_GETWithEntity:entity successBlock:^(id response) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSLog(@"get 请求数据结果： *** %@", response);
        //        [weakSelf handleGroupListData:response[@"data"] andIsMyJoined:YES];
        //        successBlock(response);
        [strongSelf processingData:response];
        successBlock(response);
    } failureBlock:^(NSError *error) {
        failureBlock(error);
    } progressBlock:nil];
    
}



- (void)processingData:(NSDictionary *)response {
    if (([[response objectForKey:@"code"] integerValue] == 0)) {
        NSDictionary *data = [response objectForKey:@"data"];
        if (data != NULL) {
            
            self.redPackedInfoDetail = [[NSMutableDictionary alloc] initWithDictionary: [response objectForKey:@"data"][@"detail"]];
            [self.dataList removeAllObjects];
            self.redPackedListArray = [[NSMutableArray alloc] initWithArray:[response objectForKey:@"data"][@"skRedbonusGrabModels"]];
            
            NSInteger luckMaxIndex = 0;
            CGFloat moneyMax = 0.0;
            
            if ([self.redPackedInfoDetail[@"total"] integerValue] == self.redPackedListArray.count) {
                for (NSInteger i = 0; i < self.redPackedListArray.count; i++) {
                    NSMutableDictionary *objDict = [NSMutableDictionary dictionaryWithDictionary:self.redPackedListArray[i]];
                    NSString *strMoney = [objDict[@"money"] stringByReplacingOccurrencesOfString:@"*" withString:@"0"];
                    CGFloat money = [strMoney floatValue];
                    if (money > moneyMax) {
                        moneyMax = money;
                        luckMaxIndex = i;
                    }
                    
                    // 庄家点数+庄家money
                    if ([[self.redPackedInfoDetail objectForKey:@"type"] integerValue] == 2) {
                        NSString *sendUserId = [NSString stringWithFormat:@"%@",[self.redPackedInfoDetail objectForKey:@"userId"]];
                        NSString *userId = [NSString stringWithFormat:@"%@",[objDict objectForKey:@"userId"]];
                        if ([sendUserId isEqualToString:userId]) {
                            [self.redPackedInfoDetail setObject:[objDict objectForKey:@"score"] forKey:@"bankerPointsNum"];
                            [self.redPackedInfoDetail setObject:[objDict objectForKey:@"money"] forKey:@"bankerMoney"];
                            [self.redPackedInfoDetail setObject:@(YES)forKey:@"isBanker"];
                        }
                        
                        // 自己抢的点数
                        if ([userId isEqualToString:[AppModel shareInstance].user.userId]) {
                            [self.redPackedInfoDetail setObject:[objDict objectForKey:@"score"] forKey:@"itselfPointsNum"];
                        }
                    }
                }
                
            }
            
            
            
            for (NSInteger i = 0; i < self.redPackedListArray.count; i++) {
                
                CDTableModel *model = [CDTableModel new];
                model.className = @"RedPackedDetTableCell";
                
                NSMutableDictionary *objDict = [NSMutableDictionary dictionaryWithDictionary:self.redPackedListArray[i]];
                
                if ([self.redPackedInfoDetail[@"type"] integerValue] == 1) {
                    // 雷
                    NSString *moneyLei = [objDict objectForKey:@"money"];
                    NSString *last = [moneyLei substringFromIndex:moneyLei.length-1];
                    NSDictionary *attrDict = [[self.redPackedInfoDetail objectForKey:@"attr"] mj_JSONObject];
                    NSString *bombNum = attrDict[@"bombNum"];
                    if ([last isEqualToString:bombNum]) {
                        [objDict setValue:@(YES) forKey:@"isMine"];
                    } else {
                        [objDict setValue:@(NO) forKey:@"isMine"];
                    }
                }
                
                BOOL isItself = NO;
                // 自己抢的钱
                NSString *userId = [NSString stringWithFormat:@"%@",[objDict objectForKey:@"userId"]];
                if ([userId isEqualToString:[AppModel shareInstance].user.userId]) {
                    [self.redPackedInfoDetail setObject:[objDict objectForKey:@"money"] forKey:@"itselfMoney"];
                    [self.redPackedInfoDetail setObject:@(YES) forKey:@"isItself"];
                    isItself = YES;
                } else {
                    isItself = NO;
                }
                
                if ([self.redPackedInfoDetail[@"total"] integerValue] == self.redPackedListArray.count) {
                    // 手气最佳
                    if (luckMaxIndex == i) {
                        [objDict setValue:@(YES) forKey:@"isLuck"];
                    } else {
                        [objDict setValue:@(NO) forKey:@"isLuck"];
                    }
                    
                    if ([[self.redPackedInfoDetail objectForKey:@"type"] integerValue] == 2) {  // 庄 闲
                        // 是
                        NSString *sendUserId = [NSString stringWithFormat:@"%@",[self.redPackedInfoDetail objectForKey:@"userId"]];
                        NSString *userId = [NSString stringWithFormat:@"%@",[objDict objectForKey:@"userId"]];
                        if ([sendUserId isEqualToString:userId]) {
                            [objDict setValue:@(YES) forKey:@"isBanker"];
                        } else {
                            [objDict setValue:@(NO) forKey:@"isBanker"];
                        }
                        
                        // 庄闲点数
                        if ([[self.redPackedInfoDetail objectForKey:@"bankerPointsNum"] integerValue] > [[objDict objectForKey:@"score"] integerValue]) {
                            
                            if (isItself) {
                                 [self.redPackedInfoDetail setValue:@(NO) forKey:@"isItselfWin"];
                            }
                           
                            NSInteger num = [[self.redPackedInfoDetail objectForKey:@"bankerWinCount"] integerValue];
                            num++;
                            [self.redPackedInfoDetail setValue:@(num) forKey:@"bankerWinCount"];
                        } else if ([[self.redPackedInfoDetail objectForKey:@"bankerPointsNum"] integerValue] == [[objDict objectForKey:@"score"] integerValue]) {
                            
                            if ([[self.redPackedInfoDetail objectForKey:@"bankerMoney"] floatValue] >= [[objDict objectForKey:@"money"] floatValue] ) {
                                if (isItself) {
                                    [self.redPackedInfoDetail setValue:@(NO) forKey:@"isItselfWin"];
                                }
                                
                                NSInteger num = [[self.redPackedInfoDetail objectForKey:@"bankerWinCount"] integerValue];
                                num++;
                                [self.redPackedInfoDetail setValue:@(num) forKey:@"bankerWinCount"];
                            } else {
                                if (isItself) {
                                    [self.redPackedInfoDetail setValue:@(YES) forKey:@"isItselfWin"];
                                }
                                NSInteger num = [[self.redPackedInfoDetail objectForKey:@"playerWinCount"] integerValue];
                                num++;
                                [self.redPackedInfoDetail setValue:@(num) forKey:@"playerWinCount"];
                            }
                        } else {
                            if (isItself) {
                                [self.redPackedInfoDetail setValue:@(YES) forKey:@"isItselfWin"];
                            }
                            NSInteger num = [[self.redPackedInfoDetail objectForKey:@"playerWinCount"] integerValue];
                            num++;
                            [self.redPackedInfoDetail setValue:@(num) forKey:@"playerWinCount"];
                        }
                    }
                }
                
                
                
                [objDict setValue:self.redPackedInfoDetail[@"type"] forKey:@"redpType"];
                model.obj = objDict;
                [self.dataList addObject:model];
            }
            self.isEmpty = (self.dataList.count == 0)?YES:NO;
            self.isMost = ((self.dataList.count % self.pageSize == 0)&(self.redPackedListArray.count>0))?NO:YES;
            
        }
    } else {
        predicate = 0;
        instance =nil;
    }
}

@end
