//
//  DiscoveryViewController.m
//  WeiCaiProj
//
//  Created by fy on 2018/12/25.
//  Copyright © 2018 hzx. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "MemberCell.h"
#import "AlertViewCus.h"
#import "WheelViewController.h"
#import "WebViewController2.h"
#import "WebViewController.h"

@interface DiscoveryViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    NSArray *_dataArray;
}
@end

@implementation DiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"发现";
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CDScreenHeight - 50)  style:UITableViewStyleGrouped];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.rowHeight = 70;
    _tableView.separatorColor = TBSeparaColor;
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    NSMutableDictionary *dic1 = [[NSMutableDictionary alloc] init];
    [dic1 setObject:@"discover_sgyxj" forKey:@"icon"];
    [dic1 setObject:@"水果游戏机" forKey:@"title"];
    [dic1 setObject:@"1" forKey:@"tag"];
    
    NSMutableDictionary *dic2 = [[NSMutableDictionary alloc] init];
    [dic2 setObject:@"discover_xydzp" forKey:@"icon"];
    [dic2 setObject:@"幸运大转盘" forKey:@"title"];
    [dic2 setObject:@"2" forKey:@"tag"];

    NSMutableDictionary *dic3 = [[NSMutableDictionary alloc] init];
    if([FUNCTION_MANAGER appType] == AppType_XZHB){
        [dic3 setObject:@"discover_xzyeb" forKey:@"icon"];
        [dic3 setObject:@"小猪余额宝" forKey:@"title"];
    }else if([FUNCTION_MANAGER appType] == AppType_TTHB){
        [dic3 setObject:@"discover_ttyeb" forKey:@"icon"];
        [dic3 setObject:@"天天余额宝" forKey:@"title"];
    }else if([FUNCTION_MANAGER appType] == AppType_WWHB){
        [dic3 setObject:@"discover_wwyeb" forKey:@"icon"];
        [dic3 setObject:@"旺旺余额宝" forKey:@"title"];
    }else if([FUNCTION_MANAGER appType] == AppType_WBHB){
        [dic3 setObject:@"discover_wbyeb" forKey:@"icon"];
        [dic3 setObject:@" 5 8 余额宝" forKey:@"title"];
    }
    [dic3 setObject:@"3" forKey:@"tag"];
    _dataArray = [NSArray arrayWithObjects:dic2,dic1,dic3, nil];
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        
        cell.itemIcon.layer.masksToBounds = YES;
        cell.itemIcon.layer.cornerRadius = 9.0;
        cell.itemIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    NSDictionary *dic = [_dataArray objectAtIndex:indexPath.row];
    cell.itemIcon.image = [UIImage imageNamed:dic[@"icon"]];
    cell.itemLabel.text = dic[@"title"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *dic = _dataArray[indexPath.row];
    NSInteger tag = [dic[@"tag"] integerValue];
    if(tag == 2){
        WheelViewController *vc = [[WheelViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }else if(tag == 1){
        NSString *urlHead = APP_MODEL.commonInfo[@"fruit.slot.url"];
        if(urlHead.length > 0){
            NSString *url = [NSString stringWithFormat:@"%@?token=%@",urlHead,APP_MODEL.user.token];
            WebViewController *vc = [[WebViewController alloc] initWithUrl:url];
            vc.navigationItem.title = @"水果游戏机";
            vc.hidesBottomBarWhenPushed = YES;
            //[vc loadWithURL:url];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
    }
    AlertViewCus *view = [AlertViewCus createInstanceWithView:nil];
    [view showWithText:@"等待更新，敬请期待" button:@"好的" callBack:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    SVP_DISMISS;
}
@end
