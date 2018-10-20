//
//  AllUserViewController.m
//  Project
//
//  Created by mini on 2018/8/16.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "AllUserViewController.h"
#import "UserTableViewCell.h"
#import "GroupNet.h"

@interface AllUserViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}
@property (nonatomic ,strong) GroupNet *model;

@end

@implementation AllUserViewController
+ (AllUserViewController *)allUser:(id)obj{
    AllUserViewController *vc = [[AllUserViewController alloc]init];
    vc.model = obj;
    return vc;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    if (_model == nil) {
        _model = [GroupNet new];
    }
}


#pragma mark ----- Layout
- (void)initLayout{
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    self.view.backgroundColor = BaseColor;
    self.navigationItem.title = @"所有成员";
    
    _tableView = [UITableView normalTable];
    [self.view addSubview:_tableView];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.separatorColor = TBSeparaColor;
    _tableView.rowHeight = 90;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView reloadData];
}



#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _model.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user"];
    if (cell == nil) {
        cell = [[UserTableViewCell alloc]initWithStyle:0 reuseIdentifier:@"user"];
    }
    cell.obj = _model.dataList[indexPath.row];
    return cell;//[tableView CDdequeueReusableCellWithIdentifier:_dataList[indexPath.row]];
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
