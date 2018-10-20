//
//  TopupViewController.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "TopupViewController.h"
#import "TopupBarView.h"
#import "MemberNet.h"
#import "WebViewController.h"

@interface TopupViewController (){
    UITableView *_tableView;
    TopupBarView *_topupBar;
}

@end

@implementation TopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.navigationItem.title = @"充值";
    
    _tableView = [UITableView normalTable];
    [self.view addSubview:_tableView];
    //    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.backgroundColor = BaseColor;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    _topupBar = [TopupBarView topupBar];
    _tableView.tableHeaderView = _topupBar;
    
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 300)];
    _tableView.tableFooterView = footer;
    
    UIButton *submit = [UIButton new];
    [footer addSubview:submit];
    submit.layer.cornerRadius = 8;
    submit.backgroundColor = MBTNColor;
    submit.titleLabel.font = [UIFont scaleFont:17];
    [submit setTitle:@"确认支付" forState:UIControlStateNormal];
    [submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submit addTarget:self action:@selector(action_submit) forControlEvents:UIControlEventTouchUpInside];
    
    [submit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footer.mas_left).offset(16);
        make.right.equalTo(footer.mas_right).offset(-16);
        make.height.equalTo(@(42));
        make.top.equalTo(footer.mas_top).offset(32);
    }];
    
    UILabel *tipLabel = [UILabel new];
    [footer addSubview:tipLabel];
    tipLabel.font = [UIFont scaleFont:12];
    tipLabel.numberOfLines = 0;
    tipLabel.textColor = Color_6;
    tipLabel.text = @"以下操作导致积分不到账\n1、保持的二维码只能用一次，不能重复使用\n2、二维码保存后30秒不使用即失效，必须重新保存。";
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footer.mas_left).offset(18);
        make.right.equalTo(footer.mas_right).offset(-18);
        make.top.equalTo(submit.mas_bottom).offset(10);
    }];
    
}


#pragma mark UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 0;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

#pragma mark action
- (void)action_submit{
    if (_topupBar.money.length == 0) {
        SV_ERROR_STATUS(@"请输入充值金额！");
        return;
    }
    SV_SHOW;
    [MemberNet TopupObj:@{@"uid":APP_MODEL.user.userId,@"type":@(_topupBar.type),@"money":_topupBar.money} Success:^(NSDictionary *info) {
        SV_DISMISS;
        NSInteger type = [info[@"data"][@"type"]integerValue];//[info objectForKey:@"data"]
        NSString *html = info[@"data"][@"html"];
        if (type == 1) {//1-html字符串，2-地址
            WebViewController *vc = [[WebViewController alloc]initWithHtmlString:html];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            WebViewController *vc = [[WebViewController alloc]initWithUrl:html];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } Failure:^(NSError *error) {
        SV_ERROR(error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
