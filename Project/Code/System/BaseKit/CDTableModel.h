//
//  CDTableModel.h
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDTableModel : NSObject

@property (nonatomic ,copy) NSString *className;
@property (nonatomic) CGFloat heighForCell;
@property (nonatomic) CGFloat heighForHeader;
@property (nonatomic) CGFloat heighForFooter;
@property (nonatomic) id obj;

@end
