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
    [dic1 setObject:@"discover_qpyx" forKey:@"icon"];
    [dic1 setObject:@"棋 牌 游 戏" forKey:@"title"];
    
    NSMutableDictionary *dic2 = [[NSMutableDictionary alloc] init];
    [dic2 setObject:@"discover_bjsc" forKey:@"icon"];
    [dic2 setObject:@"北 京 赛 车" forKey:@"title"];
    
    NSMutableDictionary *dic3 = [[NSMutableDictionary alloc] init];
    [dic3 setObject:@"discover_cqssc" forKey:@"icon"];
    [dic3 setObject:@"重庆时时彩" forKey:@"title"];
    
    NSMutableDictionary *dic4 = [[NSMutableDictionary alloc] init];
    [dic4 setObject:@"discover_hbyyb" forKey:@"icon"];
    [dic4 setObject:@"红包余额包" forKey:@"title"];
    
    NSMutableDictionary *dic5 = [[NSMutableDictionary alloc] init];
    [dic5 setObject:@"discover_xxxyx" forKey:@"icon"];
    [dic5 setObject:@"休闲小游戏" forKey:@"title"];
    
    NSMutableDictionary *dic6 = [[NSMutableDictionary alloc] init];
    [dic6 setObject:@"discover_gdyx" forKey:@"icon"];
    [dic6 setObject:@"更 多 游 戏" forKey:@"title"];
    
    _dataArray = [NSArray arrayWithObjects:dic1,dic2,dic3,dic4,dic5,dic6, nil];
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
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"等待更新，敬请期待" preferredStyle:UIAlertControllerStyleAlert];
//    [alertController modifyColor];
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDestructive handler:nil];
//    [okAction setValue:Color_0 forKey:@"_titleTextColor"];
//    [alertController addAction:okAction];
//    [self presentViewController:alertController animated:YES completion:nil];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self presentViewController:alertController animated:YES completion:nil];
//    });
    AlertViewCus *view = [AlertViewCus createInstanceWithView:nil];
    [view showWithText:@"等待更新，敬请期待" button:@"好的" callBack:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    SVP_DISMISS;
}
@end
