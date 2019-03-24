//
//  DepositOrderController.h
//  ProjectXZHB
//
//  Created by Mike on 2019/3/10.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewCell : UIView
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *textLabel;
@property(nonatomic,copy)CallbackBlock copyBlock;
@end

@interface DepositOrderController : SuperViewController
@property(nonatomic,strong)NSDictionary *infoDic;
@property(nonatomic,strong)NSString *imageUrl;
@property(nonatomic,strong)NSString *titleStr;
@property(nonatomic,assign)NSInteger type;
@end

NS_ASSUME_NONNULL_END
