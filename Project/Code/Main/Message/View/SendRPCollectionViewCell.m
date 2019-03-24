//
//  BaccaratCollectionViewCell.m
//  VVCollectProject
//
//  Created by Mike on 2019/2/25.
//  Copyright © 2019 Mike. All rights reserved.
//

#import "SendRPCollectionViewCell.h"


@interface SendRPCollectionViewCell ()
@property (nonatomic,strong) UILabel *numLabel;

@end

@implementation SendRPCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
//    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.masksToBounds = YES;
    if (self.selected) {
        self.backgroundColor = [UIColor colorWithRed:0.231 green:0.459 blue:0.796 alpha:1.000];
    } else {
        self.backgroundColor = [UIColor colorWithRed:0.725 green:0.761 blue:0.843 alpha:1.000];
    }
    self.backgroundColor = [UIColor colorWithRed:0.725 green:0.761 blue:0.843 alpha:1.000];
    UILabel *numLabel = [[UILabel alloc] init];
    //    numLabel.layer.masksToBounds = YES;
    //    numLabel.layer.cornerRadius = self.frame.size.width/2;
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.font = [UIFont boldSystemFontOfSize:16];
    numLabel.textColor = [UIColor whiteColor];
    [self addSubview:numLabel];
    _numLabel = numLabel;
    
    [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    if (selected) {
        self.backgroundColor = [UIColor colorWithRed:0.231 green:0.459 blue:0.796 alpha:1.000];
    } else {
        self.backgroundColor = [UIColor colorWithRed:0.725 green:0.761 blue:0.843 alpha:1.000];
    }
}

- (void)setModel:(id)model {
    NSString *numStr = (NSString *)model;
    _numLabel.text = numStr;
}


@end
