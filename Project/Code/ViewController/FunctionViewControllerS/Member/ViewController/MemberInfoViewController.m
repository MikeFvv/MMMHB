//
//  MemberInfoViewController.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MemberInfoViewController.h"

@interface MemberInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    UITableView *_tableView;
    UIImageView *_headIcon;
    UILabel *_nickName;
    UILabel *_sexLabel;
    NSInteger _sexType;
    NSString *_headUrl;
}

@end

@implementation MemberInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
    [self addObserver];
}

#pragma mark ----- Data
- (void)initData{
    _sexType = APP_MODEL.user.userGender;
    _headUrl = APP_MODEL.user.userAvatar;
}

- (void)addObserver{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(action_nick:) name:@"UPDATENAME" object:nil];
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.navigationItem.title = @"编辑资料";
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 40)];
    btn.titleLabel.font = [UIFont scaleFont:14];
    [btn setTitle:@"保存" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(action_save) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = right;
    
    _tableView = [UITableView normalTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.separatorColor = TBSeparaColor;
    
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont scaleFont:15];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"头像";
            
            _headIcon = [UIImageView new];
            [cell.contentView addSubview:_headIcon];
            _headIcon.layer.cornerRadius = 22;
            _headIcon.layer.masksToBounds = YES;
            _headIcon.backgroundColor = [UIColor randColor];
            [_headIcon cd_setImageWithURL:[NSURL URLWithString:[NSString cdImageLink:_headUrl]] placeholderImage:[UIImage imageNamed:@"user-default"]];
            
            [_headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(cell.contentView.mas_right).offset(-12);
                make.centerY.equalTo(cell.contentView);
                make.height.width.equalTo(@(44));
            }];
        }
        else if (indexPath.row == 1){
            cell.textLabel.text = @"昵称";
            
            _nickName = [UILabel new];
            [cell.contentView addSubview:_nickName];
            _nickName.font = [UIFont scaleFont:14];
            _nickName.text = APP_MODEL.user.userNick;
            
            [_nickName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(cell.contentView.mas_right).offset(-12);
                make.centerY.equalTo(cell.contentView);
            }];
            
        }else{
            
            cell.textLabel.text = @"性别";
            
            _sexLabel = [UILabel new];
            [cell.contentView addSubview:_sexLabel];
            _sexLabel.font = [UIFont scaleFont:15];
            _sexLabel.text = (APP_MODEL.user.userGender == 1)?@"男":@"女";
            
            [_sexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(cell.contentView.mas_right).offset(-12);
                make.centerY.equalTo(cell.contentView);
            }];
        }
        
        cell.accessoryType = 1;//(indexPath.row <2)?1:0;
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.row >0)?50:60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"图片库",@"相机",@"相册", nil];
        sheet.tag = 1;
        [sheet showInView:self.view];
    }
    if (indexPath.row == 1) {
        CDPush(self.navigationController, CDVC(@"UpdateNicknameViewController"), YES);
    }
    
    if (indexPath.row == 2) {
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
        sheet.tag = 2;
        [sheet showInView:self.view];
    }
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1) {//头像
        if (buttonIndex == 3) {
            return;
        }
        UIImagePickerController *pick = [[UIImagePickerController alloc]init];
        pick.sourceType = buttonIndex;
        pick.delegate = self;
        [self presentViewController:pick animated:YES completion:nil];
    }
    if (actionSheet.tag == 2) {//性别
        if (buttonIndex == 2) {
            return;
        }
        _sexType = buttonIndex+1;
        _sexLabel.text = (_sexType == 1)?@"男":@"女";
    }
    NSLog(@"%ld",buttonIndex);
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *key = nil;
    if (picker.allowsEditing) {
        key = UIImagePickerControllerEditedImage;
    } else {
        key = UIImagePickerControllerOriginalImage;
    }
    UIImage * image = [info objectForKey:key];
    [self upload:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark action
- (void)action_save{
    
    SV_SHOW;
    CDWeakSelf(self);
    [AppModel updataUserObj:@{@"uid":APP_MODEL.user.userId,@"face":_headUrl,@"nickname":_nickName.text,@"gender":@(_sexType)} Success:^(NSDictionary *info) {
        CDStrongSelf(self);
        [self updateInfo];
        SV_SUCCESS_STATUS([info objectForKey:@"msg"]);
    } Failure:^(NSError *error) {
        SV_ERROR(error);
    }];
}

- (void)updateInfo{
    APP_MODEL.user.userAvatar = _headUrl;
    APP_MODEL.user.userNick = _nickName.text;
    APP_MODEL.user.userGender = _sexType;
    [APP_MODEL saveToDisk];
}

- (void)upload:(UIImage *)image{
    SV_SHOW;
    UIImage *img = CD_TailorImg(image, CGSizeMake(100, 100));
    [AppModel uploadIconObj:img Success:^(NSDictionary *info) {
        SV_SUCCESS_STATUS(@"上传成功");
        self-> _headUrl = [info objectForKey:@"path"];
        self-> _headIcon.image = img;
    } Failure:^(NSError *error) {
        SV_ERROR(error);
    }];
}

- (void)action_nick:(NSNotification *)notif{
    _nickName.text = notif.object[@"text"];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
