//
//  SSChatImageCell.m
//  SSChatView
//
//  Created by soldoros on 2018/10/12.
//  Copyright © 2018年 soldoros. All rights reserved.
//

#import "SSChatImageCell.h"

@implementation SSChatImageCell

-(void)initChatCellUI{
    
    [super initChatCellUI];
    
    self.mImgView = [UIImageView new];
    self.mImgView.layer.cornerRadius = 5;
    self.mImgView.layer.masksToBounds  = YES;
    self.mImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.mImgView.backgroundColor = [UIColor whiteColor];
    [self.bubbleBackView addSubview:self.mImgView];
    
}


-(void)setModel:(FYMessagelLayoutModel *)model{
    [super setModel:model];
    
    UIImage *image = [UIImage imageNamed:model.message.backImgString];
    image = [image resizableImageWithCapInsets:model.imageInsets resizingMode:UIImageResizingModeStretch];
    self.bubbleBackView.frame = model.bubbleBackViewRect;
    self.bubbleBackView.image = image;
//    [self.bubbleBackView setBackgroundImage:image forState:UIControlStateNormal];
    
    
    self.mImgView.frame = self.bubbleBackView.bounds;
//    self.mImgView.image = self.layout.message.image;
//    self.mImgView.contentMode = self.layout.message.contentMode;
    
    
    //给图片设置一个描边 描边跟背景按钮的气泡图片一样
    UIImageView *btnImgView = [[UIImageView alloc]initWithImage:image];
    btnImgView.frame = CGRectInset(self.mImgView.frame, 0.0f, 0.0f);
    self.mImgView.layer.mask = btnImgView.layer;
    
}


//点击展开图片
-(void)buttonPressed:(UIButton *)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didChatImageVideoCellIndexPatch:layout:)]){
        [self.delegate didChatImageVideoCellIndexPatch:self.indexPath layout:self.model];
    }
}

@end
