//
//  HelpCenterWebController.m
//  Project
//
//  Created by Mike on 2019/3/20.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "HelpCenterWebController.h"

@interface HelpCenterWebController ()
@property(nonatomic,strong)NSMutableArray *guideArray;
@end

@implementation HelpCenterWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"帮助中心";
    UIButton *regisBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    regisBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [regisBtn setTitle:@"新手引导" forState:UIControlStateNormal];
    [regisBtn addTarget:self action:@selector(guideAction) forControlEvents:UIControlEventTouchUpInside];
    [regisBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:regisBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - 新手引导页
- (void)guideAction{
    SVP_SHOW;
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER getGuideImageListWithSuccess:^(id object) {
        SVP_DISMISS;
        NSArray *arr = object[@"data"];
        weakSelf.guideArray = [NSMutableArray array];
        for (NSDictionary *dic in arr) {
            [weakSelf.guideArray addObject:dic[@"content"]];
        }
        [weakSelf showGuide];
    } fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
}

-(void)showGuide{
    if(self.guideArray.count == 0){
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    GuideView *guideView = [[GuideView alloc] initWithArray:self.guideArray target:nil selector:nil];
    [guideView showWithAnimationWithAni:YES];
}
@end