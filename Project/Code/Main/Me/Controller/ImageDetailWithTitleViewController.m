//
//  ImageDetailWithTitleViewController.m
//  Project
//
//  Created by fy on 2019/1/31.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "ImageDetailWithTitleViewController.h"

@interface ImageDetailWithTitleViewController ()

@end

@implementation ImageDetailWithTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getData];
}

-(void)getData{
    SVP_SHOW;
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER getFirstRewardWithUserId:self.userId rewardType:self.rewardType success:^(id object) {
        SVP_DISMISS;
        NSDictionary *data = [object objectForKey:@"data"];
        weakSelf.text = [NSString stringWithFormat:@"已领取：%@元",data[@"reward"]];
        NSString *image = [[data objectForKey:@"skPromot"] objectForKey:@"img"];
        weakSelf.imageUrl = image;
        [weakSelf showImage];
    } fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)writeTitle{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize2:21];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = COLOR_X(228, 32, 52);;
    label.text = self.text;
    [self.imageView addSubview:label];
    label.frame = CGRectMake(0, 192, self.imageView.frame.size.width, 50);
}

@end
