//
//  ImageDetailViewController.m
//  Project
//
//  Created by fy on 2019/1/28.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "ImageDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface ImageDetailViewController ()

@end

@implementation ImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.bgColor == nil)
        self.bgColor = COLOR_X(228, 32, 52);
    self.view.backgroundColor = self.bgColor;
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setTranslucent:NO];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView = scrollView;
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imageView];
    [self showImage];
}

-(void)showImage{
    if(self.imageUrl){
        WEAK_OBJ(weakSelf, self);
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [weakSelf resetImageView];
        }];
    }
}

-(void)resetImageView{
    UIImage *img = self.imageView.image;
    if(img == nil)
        return;
    
    self.imageView.frame = CGRectMake(0, 0,img.size.width, img.size.height);
    float rate = img.size.width/img.size.height;
    float x = self.insetsValue;
    float width = SCREEN_WIDTH - x * 2;
    float height = width/rate;
    height += self.insetsValue;
    self.imageView.frame = CGRectMake(x, self.insetsValue,width, height);
    if(height <= self.scrollView.frame.size.height)
        height = self.scrollView.frame.size.height + 1;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, height);
    
    if(self.imageView.frame.size.height < self.scrollView.frame.size.height - 70){
        CGPoint point = self.imageView.center;
        point.y = (self.scrollView.frame.size.height - 70)/2.0;
        self.imageView.center = point;
    }
    [self writeTitle];
}

-(void)writeTitle{
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
