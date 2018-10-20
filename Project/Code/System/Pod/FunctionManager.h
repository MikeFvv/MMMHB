//
//  FunctionManager.h
//  I_am_here
//
//  Created by caesar on 13-5-2.
//  Copyright (c) 2013年 caesar. All rights reserved.
//应用中需要用到的一些函数

#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, FixTypes)
{
    FixTypes_width,
    FixTypes_height,
};//哪个固定

#define FUNCTION_MANAGER [FunctionManager sharedInstance]

@interface FunctionManager : NSObject<CLLocationManagerDelegate,UIAlertViewDelegate>{
    BOOL _showFailAlert;//显示出错，防止重复提醒
}
@property(nonatomic,strong)UIWebView *phoneCallWebView;
@property(nonatomic,strong)CLLocationManager *locationManager;

+(FunctionManager *)sharedInstance;
+(void)destroyInstance;
-(NSString *)getApplicationBundleId;
-(NSString *)getDeviceModel;//机器型号 如iPod4,1,
-(NSString *)getIosVersion;//系统版本号 如4.3.5
-(NSString *)getApplicationVersion;//软件版本
-(NSString *)getApplicationName;//获取应用名
-(NSString *)getApplicationID;//软件ID
-(void)showAlertWithTitle:(NSString *)title andText:(NSString *)text;//弹出无回调的警告框

- (NSInteger)getWeekFromString:(NSString *)dateString;

- (NSString *)stringFromDate:(NSDate *)date;

-(NSDate*)dateFromString:(NSString*)uiDate andFormat:(NSString *)format;

-(BOOL)checkIsNum:(NSString *)str;

-(BOOL)validatePassword:(NSString *)passWord;
-(BOOL)validateEmail:(NSString *)email;
-(BOOL)validateNickname:(NSString *)nickname;
-(BOOL)validateIdentityCard: (NSString *)identityCard;
-(BOOL)validatePhone:(NSString *)phone;

-(UIImage*)imageWithColor:(UIColor*)color;
-(UIImage*)imageWithColor:(UIColor*)color andSize:(CGSize)size;

-(int)heightForLabel:(UILabel *)label;

-(int)heightForStr:(NSString *)string andFont:(UIFont *)font andLineBreakMode:(NSLineBreakMode)mode andWidth:(int)width;

- (NSString *)URLEncodedWithString:(NSString *)url;//将有中文的地址转成url编码
- (NSString *)encodedWithString:(NSString *)string;

-(UITableViewCell *)cellForChildView:(UIView *)view;

-(void)fetchVersionInfo;

-(CGSize)getFitSizeWithLabel:(UILabel *)label;
-(CGSize)getFitSizeWithLabel:(UILabel *)label withFixType:(FixTypes)fixType;
- (NSInteger)getAttributedStringHeightWithString:(NSAttributedString *)string  andWidth:(NSInteger)width;

-(void)startLocation;

-(long long)fileSizeAtPath:(NSString*) filePath;
-(float)folderSizeAtPath:(NSString*)folderPath;


//归档
-(BOOL)archiveWithData:(id)data andFileName:(NSString *)fileName;
-(id)readArchiveWithFileName:(NSString *)fileName;

//跳过icloud备份
-(BOOL)skipIcoundBackupAtURL:(NSString*)filePath;


-(UIViewController *)currentViewController;

//-(NSString *)documentCachePath;

-(void)showIndicatorView:(NSString *)text andSuperView:(UIView *)view;
-(void)showIndicatorView:(NSString *)text;
-(void)dismissIndicatorView;

//通用处理接口返回的错误
-(void)handleFailResponse:(id)responseObj;
@end
