//
//  CDAlertViewController.m
//  Project
//
//  Created by mac on 2018/9/7.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "CDAlertViewController.h"

typedef NS_ENUM(NSInteger, AlertStyle) {
    CDAlertAlert = 0,
    CDAlertDatePiker = 1,
};

typedef void (^PikerHandle)(NSString *date);

@interface CDAlertViewController (){
    UIControl *_backControl;
}

@property (nonatomic ,copy) PikerHandle piker;
@property (nonatomic ,strong) UIView *contentView;

@end

@implementation CDAlertViewController

- (instancetype)initWithStyle:(AlertStyle)style{
    self = [super init];
    if (self) {
        [self initData];
        [self initSubviews];
        [self initLayout];
        if (style == CDAlertDatePiker) {
            [self initPicker];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark ----- Data
- (void)initData{
    
}


#pragma mark ----- Layout
- (void)initLayout{
    [_backControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}



#pragma mark ----- subView
- (void)initSubviews{
    _backControl = [UIControl new];
    [self.view addSubview:_backControl];
    _backControl.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [_backControl addTarget:self action:@selector(action_disMiss) forControlEvents:UIControlEventTouchUpInside];
    
    _contentView = [UIView new];
    [self.view addSubview:_contentView];
}

- (UIDatePicker *)picker{
    if (_picker == nil) {
        _picker = [UIDatePicker new];
        _picker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        _picker.datePickerMode = UIDatePickerModeDate;
        _picker.backgroundColor = [UIColor whiteColor];
//        _picker.date = [NSDate dateWithTimeIntervalSince1970:APP_MODEL.user.jointime];
        [_picker setMaximumDate:[NSDate date]];
        [_picker setMinimumDate:[NSDate dateWithTimeIntervalSince1970:APP_MODEL.user.jointime]];
    }
    return _picker;
}

#pragma mark SetContentView
- (void)initPicker{
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@(216+50));
    }];
    
    [self.contentView addSubview:self.picker];
    [_picker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
    }];
    
    UIButton *cancle = [[UIButton alloc]initWithFrame:CGRectMake(2, 0, 50, 50)];
    [self.contentView addSubview:cancle];
    [cancle setTitle:@"取消" forState:UIControlStateNormal];
    [cancle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancle.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancle addTarget:self action:@selector(action_disMiss) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *maker = [[UIButton alloc]initWithFrame:CGRectMake(CDScreenWidth-52, 0, 50, 50)];
    [self.contentView addSubview:maker];
    [maker setTitle:@"确定" forState:UIControlStateNormal];
    [maker setTitleColor:MBTNColor forState:UIControlStateNormal];
    maker.titleLabel.font = [UIFont systemFontOfSize:14];
    [maker addTarget:self action:@selector(action_make) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark action
- (void)action_disMiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)action_make{
    [self action_disMiss];
    if (self.piker) {
        self.piker(dateString_date(_picker.date,CDDateDay));
    }
}

+ (void)showDatePikerDate:(void (^)(NSString *))date{
    CDAlertViewController *alert = [[CDAlertViewController alloc]initWithStyle:CDAlertDatePiker];
    alert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alert.piker = date;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

+ (void)showDatePikerDate:(void (^)(NSString *))date defaultTime:(double)defaultTime{
    CDAlertViewController *alert = [[CDAlertViewController alloc]initWithStyle:CDAlertDatePiker];
    alert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alert.piker = date;
    alert.picker.date = [NSDate dateWithTimeIntervalSince1970:defaultTime];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
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
