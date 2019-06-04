//
//  RechargeViewController.m
//  ProjectXZHB
//
//  Created by fangyuan on 2019/3/8.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "RechargeViewController.h"
#import "WebViewController.h"
#import "RechargeDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "CustomerServiceAlertView.h"

@interface RechargeViewController ()<UITableViewDelegate,UITableViewDataSource,SelectRechargeTypeDelegate>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *rechargeTypeList;
@property(nonatomic,strong)NSArray *rechargeTypeList2;

@property(nonatomic,strong)UILabel *tipLabel;
@end

@implementation RechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"充值中心";
    // Do any additional setup after loading the view.
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    headView.backgroundColor = [UIColor clearColor];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headView.frame.size.width, headView.frame.size.height - 3)];
    bgView.backgroundColor = [UIColor whiteColor];
    [headView addSubview:bgView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = MBTNColor;
    titleLabel.font = [UIFont boldSystemFontOfSize:19];
    titleLabel.text = @"首选支付";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bgView);
    }];
    
    _tableView = [UITableView groupTable];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.tableHeaderView = headView;
    _tableView.rowHeight = 56;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    _tableView.tableFooterView = [self bottomView];
    
    SVP_SHOW;
    [self requestFirstRechargeList];
    [self requestAllRechargeList];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.rechargeTypeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = [NSString stringWithFormat:@"%zd",row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor whiteColor];
        [cell addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(cell);
            make.top.equalTo(cell).offset(2);
            make.bottom.equalTo(cell).offset(-2);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = Color_0;
        titleLabel.font = [UIFont systemFontOfSize2:16];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.tag = 1;
        [cell addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell);
        }];
        
        UIImageView *iconView = [[UIImageView alloc] init];
        [cell addSubview:iconView];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.tag = 2;
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell).offset(40);
            make.width.height.equalTo(@40);
            make.centerY.equalTo(cell.mas_centerY);
        }];
        
        UIImageView *pigView = [[UIImageView alloc] init];
        [cell addSubview:pigView];
        pigView.image = [UIImage imageNamed:@"pig"];
        pigView.contentMode = UIViewContentModeScaleAspectFit;
        pigView.tag = 3;
        [pigView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.mas_right).offset(-40);
            make.width.height.equalTo(@30);
            make.centerY.equalTo(cell.mas_centerY);
        }];
    }
    NSDictionary *dic = self.rechargeTypeList[indexPath.row];
    UILabel *titleLabel = [cell viewWithTag:1];
    UIImageView *iconView = [cell viewWithTag:2];
    titleLabel.text = dic[@"title"];
    if(dic[@"img"])
        [iconView sd_setImageWithURL:[NSURL URLWithString:dic[@"img"]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.rechargeTypeList[indexPath.row];
    RechargeDetailViewController *vc = [[RechargeDetailViewController alloc] init];
    vc.title = dic[@"title"];
    vc.infoDic = dic;
    [self.navigationController pushViewController:vc animated:YES];
}

-(UIView *)bottomView{
    NSInteger height = 300;
    if(SCREEN_WIDTH == 320)
        height = 350;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    view.backgroundColor = [UIColor clearColor];
    
    UIButton *btn = [UIButton new];
    [view addSubview:btn];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize2:17];
    [btn setTitle:@"更多支付方式" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 8.0f;
    btn.layer.masksToBounds = YES;
    btn.backgroundColor = MBTNColor;
    [btn delayEnable];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(50));
        make.right.equalTo(view.mas_right).offset(-50);
        make.height.equalTo(@(44));
        make.top.equalTo(view.mas_top).offset(16);
    }];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = COLOR_X(190, 190, 190);
    tipLabel.font = [UIFont systemFontOfSize2:13];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(view);
        make.top.equalTo(btn.mas_bottom).offset(50);
    }];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"支付遇到困难？联系客服取得帮助"];
    [string addAttribute:NSForegroundColorAttributeName value:COLOR_X(40, 40, 141) range:NSMakeRange(7, 4)];
    tipLabel.attributedText = string;
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [view addSubview:btn2];
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(tipLabel.mas_centerY);
        make.height.equalTo(@30);
        make.width.equalTo(@100);
    }];
    [btn2 addTarget:self action:@selector(actionShowCustomerServiceAlertView) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TBSeparaColor;
    [view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0.5);
        make.left.right.equalTo(view);
        make.top.equalTo(btn2.mas_bottom).offset(5);
    }];
    
    UILabel *tLabel = [[UILabel alloc] init];
    tLabel.backgroundColor = [UIColor clearColor];
    tLabel.textColor = COLOR_X(80, 80, 80);
    tLabel.font = [UIFont systemFontOfSize2:14];
    [view addSubview:tLabel];
    NSInteger x = 50;
    if(SCREEN_WIDTH == 320)
        x = 30;
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(x));
        make.top.equalTo(lineView.mas_bottom).offset(10);
        make.width.equalTo(@(SCREEN_WIDTH - x * 2));
    }];
    tLabel.text = @"温馨提示";
    
    NSDictionary *dic = [[FunctionManager sharedInstance] appConstants];
    UILabel *tipLabel2 = [[UILabel alloc] init];
    tipLabel2.backgroundColor = [UIColor clearColor];
    tipLabel2.textColor = COLOR_X(190, 190, 190);
    tipLabel2.font = [UIFont systemFontOfSize2:13];
    tipLabel2.numberOfLines = 0;
    tipLabel2.text = dic[@"rechargeTip"];
    [view addSubview:tipLabel2];
    self.tipLabel = tipLabel2;
    [tipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(tLabel);
        make.top.equalTo(tLabel.mas_bottom).offset(8);
    }];
    
    return view;
}

