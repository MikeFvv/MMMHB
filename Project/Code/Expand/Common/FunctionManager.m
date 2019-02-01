//
//  FunctionManager.m
//  I_am_here
//
//  Created by wc on 13-5-2.
//  Copyright (c) 2013年 wc. All rights reserved.
//

#import "FunctionManager.h"
#import "sys/utsname.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/socket.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <arpa/inet.h>
#import <AVFoundation/AVFoundation.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#include <mach/mach_host.h>
#include <mach/machine.h>
#include <mach/host_info.h>
#include <mach/mach_time.h>

@implementation FunctionManager

+(instancetype)sharedInstance{
    static dispatch_once_t onceFun;
    static FunctionManager *instance = nil;
    dispatch_once(&onceFun, ^{
    if(instance == nil){
        instance = [[FunctionManager alloc] init];
    }});
    return instance;
}

-(id)init{
    if(self = [super init]){
    }
    return self;
}

#pragma mark
-(NSString *)getDeviceModel{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

-(NSString *)getIosVersion{
    return [[UIDevice currentDevice] systemVersion];
}

-(NSString *)getApplicationVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

-(NSString *)getApplicationName{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

-(NSString *)getApplicationID{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppId"];
}

-(void)showAlertWithTitle:(NSString *)title andText:(NSString *)text{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (NSInteger)getWeekFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =
    [gregorian components:NSWeekdayCalendarUnit fromDate:destDate];
    NSInteger weekday = [weekdayComponents weekday];
    return weekday;
}

- (NSString *)stringFromDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSEraCalendarUnit |NSYearCalendarUnit | NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit | NSMinuteCalendarUnit fromDate: date];
    
    [comps setMinute:00];
    
    NSDate *newDate =  [calendar dateFromComponents:comps];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:newDate];
    return destDateString;
}

-(NSDate*)dateFromString:(NSString*)uiDate andFormat:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:format];
    NSDate *date=[formatter dateFromString:uiDate];
    return date;
}

#pragma mark 验证
-(BOOL)checkIsNum:(NSString *)str{
    NSString * regex        = @"(^[0-9.]{0,15}$)";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch            = [pred evaluateWithObject:str];
    return isMatch;
}

-(BOOL)checkIsInteger:(NSString *)str{
    NSString * regex        = @"(^[0-9]{0,15}$)";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch            = [pred evaluateWithObject:str];
    return isMatch;
}

-(BOOL)validateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

-(BOOL)validatePhone:(NSString *)phone{
//    NSString *phoneRegex = @"^((1[0-9]))\\d{9}$";
//    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
//    //    NSLog(@"phoneTest is %@",phoneTest);
//    return [phoneTest evaluateWithObject:phone];
    if(phone.length < 6)
        return NO;
    NSString *s = [phone substringToIndex:1];
    if([s isEqualToString:@"1"])
        return YES;
    return NO;
}

//密码
-(BOOL)validatePassword:(NSString *)passWord{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,20}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}

//昵称
-(BOOL)validateNickname:(NSString *)nickname{
    NSString *nicknameRegex = @"^[\u4e00-\u9fa5]{4,8}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nicknameRegex];
    return [passWordPredicate evaluateWithObject:nickname];
}

//身份证号
-(BOOL)validateIdentityCard: (NSString *)identityCard{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}

#pragma mark
-(UIImage*)imageWithColor:(UIColor*)color{
    return [self imageWithColor:color andSize:CGSizeMake(5, 3)];
}

