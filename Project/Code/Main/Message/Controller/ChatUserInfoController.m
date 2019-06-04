//
//  ChatUserInfoController.m
//  Project
//
//  Created by Mike on 2019/1/7.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "ChatUserInfoController.h"
#import "UserTableViewCell.h"
#import "CharUserInfoCell.h"
#import "BANetManager_OC.h"

@interface ChatUserInfoController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
// 用户信息
@property (nonatomic,strong) id userInfo;

@end

@implementation ChatUserInfoController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self getUserInfoData];
    [self initSubviews];
}

#pragma mark - subView
- (void)initSubviews{
    self.navigationItem.title = @"详细资料";
    self.view.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1.000];
    
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.separatorColor = TBSeparaColor;
    _tableView.rowHeight = 80;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1.000];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)getUserInfoData {
    
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@/%@",[AppModel shareInstance].serverUrl,@"admin/user/baseInfo",self.userId];
    entity.needCache = NO;
    
     SVP_SHOW;
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_GETWithEntity:entity successBlock:^(id response) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
         SVP_DISMISS;
        if ([response objectForKey:@"code"] && [[response objectForKey:@"code"] integerValue] == 0) {
            strongSelf.userInfo = response[@"data"];
            [strongSelf.tableView reloadData];
        } else {
//            NSLog(@"post 请求数据结果： *** %@", response);
        }
        
    } failureBlock:^(NSError *error) {
         SVP_DISMISS;
        [[FunctionManager sharedInstance] handleFailResponse:error];
    } progressBlock:nil];
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CharUserInfoCell *cell = [CharUserInfoCell cellWithTableView:tableView reusableId:@"CharUserInfoCell"];
    
    cell.model = self.userInfo;
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 25;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    return view;
}

@end

