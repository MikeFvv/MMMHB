//
//  EnvelopeListViewController.m
//  Project
//
//  Created by mini on 2018/8/13.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "RedPackedDetListController.h"
#import "EnvelopBackImg.h"
#import "EnvelopeNet.h"
#import "NetRequestManager.h"
#import "NSString+Size.h"



@interface RedPackedDetListController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) EnvelopBackImg *redView;
@property (nonatomic,strong) UIImageView *icon;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *mineLabel;
@property (nonatomic,strong) UILabel *moneyLabel;
@property (nonatomic,strong) UILabel *yuanLabel;
@property (nonatomic,strong) UIImageView *pointsNumImageView;
@property (nonatomic,strong) UIImageView *bankerPlayerImageView;

@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIView *headBackView;
//
@property (nonatomic,assign) CGFloat redImgHeight;
// 未领取红包提示
@property (nonatomic,strong) UILabel *mesLabel;
@property (nonatomic,strong) EnvelopeNet *model;
@property (nonatomic,strong) UILabel *timeLabel;

@property (nonatomic,strong) UILabel *bankerLabel;
@property (nonatomic,strong) UILabel *playerWinLabel;

@property (nonatomic,assign) CGFloat bottomViewHeight;

// timeStr
@property (nonatomic,copy) NSString *oldTimeStr;
//
@property (nonatomic,assign) BOOL isClosed;


@end

@implementation RedPackedDetListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    self.bottomViewHeight = 0;
    self.oldTimeStr = @"99999";
    self.isClosed = NO;
    [self setNavUI];
    [self initSubviews];
    [self initLayout];
    [self setHeadData];
    [self setRefreshUserInfo];
    [self getData];
    
    [_tableView registerClass:NSClassFromString(@"RedPackedDetTableCell") forCellReuseIdentifier:@"RedPackedDetTableCell"];
    [_tableView addSubview:self.headBackView];
    
}

- (void)setNavUI {
    // 中间颜色
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"msg3"] forBarMetrics:UIBarMetricsDefault];
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 100);
    [self.navigationController.navigationBar setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:0.851 green:0.345 blue:0.251 alpha:1.000] size:size] forBarMetrics:UIBarMetricsDefault];
    
    if (self.isRightBarButton) {
        // 右边文字
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"账单记录" style:UIBarButtonItemStylePlain target:self action:@selector(onGotoBill:)];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName, nil] forState:UIControlStateNormal];
    }
    
    // 左边图片和文字
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 30, 44);
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:16];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(10, -12, 10, 10);
    backButton.titleEdgeInsets = UIEdgeInsetsMake(10, -18, 10, 10);
    backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [backButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (UIView *)headBackView {
    if (_headBackView == nil) {
        _headBackView = [[UIView alloc] initWithFrame:CGRectMake(0, -300, [UIScreen mainScreen].bounds.size.width, 300)];
        _headBackView.backgroundColor = [UIColor colorWithRed:0.851 green:0.345 blue:0.251 alpha:1.000];
    }
    return _headBackView;
}

- (UIImageView *)imgView {
    if (_imgView == nil) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -260, [UIScreen mainScreen].bounds.size.width, 260)];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        _imgView.image = [UIImage imageNamed:@"kkkkkk"];
    }
    return _imgView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 100);
    [self.navigationController.navigationBar setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:0.851 green:0.345 blue:0.251 alpha:1.000] size:size] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarBg"] forBarMetrics:UIBarMetricsDefault];
    //    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBarBg"] forBarMetrics:UIBarMetricsDefault];
}


/**
 设置颜色为背景图片

 @param color <#color description#>
 @param size <#size description#>
 @return <#return value description#>
 */
- (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)onGotoBill:(id)sender {
    CDPush(self.navigationController, CDPVC(@"BillViewController", nil), YES);
}

#pragma mark - initData
- (void)initData {
    
    self.model = [EnvelopeNet shareInstance];
    
}

#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews {
    self.navigationItem.title = @"红包详情";
    self.view.backgroundColor = BaseColor;
    
    [self tableViewUI];
    [self redpackedHeadUI];
    
    
    _tableView.StateView = [StateView StateViewWithHandle:^{
        
    }];
    
}