-(UIImage*)imageWithColor:(UIColor*)color andSize:(CGSize)size{
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(int)heightForLabel:(UILabel *)label{
    return [self heightForStr:label.text andFont:label.font andLineBreakMode:label.lineBreakMode andWidth:label.frame.size.width];
}

-(int)heightForStr:(NSString *)string andFont:(UIFont *)font andLineBreakMode:(NSLineBreakMode)mode andWidth:(int)width{
    CGSize size = CGSizeMake(width,9999);
    CGSize labelsize = [string sizeWithFont:font constrainedToSize:size lineBreakMode:mode];
    return labelsize.height + 2;
}

- (void)exitApp{
    exit(0);
}

-(NSString *)fullPathWithUrl:(NSString *)url{
    return nil;
}

-(UITableViewCell *)cellForChildView:(UIView *)view{
    while (![view.superview isKindOfClass:[UITableViewCell class]]) {
        view = view.superview;
        if(view == nil)
            return nil;
    }
    return (UITableViewCell *)view.superview;
}

- (NSString *)URLEncodedWithString:(NSString *)url{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)url,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              NULL,
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

- (NSString *)encodedWithString:(NSString *)string{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)string,
                                                              NULL,
                                                              (CFStringRef)@":/?&=;+!@#$()',*",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

#pragma mark
-(void)fetchVersionInfo{
    
}

-(void)requestVersionInfoBack:(NSDictionary *)dict{
}

-(CGSize)getFitSizeWithLabel:(UILabel *)label{
    return [self getFitSizeWithLabel:label withFixType:FixTypes_width];
}

#pragma mark
-(CGSize)getFitSizeWithLabel:(UILabel *)label withFixType:(FixTypes)fixType{
    NSString *str = label.text;
    CGSize size;
    if(fixType == FixTypes_width)
        size = CGSizeMake(label.frame.size.width, 999);
    else
        size = CGSizeMake(999, label.frame.size.height);
    
    CGSize titleSize;
    titleSize = [str sizeWithFont:label.font constrainedToSize:size lineBreakMode:label.lineBreakMode];
    titleSize.height += 1;
    titleSize.width += 1;
    return titleSize;
}

#pragma mark 文件大小
//单个文件的大小
-(long long)fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//遍历文件夹获得文件夹大小，返回多少M
-(float)folderSizeAtPath:(NSString*)folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

#pragma mark 保存本地
-(BOOL)archiveWithData:(id)data andFileName:(NSString *)fileName{
    NSString *cachePath = [self documentCachePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@",cachePath,fileName];
    
    BOOL result = [NSKeyedArchiver archiveRootObject:data toFile:path];
    return result;
}

-(id)readArchiveWithFileName:(NSString *)fileName{
    NSString *cachePath = [self documentCachePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@",cachePath,fileName];
    id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return obj;
}

#pragma mark
-(BOOL)skipIcoundBackupAtURL:(NSString*)filePath{
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return NO;
    NSError* error = nil;
    BOOL success= [[NSURL fileURLWithPath:filePath] setResourceValue:[NSNumber numberWithBool:YES]forKey:NSURLIsExcludedFromBackupKey error:&error];
    return success;
}

#pragma mark 获取当前vc
-(UIViewController *)currentViewController{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    if([result isKindOfClass:[UITabBarController class]]){
        result = ((UITabBarController *)result).selectedViewController;
    }
    if([result isKindOfClass:[UINavigationController class]])
        result = [((UINavigationController *)result).viewControllers lastObject];
    return result;
}

#pragma mark document下创建的保存所有缓存的目录
-(NSString *)documentCachePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/Cache",[paths objectAtIndex:0]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        [self skipIcoundBackupAtURL:path];
    }
    return path;
}

-(NSString *)localPathByTail:(NSString *)tail{
    NSString *documentPath = [self documentCachePath];
    return [NSString stringWithFormat:@"%@/%@",documentPath,tail];
}

- (NSInteger)getAttributedStringHeightWithString:(NSAttributedString *)string width:(NSInteger)width height:(NSInteger)height{
    NSInteger total_height = 0;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);    //string 为要计算高度的NSAttributedString
    CGRect drawingRect = CGRectMake(0, 0, width, height);  //这里的高要设置足够大
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    
    NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
    CGPoint origins[[linesArray count]];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    int line_y = (int) origins[[linesArray count] -1].y;  //最后一行line的原点y坐标
    
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    CTLineRef line = (__bridge CTLineRef) [linesArray objectAtIndex:[linesArray count]-1];
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    total_height = 1000 - line_y + (int) descent +1 + linesArray.count * 8;    //+1为了纠正descent转换成int小数点后舍去的值
    CFRelease(textFrame);
    return total_height;
}

-(UIWindow *)getMainView{
    UIWindow *view = nil;
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows)
        if (window.windowLevel == UIWindowLevelNormal) {
            view = window;
            break;
        }
    return view;
}

