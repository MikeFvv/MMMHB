//
//  MessageViewController.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageNet.h"
#import <RongIMKit/RongIMKit.h>
#import "ChatViewController.h"
#import "MessageItem.h"
#import "WebViewController.h"
#import "ModelHelper.h"

@interface MessageViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
}
@property(nonatomic,strong)MessageNet *model;
@end

@implementation MessageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}


#pragma mark ----- Data
- (void)initData{
    _model = [[MessageNet alloc]init];
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    CDWeakSelf(self);
    __weak MessageNet *weakModel = _model;
    self.navigationItem.title = @"消息";
    
    _tableView = [UITableView normalTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 80;
    _tableView.separatorColor = TBSeparaColor;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        CDStrongSelf(self);
        weakModel.page = 1;
        [self getData];
    }];
    
    _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        if (!weakModel.isMost) {
            CDStrongSelf(self);
            weakModel.page ++;
            [self getData];
        }
    }];
    
    _tableView.StateView = [StateView StateViewWithHandle:^{
        CDStrongSelf(self);
        [self getData];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_tableView.mj_header beginRefreshing];
//        [self test];
    });
    
}

//- (void)test{
//    WebViewController *web = [[WebViewController alloc]initWithUrl:@"http://da8888.com/"];
//    web.hidesBottomBarWhenPushed = YES;
//    UINavigationController *vc = self.tabBarController.viewControllers[0];
//    CDPush(vc, web, YES);
//}

- (void)getData{
    WEAK_OBJ(weakSelf, self);
    [_model requestGroupListWithSuccess:^(NSDictionary *info) {
        [weakSelf reload];
    } Failure:^(NSError *error) {
        [FUNCTION_MANAGER handleFailResponse:error];
        [weakSelf reload];
    }];
}

- (void)reload{
    [_tableView.mj_footer endRefreshing];
    [_tableView.mj_header endRefreshing];
    if(_model.isNetError){
        [_tableView.StateView showNetError];
    }
    else if(_model.isEmpty){
        [_tableView.StateView showEmpty];
    }else{
        [_tableView.StateView hidState];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_tableView reloadData];
    });
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _model.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView CDdequeueReusableCellWithIdentifier:_model.dataList[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    CDTableModel *model = _model.dataList[indexPath.row];
    //MessageItem *item = [MessageItem mj_objectWithKeyValues:model.obj];
    MessageItem *item = [MODEL_HELPER getMessageItem:model.obj];
    if ([item.groupName isEqualToString:@"通知消息"]) {
        CDPush(self.navigationController, CDVC(@"NotifViewController"), YES);
        return;
    }
    if ([item.groupName isEqualToString:@"在线客服"]) {
        WebViewController *vc = [[WebViewController alloc]initWithUrl:ServiceLink];
        vc.title = item.groupName;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
//    float min = [item.minMoney floatValue];
//    float user = [APP_MODEL.user.money floatValue];
//    if (user < min) {
//        SV_ERROR_STATUS(@"余额不足。");
//        return;
//    }
    SV_SHOW;
    CDWeakSelf(self);
    [MESSAGE_NET checkGroupId:item.groupId Completed:^(BOOL complete) {
        CDStrongSelf(self);
        if (complete) {
            SV_DISMISS;
            [self groupChat:item];
        }
        else{
            [MESSAGE_NET joinGroup:item.groupId success:^(NSDictionary *info) {
                SV_DISMISS;
                [self groupChat:item];
            } failure:^(NSError *error) {
                [FUNCTION_MANAGER handleFailResponse:error];
            }];
        }
    }];
}

- (void)groupChat:(id)obj{
    ChatViewController *vc = [ChatViewController groupChatWithObj:obj];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