- (void)tableViewUI {
    
    __weak __typeof(self)weakSelf = self;
    _tableView = [UITableView normalTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = TBSeparaColor;
    _tableView.rowHeight = 71;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.model.page = 1;
        [weakSelf getData];
    }];
     self.model.page = 1;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    
    UILabel *mesLabel = [[UILabel alloc] init];
    
    if ([self.model.redPackedInfoDetail[@"type"] integerValue] == 2) {
        mesLabel.text =  kMessCowRefundMessage;
    } else {
        mesLabel.text = [NSString stringWithFormat:@"未领取的红包，将于%0.f分钟后发起退款", self.returnPackageTime/60 <= 1 ? 1 : self.returnPackageTime/60];
    }
    
    mesLabel.font = [UIFont systemFontOfSize:13];
    mesLabel.textColor = Color_6;
    [footView addSubview:mesLabel];
    _mesLabel = mesLabel;
    
    [mesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(footView.mas_centerX);
        make.centerY.mas_equalTo(footView.mas_centerY);
    }];
    
    _tableView.tableFooterView = footView;
}

- (void)redpackedHeadUI {
    
    CGFloat redImgHeight = CD_Scal(40, 667)/0.8;
    _redImgHeight = redImgHeight;
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CDScreenWidth, self.headHeight)];
    headView.backgroundColor = kBackgroundGrayColor;
    _redView = [[EnvelopBackImg alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, redImgHeight) r:400 x:0 y:-(400-redImgHeight)];
    _redView.backgroundColor = [UIColor clearColor];
    [headView addSubview:_redView];
    _headView = headView;
    _tableView.tableHeaderView = headView;
    
    _icon = [UIImageView new];
    [headView addSubview:_icon];
    _icon.layer.cornerRadius = 5;
    _icon.layer.masksToBounds = YES;
    _icon.layer.borderWidth = 1.5;
    _icon.layer.borderColor = [UIColor colorWithRed:0.914 green:0.804 blue:0.631 alpha:1.000].CGColor;
    _icon.image = [UIImage imageNamed:@"user-default"];
    
    [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headView);
        make.centerY.equalTo(self ->_redView.mas_bottom);
        make.height.width.equalTo(@(50));
    }];
    
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont boldSystemFontOfSize2:16];
    [headView addSubview:_nameLabel];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headView);
        make.top.equalTo(self ->_icon.mas_bottom).offset(8);
    }];
    
    
    
    _mineLabel = [UILabel new];
    _mineLabel.font = [UIFont boldSystemFontOfSize2:16];
    _mineLabel.textColor = [UIColor darkGrayColor];
    [headView addSubview:_mineLabel];
    
    [_mineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headView);
        make.top.equalTo(self ->_nameLabel.mas_bottom).offset(5);
    }];
    
    _moneyLabel = [UILabel new];
    [headView addSubview:_moneyLabel];
    _moneyLabel.textColor = [UIColor blackColor];
    //    _moneyLabel.backgroundColor = [UIColor redColor];
    _moneyLabel.font = [UIFont boldSystemFontOfSize2:48];

    [_moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self ->_mineLabel.mas_bottom).offset(5);
        make.centerX.equalTo(headView);
    }];
    
    
    _bankerPlayerImageView = [UIImageView new];
    [headView addSubview:_bankerPlayerImageView];
    
    [_bankerPlayerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.moneyLabel.mas_centerY);
        make.right.equalTo(self.moneyLabel.mas_left).offset(-50);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    _pointsNumImageView = [UIImageView new];
    [headView addSubview:_pointsNumImageView];
    
    [_pointsNumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.moneyLabel.mas_right).offset(5);
        make.bottom.equalTo(self.moneyLabel.mas_bottom).offset(-15);
        make.size.mas_equalTo(CGSizeMake(15, 14.5));
    }];
    
    // 元
    _yuanLabel = [UILabel new];
    [headView addSubview:_yuanLabel];
    _yuanLabel.textColor = Color_3;
    _yuanLabel.font = [UIFont boldSystemFontOfSize2:18];
    
    [_yuanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.moneyLabel.mas_centerY).offset(5);
        make.right.equalTo(self.moneyLabel.mas_left).offset(0);
    }];
    
    _timeLabel = [UILabel new];
    [headView addSubview:_timeLabel];
    _timeLabel.textColor = [UIColor redColor];
    _timeLabel.font = [UIFont systemFontOfSize:18];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.moneyLabel.mas_bottom).offset(10);
        make.centerX.equalTo(headView.mas_centerX);
    }];
    
    
    
}
/**
 庄、闲统计视图
 */
