//
//  ViewController.m
//  Project
//
//  Created by zhyt on 2018/7/10.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "ViewController.h"
#import "RongYunManager.h"
#import "TabbarButton.h"


@interface ViewController ()<UITabBarControllerDelegate>{
    TabbarButton *_tabbar[4];
    NSInteger _selectIndex;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initSubViewControllers];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateValue)name:@"CDReadNumberChange" object:nil];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self test];
//    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [RONG_YUN_MANAGER connect];
}

//- (void)test{
//    NSURL *url = [[NSURL alloc] initWithString: @"http://da8888.com/" ];
//    [[UIApplication sharedApplication] openURL:url];
//}

#pragma mark 收到消息重新刷新
- (void)updateValue{
    NSInteger num = 0;
    for (NSDictionary *dic in APP_MODEL.unReadNumberArray) {
        NSInteger ureadNum = [dic[@"unreadNum"] integerValue];
        num += ureadNum;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tabbar[1] setBadeValue:(num>0)?@"1":@"0"];
    });
}

- (void)initSubViewControllers{
    _selectIndex = 0;
    self.delegate = self;
    
    NSArray *vcs = @[@"MessageViewController",@"GroupViewController",@"DiscoverViewController",@"MemberViewController"];
    NSArray *titles = @[@"消息",@"群组",@"发现",@"我的"];
    NSArray *nors = @[@"footer-icon-tip",@"footer-icon-group",@"tabar_find",@"footer-icon-my"];
    NSArray *ses = @[@"footer-icon-tip-on",@"footer-icon-group-on",@"tabar_find_on",@"footer-icon-my-on"];
    NSMutableArray *vs = [[NSMutableArray alloc]init];
    CGFloat w = CDScreenWidth/vcs.count;
    for (int i = 0; i<vcs.count; i++) {
        UIViewController *vc = [[NSClassFromString(vcs[i])alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        [vs addObject:nav];
        _tabbar[i] = [TabbarButton tabbar];
        [self.tabBar addSubview:_tabbar[i]];
        _tabbar[i].frame = CGRectMake(i *w, 0, w, 50);
        _tabbar[i].title = titles[i];
        _tabbar[i].normalImg = [UIImage imageNamed:nors[i]];
        _tabbar[i].selectImg = [UIImage imageNamed:ses[i]];
        _tabbar[i].tabbarSelected = (i == _selectIndex)?YES:NO;
        if (i == 1){
            [self updateValue];
        }
    }
    self.viewControllers = vs;
}

#pragma mark UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    NSUInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if(_selectIndex == index){
        return;
    }
    _tabbar[_selectIndex].tabbarSelected = NO;
    _tabbar[index].tabbarSelected = YES;
    _selectIndex = index;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