-(CGSize)getFitSizeWithStr:(NSString *)str andFont:(UIFont *)font andMaxSize:(CGSize)maxSize{
    CGSize titleSize;
    titleSize = [str sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    titleSize.height += 1;
    titleSize.width += 1;
    return titleSize;
}

-(void)handleFailResponse:(id)object{
    if([object isKindOfClass:[NSError class]]){
        NSError *error = (NSError *)object;
        SVP_ERROR(error);
    }else if([object isKindOfClass:[NSDictionary class]]){
        NSDictionary *dd = (NSDictionary *)object;
        if(dd[@"msg"])
            SVP_ERROR_STATUS(dd[@"msg"]);
        else if(dd[@"error"]){
            if([dd[@"error"] isEqualToString:@"unauthorized"]){
                SVP_ERROR_STATUS(@"账号密码错误");
            }else
                SVP_ERROR_STATUS(dd[@"error"]);
        }
    }else if([object isKindOfClass:[NSString class]])
        SVP_ERROR_STATUS(object);
    else
        SVP_DISMISS;
}

-(void)checkVersion:(BOOL)showAlert{
    WEAK_OBJ(weakObj, self);
    [NET_REQUEST_MANAGER requestAppConfigWithSuccess:^(id object) {
        SVP_DISMISS;
        [weakObj checkVersion2:showAlert];
    } fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
}

-(void)checkVersion2:(BOOL)showAlert{
    WEAK_OBJ(weakObj, self);
    NSDictionary *dict = APP_MODEL.commonInfo;
    NSString *appVersion = [self getApplicationVersion];
    NSString *newestVersion = dict[@"ios.version"];
    if([appVersion compare:newestVersion] == NSOrderedAscending){
        NSInteger forceUpate = [dict[@"ios.force.update.flag"] integerValue];
        NSString *desc = dict[@"ios.version.update.content"];
        
        AlertViewCus *view = [AlertViewCus createInstanceWithView:nil];
        if(forceUpate == 0){
            [view showWithText:desc button1:@"更新" button2:@"取消" callBack:^(id object) {
                NSInteger tag = [object integerValue];
                if(tag == 0){
                    NSURL *url = [NSURL URLWithString:APP_MODEL.commonInfo[@"ios.download.path"]];
                    if([[UIApplication sharedApplication] canOpenURL:url])
                        [[UIApplication sharedApplication] openURL:url];
                    [weakObj performSelector:@selector(exitApp) withObject:nil afterDelay:0.5];
                }
            }];
        }else{
            [view showWithText:desc button:@"更新" callBack:^(id object) {
                NSURL *url = [NSURL URLWithString:APP_MODEL.commonInfo[@"ios.download.path"]];
                if([[UIApplication sharedApplication] canOpenURL:url])
                    [[UIApplication sharedApplication] openURL:url];
                [weakObj performSelector:@selector(exitApp) withObject:nil afterDelay:0.5];
            }];
        }
//
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"版本更新" message:desc preferredStyle:UIAlertControllerStyleAlert];
//        [alertController modifyColor];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            NSURL *url = [NSURL URLWithString:APP_MODEL.commonInfo[@"ios.download.path"]];
//            if([[UIApplication sharedApplication] canOpenURL:url])
//                [[UIApplication sharedApplication] openURL:url];
//            [weakObj performSelector:@selector(exitApp) withObject:nil afterDelay:0.5];
//        }];
//        [okAction setValue:Color_0 forKey:@"_titleTextColor"];
//        [alertController addAction:okAction];
//        if(forceUpate == 0){
//            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
//            [cancelAction setValue:Color_0 forKey:@"_titleTextColor"];
//            [alertController addAction:cancelAction];
//        }
//        [[FUNCTION_MANAGER currentViewController] presentViewController:alertController animated:YES completion:nil];
    }else{
        if(showAlert){
            SVP_SUCCESS_STATUS(@"已是最新版本");
        }
    }
}

-(BOOL)testMode{
    if([APP_MODEL.serverUrl rangeOfString:@"/api"].length > 0 || [APP_MODEL.serverUrl rangeOfString:@".com"].length > 0)
        return NO;
    return YES;
}
@end