- (void)HeadBottomView {
    
    UIView *leftView = [[UIView alloc] init];
    leftView.backgroundColor = kBackgroundGrayColor;
    [self.headView addSubview:leftView];
    
    UIView *rightView = [[UIView alloc] init];
    rightView.backgroundColor = kBackgroundGrayColor;
    [self.headView addSubview:rightView];
    
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(10);
        make.left.equalTo(self.headView.mas_left);
        make.right.equalTo(self.headView).multipliedBy(0.5);
        make.height.equalTo(@(30));
    }];
    
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftView.mas_right);
        make.top.equalTo(leftView.mas_top);
        make.size.equalTo(leftView);
    }];
    
    UILabel *bankerTitleLabel = [UILabel new];
    bankerTitleLabel.text = @"庄赢";
    [leftView addSubview:bankerTitleLabel];
    bankerTitleLabel.textColor = Color_3;
    bankerTitleLabel.font = [UIFont boldSystemFontOfSize2:17];
    
    [bankerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(leftView.mas_centerY);
        make.centerX.equalTo(leftView.mas_centerX).offset(-10);
    }];
    
    _bankerLabel = [[UILabel alloc] init];
    [leftView addSubview:_bankerLabel];
    _bankerLabel.textColor = [UIColor redColor];
    _bankerLabel.font = [UIFont boldSystemFontOfSize2:17];
    
    [_bankerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bankerTitleLabel.mas_centerY);
        make.left.equalTo(bankerTitleLabel.mas_right).offset(5);
    }];
    
    
    UILabel *playerWinTitleLabel = [UILabel new];
    playerWinTitleLabel.text = @"闲赢";
    [rightView addSubview:playerWinTitleLabel];
    playerWinTitleLabel.textColor = Color_3;
    playerWinTitleLabel.font = [UIFont boldSystemFontOfSize2:17];
    [playerWinTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(rightView.mas_centerY);
        make.centerX.equalTo(rightView.mas_centerX).offset(-10);;
    }];
    
    _playerWinLabel = [[UILabel alloc] init];
    [rightView addSubview:_playerWinLabel];
    _playerWinLabel.textColor = [UIColor redColor];
    _playerWinLabel.font = [UIFont boldSystemFontOfSize2:17];
    
    [_playerWinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(playerWinTitleLabel.mas_centerY);
        make.left.equalTo(playerWinTitleLabel.mas_right).offset(5);
    }];
    
    
}


