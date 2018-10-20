//
//  GroupHeadView.m
//  Project
//
//  Created by mini on 2018/8/16.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "GroupHeadView.h"
#import "UserCollectionViewCell.h"

#define ALLTAG 1000

@interface GroupHeadView()<UICollectionViewDelegate,UICollectionViewDataSource>{
    UICollectionView *_collectionView;
    UIButton *_allBtn;
    
}
@property (nonatomic ,strong) NSArray *dataList;

@end

@implementation GroupHeadView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
+ (GroupHeadView *)headViewWithList:(NSArray *)list{
    NSInteger l = (list.count == 0)?0:list.count /6+ 1;
    CGFloat h = l*CD_Scal(82, 667)+50;
    l = (l>5)?5:l;
    GroupHeadView *view = [[GroupHeadView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, h)];
    view.dataList = list;
    [view updateList:list];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initSubviews];
        [self initLayout];
    }
    return self;
}

#pragma mark ----- Data
- (void)initData{
    
}

- (void)updateList:(NSArray *)list{
    _dataList = list;
    [_collectionView reloadData];
}

-(void)setTotalNum:(NSInteger)num{
    NSString *count = [NSString stringWithFormat:@"全部群成员（%ld） >",num];
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:count];
    NSRange rang = NSMakeRange(0, count.length);
    [AttributedStr addAttribute:NSFontAttributeName value:[UIFont scaleFont:14] range:rang];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:MBTNColor range:NSMakeRange(rang.location, rang.length-2)];
    [AttributedStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(rang.location, rang.length-2)];
    [_allBtn setAttributedTitle:AttributedStr forState:UIControlStateNormal];
}

#pragma mark ----- Layout
- (void)initLayout{
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).offset(-50);
    }];
    
    [_allBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self-> _collectionView.mas_bottom).offset(0);
        make.width.equalTo(self.mas_width).offset(-60);
        make.height.equalTo(@(50));
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    self.backgroundColor = Color_F;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(CDScreenWidth/5, CD_Scal(82, 667));
    
    _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    [self addSubview:_collectionView];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.scrollEnabled = NO;
    [_collectionView registerClass:NSClassFromString(@"UserCollectionViewCell") forCellWithReuseIdentifier:@"UserCollectionViewCell"];
    
    _allBtn = [UIButton new];
    [self addSubview:_allBtn];
    _allBtn.titleLabel.font = [UIFont scaleFont:15];
    [_allBtn setTitleColor:MBTNColor forState:UIControlStateNormal];
 
    [_allBtn addTarget:self action:@selector(action_allClick) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCollectionViewCell" forIndexPath:indexPath];
    [cell update:_dataList[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.click) {
        self.click(indexPath.row);
    }
}

#pragma mark action
- (void)action_allClick{
    if (self.click) {
        self.click(ALLTAG);
    }
}

@end