-(void)moreAction{
    SelectRechargeTypeView *sheet = [[SelectRechargeTypeView alloc] initWithArray:self.rechargeTypeList2];
    sheet.titleLabel.text = @"更多支付方式";
    sheet.delegate = self;
    [sheet showWithAnimationWithAni:YES];
}

#pragma mark - 客服弹框
- (void)actionShowCustomerServiceAlertView{
    NSString *imageUrl = [AppModel shareInstance].commonInfo[@"customer.service.window"];
    if (imageUrl.length == 0) {
        [self connectToSer];
        return;
    }
    CustomerServiceAlertView *view = [[CustomerServiceAlertView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [view updateView:@"常见问题" imageUrl:imageUrl];
    __weak __typeof(self)weakSelf = self;
    
    // 查看详情
    view.customerServiceBlock = ^{
        [weakSelf connectToSer];
    };
    [view showInView:self.view];
}

-(void)connectToSer{
    WebViewController *vc = [[WebViewController alloc] initWithUrl:[AppModel shareInstance].commonInfo[@"pop"]];
    vc.title = @"在线客服";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)selectRechargeTypeDelegateWithActionSheet:(SelectRechargeTypeView *)actionSheet index:(NSInteger)index{
    NSDictionary *dic = self.rechargeTypeList2[index];
    
    RechargeDetailViewController *vc = [[RechargeDetailViewController alloc] init];
    vc.title = dic[@"title"];
    vc.infoDic = dic;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)requestFirstRechargeList{
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER requestFirstRechargeListWithSuccess:^(id object) {
        NSArray *arr = object[@"data"];
        SVP_DISMISS;
        weakSelf.rechargeTypeList = arr;
        [weakSelf.tableView reloadData];
    } fail:^(id object) {
        [[FunctionManager sharedInstance] handleFailResponse:object];
    }];
}

-(void)requestAllRechargeList{
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER requestAllRechargeListWithSuccess:^(id object) {
        NSArray *arr = object[@"data"];
        weakSelf.rechargeTypeList2 = arr;
    } fail:^(id object) {
        [[FunctionManager sharedInstance] handleFailResponse:object];
    }];
}
@end