- (void)setHeadData {
    [_icon cd_setImageWithURL:[NSURL URLWithString:[NSString cdImageLink:self.model.redPackedInfoDetail[@"avatar"]]] placeholderImage:[UIImage imageNamed:@"user-default"]];
    _nameLabel.text = self.model.redPackedInfoDetail[@"nick"];
    
    if ([self.model.redPackedInfoDetail[@"type"] integerValue] == 1) {
        NSDictionary *attrDict = [[self.model.redPackedInfoDetail objectForKey:@"attr"] mj_JSONObject];
        NSString *bombNum = attrDict[@"bombNum"];
        _mineLabel.text = [NSString stringWithFormat:@"%zd-%@", [self.model.redPackedInfoDetail[@"money"] integerValue], bombNum];
        _bankerPlayerImageView.hidden = YES;
    } else if ([self.model.redPackedInfoDetail[@"type"] integerValue] == 2) {
        
        if ([[AppModel shareInstance].user.userId isEqualToString:self.bankerId]) {
            // ****** 庄、闲视图 ******
            [self HeadBottomView];
            if ([self.model.redPackedInfoDetail[@"overFlag"] integerValue] == YES) {
                self.bankerLabel.text = [self.model.redPackedInfoDetail[@"bankWin"] stringValue];
                self.playerWinLabel.text = [self.model.redPackedInfoDetail[@"playerWin"] stringValue];
            } else {
                self.bankerLabel.text = @"-";
                self.playerWinLabel.text = @"-";
            }
        } else {
            // 自己抢的
            if ([self.model.redPackedInfoDetail[@"itselfMoney"] floatValue] > 0 && [self.model.redPackedInfoDetail[@"overFlag"] boolValue] == YES) {
                _bankerPlayerImageView.hidden = NO;
                if ([self.model.redPackedInfoDetail[@"isItselfWin"] boolValue]) {
                    _bankerPlayerImageView.image = [UIImage imageNamed:@"cow_win"];
                } else {
                    _bankerPlayerImageView.image = [UIImage imageNamed:@"cow_lose"];
                }
            } else {
                _bankerPlayerImageView.hidden = YES;
            }
        }
        
        _mineLabel.text = [NSString stringWithFormat:@"￥%zd-%@包", [self.model.redPackedInfoDetail[@"money"] integerValue], self.model.redPackedInfoDetail[@"total"]];
        
        NSInteger time = [self.model.redPackedInfoDetail[@"exceptOverdueTimes"] integerValue];
        
        if ([self.model.redPackedInfoDetail[@"left"] integerValue] == 0 || time <= 0) {
            
            if ([self.model.redPackedInfoDetail[@"overFlag"] boolValue]) {
                self.timeLabel.textColor = [UIColor blackColor];
                self.timeLabel.text = @"本包游戏已截止";
            } else {
                self.timeLabel.textColor = [UIColor redColor];
                self.timeLabel.text = @"结算中...";
            }
            self.isClosed = YES;
        } else {
            [self startWithTime:time title:@"结算中..." countDownTitle:@"秒" mainColor:[UIColor colorWithRed:84/255.0 green:180/255.0 blue:98/255.0 alpha:1.0f] countColor:[UIColor lightGrayColor]];
        }
        
    } else if ([self.model.redPackedInfoDetail[@"type"] integerValue] == 3) {
        NSDictionary *attrDict = [[self.model.redPackedInfoDetail objectForKey:@"attr"] mj_JSONObject];
        NSString *type = attrDict[@"type"];
        if([type isKindOfClass:[NSNumber class]])
            type = [(NSNumber *)type stringValue];
        NSArray *bombNumArray = (NSArray *)[(NSString *)attrDict[@"bombList"] mj_JSONObject];
        bombNumArray = [FUNCTION_MANAGER orderBombArray:bombNumArray];
        NSString *mineNumStr = [FUNCTION_MANAGER formatBombArrayToString:bombNumArray];
//        NSString *mineNumStr = @"[";
//
//        for (NSInteger index = 0; index < bombNumArray.count; index++) {
//            if (index == bombNumArray.count -1) {
//                mineNumStr = [mineNumStr stringByAppendingString: [NSString stringWithFormat:@"%@]", bombNumArray[index]]];
//            } else {
//               mineNumStr = [mineNumStr stringByAppendingString: [NSString stringWithFormat:@"%@,", bombNumArray[index]]];
//            }
//        }
        
        
        mineNumStr = [mineNumStr stringByAppendingString: [[NSString stringWithFormat:@"%ld",type.integerValue] isEqualToString:@"1"] ? @"" : @" 不"];
        _mineLabel.text = [NSString stringWithFormat:@"￥%zd-%zd包-%@", [self.model.redPackedInfoDetail[@"money"] integerValue], [self.model.redPackedInfoDetail[@"total"] integerValue], mineNumStr];
        _bankerPlayerImageView.hidden = YES;
    } else {
        _bankerPlayerImageView.hidden = YES;
        _mineLabel.text = kRedpackedGongXiFaCaiMessage;
    }
}


#pragma mark -  倒计时按钮
/**
 *  倒计时按钮
 *
 *  @param timeLine 倒计时总时间
 *  @param title    还没倒计时的title
 *  @param subTitle 倒计时中的子名字，如时、分
 *  @param mColor   还没倒计时的颜色
 *  @param color    倒计时中的颜色
 */
