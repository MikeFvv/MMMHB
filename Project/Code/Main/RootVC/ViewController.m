//
//  ViewController.m
//  Project
//
//  Created by Mike on 2019/1/17.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    self.view.backgroundColor = [UIColor redColor];
}

- (void)initUI {
    UIButton *testBtn = [UIButton new];
    [self.view addSubview:testBtn];
    testBtn.layer.cornerRadius = 8;
    testBtn.layer.masksToBounds = YES;
    testBtn.backgroundColor = MBTNColor;
    testBtn.titleLabel.font = [UIFont boldSystemFontOfSize2:17];
    [testBtn setTitle:@"eeee测试测试" forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
    [testBtn delayEnable];
    [testBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.top.equalTo(self.view.mas_top).offset(200);
        make.height.equalTo(@(44));
    }];
    
}
- (void)testAction {
    ViewController *vc = [ViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
