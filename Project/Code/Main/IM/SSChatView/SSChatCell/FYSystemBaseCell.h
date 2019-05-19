//
//  FYSystemBaseCell.h
//  Project
//
//  Created by Mike on 2019/4/15.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYMessagelLayoutModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FYSystemBaseCell : UITableViewCell

-(void)initChatCellUI;
@property(nonatomic, strong) FYMessagelLayoutModel  *model;

@end

NS_ASSUME_NONNULL_END