- (void)startWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color {
    
    //倒计时时间
    __block NSInteger timeOut = timeLine;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //每秒执行一次
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        
        if (timeOut <= 0) {
//            NSLog(@"🔴=1==%@", [NSThread currentThread]);
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //                self.timeLabel.backgroundColor = mColor;
                self.timeLabel.textColor = [UIColor redColor];
                self.timeLabel.text = title;
//                self.timeLabel.userInteractionEnabled = YES;
            });
            [self getData];
        } else {

            NSString *timeStr = [NSString stringWithFormat:@"%0.2ld", (long)timeOut];
            dispatch_async(dispatch_get_main_queue(), ^{
                //                self.timeLabel.backgroundColor = color;
                if ([timeStr integerValue] <= [self.oldTimeStr integerValue] && !self.isClosed) {
                    self.timeLabel.textColor = [UIColor redColor];
                    self.timeLabel.text = [NSString stringWithFormat:@"剩余%@%@",timeStr,subTitle];
//                    self.timeLabel.userInteractionEnabled = NO;
                    self.oldTimeStr = timeStr;
                }
                
            });
            timeOut--;
        }
    });
    dispatch_resume(_timer);
}


-(void)setRefreshUserInfo {

    if ([self.model.redPackedInfoDetail[@"isItself"] boolValue]  == YES) {
        if ([self.model.redPackedInfoDetail[@"type"] integerValue] == 2) {
            self.pointsNumImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"cow_%@", self.model.redPackedInfoDetail[@"itselfPointsNum"]]];
            self.pointsNumImageView.hidden = NO;
        } else {
            self.pointsNumImageView.hidden = YES;
        }
        
        self.moneyLabel.text = [NSString stringWithFormat:@"%@",self.model.redPackedInfoDetail[@"itselfMoney"]];
        
        self.moneyLabel.hidden = NO;
        self.yuanLabel.text = @"￥";
        self.yuanLabel.hidden = NO;
    } else {
        self.pointsNumImageView.hidden = YES;
        self.moneyLabel.hidden = YES;
        self.yuanLabel.hidden = YES;
    }
    
    // 未领取红包提示Label
    if (self.model.dataList.count == [self.model.redPackedInfoDetail[@"total"] integerValue]) {
        self.mesLabel.hidden = YES;
    } else {
        self.mesLabel.hidden = NO;
    }
    
    CGRect headFrame = self.headView.frame;
    headFrame.size.height = self.headHeight;
    self.headView.frame = headFrame;
}


#pragma mark -  计算HeadView高度
/**
 计算HeadView高度
 
 @return 高度值
 */
- (CGFloat)headHeight {
    
    NSDictionary *attrDict = [[self.model.redPackedInfoDetail objectForKey:@"attr"] mj_JSONObject];
    NSString *bombNum = attrDict[@"bombNum"];
    NSString *mineStr = [NSString stringWithFormat:@"%zd-%@", [self.model.redPackedInfoDetail[@"money"] integerValue], bombNum];
    CGFloat nameHeihgt = [self.model.redPackedInfoDetail[@"nick"] heightWithFont:[UIFont boldSystemFontOfSize2:16] constrainedToWidth:SCREEN_WIDTH];
    CGFloat mineHeihgt = [mineStr heightWithFont:[UIFont systemFontOfSize:14] constrainedToWidth:SCREEN_WIDTH];
    NSString *moneyStr = [NSString stringWithFormat:@"%@",self.model.redPackedInfoDetail[@"itselfMoney"]];
    CGFloat moneyHeihgt = 0;
    if (![moneyStr isEqualToString:@"(null)"] && moneyStr.length > 0) {
        moneyHeihgt = [moneyStr heightWithFont:[UIFont boldSystemFontOfSize2:48] constrainedToWidth:SCREEN_WIDTH];
    }
    
    NSString *timeStr = [NSString stringWithFormat:@"%@",self.model.redPackedInfoDetail[@"exceptOverdueTimes"]];
    CGFloat timeHeihgt = 0;
    if (![timeStr isEqualToString:@"(null)"] && timeStr.length > 0) {
         timeHeihgt = [timeStr heightWithFont:[UIFont systemFontOfSize:14] constrainedToWidth:SCREEN_WIDTH];
    }
   
    if ([self.model.redPackedInfoDetail[@"type"] integerValue] == 2 && [[AppModel shareInstance].user.userId isEqualToString: self.bankerId]) {
        self.bottomViewHeight = 30 + 25;
    } else if ([self.model.redPackedInfoDetail[@"type"] integerValue] == 2) {
        self.bottomViewHeight = 20;
    } else {
        self.bottomViewHeight = 0;
    }
    
    CGFloat totalHeight = self.redImgHeight + nameHeihgt + mineHeihgt + moneyHeihgt + timeHeihgt + self.bottomViewHeight + (50/2 + 8+5+5*2 + 5 + 5);
    
    return totalHeight;
}

