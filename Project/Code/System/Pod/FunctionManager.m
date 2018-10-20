//
//  FunctionManager.m
//  I_am_here
//
//  Created by caesar on 13-5-2.
//  Copyright (c) 2013年 caesar. All rights reserved.
//

#import "FunctionManager.h"
#import <CoreText/CoreText.h>
#import "sys/utsname.h"

static FunctionManager *instance = nil;

@implementation FunctionManager

+(instancetype)sharedInstance{
    static dispatch_once_t instFun;
    dispatch_once(&instFun, ^{
    if(instance == nil){
        instance = [[FunctionManager alloc] init];
    }
    });
    return instance;
}

+(void)destroyInstance{
    if(instance){
        instance = nil;
    }
}

-(id)init{
    if(self = [super init]){
        _showFailAlert = YES;
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

-(NSString *)getApplicationBundleId{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
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
    return [self heightForStr:label.text andFont:label.font andLineBreakMode:label.lineBreakMode andWidth:label.width];
}

-(int)heightForStr:(NSString *)string andFont:(UIFont *)font andLineBreakMode:(NSLineBreakMode)mode andWidth:(int)width{
    CGSize size = CGSizeMake(width,9999);
    CGSize labelsize = [string sizeWithFont:font constrainedToSize:size lineBreakMode:mode];
    return labelsize.height + 2;
}

- (void)exitApp{
    exit(0);
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

-(void)makeCall:(NSString *)phoneNum{
    if(phoneNum.length == 0)
        return;
    NSURL *phoneNumberURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", phoneNum]];
    
    if (!self.phoneCallWebView ) {
        self.phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [self.phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneNumberURL]];
}

-(CGSize)getFitSizeWithLabel:(UILabel *)label{
    return [self getFitSizeWithLabel:label withFixType:FixTypes_width];
}

#pragma mark
-(CGSize)getFitSizeWithLabel:(UILabel *)label withFixType:(FixTypes)fixType{
    NSString *str = label.text;
    CGSize size;
    if(fixType == FixTypes_width)
        size = CGSizeMake(label.width, 999);
    else
        size = CGSizeMake(999, label.height);
    
    CGSize titleSize;
    titleSize = [str sizeWithFont:label.font constrainedToSize:size lineBreakMode:label.lineBreakMode];
    titleSize.height += 1;
    titleSize.width += 1;
    return titleSize;
}

-(void)showFailAlertAction{
    _showFailAlert = YES;
}


#pragma mark 定位
-(void)startLocation{
    // 判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }else {
        //提示用户无法进行定位操作
    }
    
    // 开始定位
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization ];
    }
    if(self.locationManager)
        [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    
    CLLocationCoordinate2D coor = currentLocation.coordinate;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSNumber numberWithDouble:coor.latitude] forKey:@"local_latitude"];
    [ud setObject:[NSNumber numberWithDouble:coor.longitude] forKey:@"local_longitude"];
    [ud synchronize];
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notif_localCoordinateBack object:nil userInfo:nil];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coor.latitude longitude:coor.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error){
        if (error){
            NSLog(@"failed with error: %@", error);
            return;
        }
        if(placemarks.count > 0){
            CLPlacemark *placemark = placemarks[0];
            NSDictionary *addressDic = placemark.addressDictionary;
            NSString *city = addressDic[@"City"];
            if(city){
                city = [city stringByReplacingOccurrencesOfString:@"市" withString:@""];
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:city forKey:@"local_city"];
                [ud synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:notif_localCityBack object:city];
            }
        }
    }];
}

- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias{
    NSLog(@"iResCode = %d,tags = %@服务器返回的结果：%@",iResCode,tags,alias);
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

- (NSInteger)getAttributedStringHeightWithString:(NSAttributedString *)string  andWidth:(NSInteger)width{
    NSInteger total_height = 0;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);    //string 为要计算高度的NSAttributedString
    CGRect drawingRect = CGRectMake(0, 0, width, 1000);  //这里的高要设置足够大
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

#pragma mark indicator
-(void)showIndicatorView:(NSString *)text andSuperView:(UIView *)view{
    [INDICATOR_VIEW showWithText:text andSuperView:view];
}

-(void)showIndicatorView:(NSString *)text{
    [INDICATOR_VIEW showWithText:text];
}
-(void)dismissIndicatorView{
    [INDICATOR_VIEW dismiss];
}

#pragma mark
-(NSString *)formatTimeWithTime:(NSString *)times{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:times];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components =
    [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:destDate];
    //    NSDateComponents *components2 =
    //    [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    NSInteger month = [components month];
    NSInteger day = [components day];
    NSInteger hour = [components hour];
    NSInteger minutes = [components minute];
    double time = [destDate timeIntervalSince1970];
    
    NSString *str = @"";
    double tTime = [[NSDate date] timeIntervalSince1970];
    components =
    [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    NSInteger nowDay = [components day];
    
    double timeInv = tTime - time;
    if(timeInv < 60)
        timeInv = 60;
    if(time == 0){
        str = @"刚刚";
    }
    else if(nowDay == day && timeInv < 3600)
    {
        str = [NSString stringWithFormat:@"%d分钟前",(int)timeInv/60];
    }
    else if(nowDay == day && timeInv < 24 * 3600)
    {
        str = [NSString stringWithFormat:@" 今天 %02ld:%02ld",(long)hour,(long)minutes];
    }
    else
        str = [NSString stringWithFormat:@"%02ld-%02ld %02ld:%02ld",(long)month,(long)day,(long)hour,(long)minutes];
    return str;
}

-(CGSize)getFitSizeWithStr:(NSString *)str andFont:(UIFont *)font andMaxSize:(CGSize)maxSize{
    CGSize titleSize;
    titleSize = [str sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    titleSize.height += 1;
    titleSize.width += 1;
    return titleSize;
}

-(void)handleFailResponse:(id)responseObj{
    if([responseObj isKindOfClass:[NSError class]]){
        NSError *error = responseObj;
        SV_ERROR_STATUS([error description]);
        return;
    }
    NSDictionary *responseDic = responseObj;
    ResultCode code = (ResultCode)[[responseDic objectForKey:@"code"] integerValue];
    if([responseDic objectForKey:@"code"] && code != ResultCodeSuccess){
        if(responseDic[@"msg"])
            SV_ERROR_STATUS(responseDic[@"msg"]);
        else
            SV_ERROR_STATUS(@"请求授权失败");
    }else if(responseDic[@"error"]){
        if([responseDic[@"error"] isEqualToString:@"unauthorized"])
            SV_ERROR_STATUS(@"用户不存在");
        else if([responseDic[@"error"] isEqualToString:@"invalid_grant"])
            SV_ERROR_STATUS(@"密码错误");
        else
            SV_ERROR_STATUS(responseDic[@"error"]);
    }
    else
        SV_DISMISS;
}

-(NSArray *)getBankList{
    return [self readArchiveWithFileName:@"bankList"];
}

- (void)updateChat:(NSString *)chatId number:(NSInteger)number lastMessage:(NSString *)message lastTime:(NSString *)lastTime{
    BOOL isIn = NO;
    for (NSMutableDictionary *dic in APP_MODEL.unReadNumberArray) {
        NSString *cId = dic[@"chatId"];
        if([cId isEqualToString:chatId]){
            NSInteger unreadNum = [dic[@"unreadNum"] integerValue];
            if(number == -1)
                dic[@"unreadNum"] = @"0";
            else
                dic[@"unreadNum"] = [NSString stringWithFormat:@"%ld",unreadNum+number];
            dic[@"lastMessage"] = message;
            dic[@"lastTime"] = lastTime;
            isIn = YES;
            break;
        }
    }
    if(isIn == NO){
        if(number > 0){
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:chatId forKey:@"chatId"];
            [dic setObject:[NSString stringWithFormat:@"%ld",number] forKey:@"unreadNum"];
            dic[@"lastMessage"] = message;
            dic[@"lastTime"] = lastTime;
            [APP_MODEL.unReadNumberArray addObject:dic];
        }
    }
    [FUNCTION_MANAGER archiveWithData:APP_MODEL.unReadNumberArray andFileName:@"unreadRecord"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CDReadNumberChange" object:nil];
}
@end