#pragma mark - 获取红包详情
- (void)getData {
    
    if (self.model.isGrabId) {
        [self setReLoadData];
        return;
    }
    
    NSString *redPackedId;
    if ([self.objPar isKindOfClass:[EnvelopeNet class]]) {
        EnvelopeNet *model = (EnvelopeNet *)self.objPar;
        redPackedId = [model.redPackedInfoDetail[@"id"] stringValue];
    } else if ([self.objPar isKindOfClass:[NSNumber class]]) {
        [self setReLoadData];
        return;
    } else {
        redPackedId = (NSString *)self.objPar;
        self.model.redPackedInfoDetail = [NSMutableDictionary dictionary];
        [self.model.redPackedListArray removeAllObjects];
        [self.model.dataList removeAllObjects];
        SVP_SHOW;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.model getRedpDetSendId:redPackedId successBlock:^(NSDictionary *dic) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        SVP_DISMISS;
        if (([[dic objectForKey:@"code"] integerValue] == 0)) {
            [strongSelf setReLoadData];
        } else {
            [strongSelf setReLoadData];
            SVP_ERROR_STATUS([dic objectForKey:@"msg"]);
        }
    } failureBlock:^(NSError *error) {
        [weakSelf setReLoadData];
        [FUNCTION_MANAGER handleFailResponse:error];
    }];
}

- (void)setReLoadData {
    [self setHeadData];
    [self setRefreshUserInfo];
    [self.tableView reloadData];
    
    [self.tableView.mj_header endRefreshing];
    if (self.model.isNetError) {
        [_tableView.StateView showNetError];
    }
    else if (self.model.isEmpty){
        [_tableView.StateView showEmpty];
    }else{
        [_tableView.StateView hidState];
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    CGFloat curMoneyTotal = 0;
    for (int i = 0; i < self.model.dataList.count; i++){
        CDTableModel *model = _model.dataList[i];
        NSString *strMoney = [model.obj[@"money"] stringByReplacingOccurrencesOfString:@"*" withString:@"0"];
        CGFloat money = [strMoney floatValue];
        curMoneyTotal += money;
    }
    
    NSString *s = [NSString stringWithFormat:@"已领取%ld/%ld个，共%.2f/%@元",self.model.dataList.count,[self.model.redPackedInfoDetail[@"total"] integerValue],curMoneyTotal, self.model.redPackedInfoDetail[@"money"]];
    
    UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 45)];
    sectionHeaderView.backgroundColor = Color_F;
    //sectionHeaderView.layer.shadowColor = [UIColor blackColor].CGColor;
    sectionHeaderView.layer.shadowOffset = CGSizeMake(0, 0);
    sectionHeaderView.layer.shadowOpacity = 0.1;
    
    // 单边阴影 顶边
    float shadowPathWidth = sectionHeaderView.layer.shadowRadius;
    CGRect shadowRect = CGRectMake(0, 0-shadowPathWidth/2.0, sectionHeaderView.bounds.size.width, shadowPathWidth);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
    sectionHeaderView.layer.shadowPath = path.CGPath;
    
    UILabel *label = [UILabel new];
    [sectionHeaderView addSubview:label];
    label.font = [UIFont systemFontOfSize2:14];
    label.textColor = [UIColor darkGrayColor];
    label.text = s;
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(sectionHeaderView.mas_left).offset(15);
        make.centerY.equalTo(sectionHeaderView.mas_centerY);
    }];
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1.000];
    [sectionHeaderView addSubview:bottomView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(sectionHeaderView);
        make.height.mas_equalTo(0.5);
    }];
    
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.model.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView CDdequeueReusableCellWithIdentifier:_model.dataList[indexPath.row]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
