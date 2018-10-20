//
//  SVProgressHUD+CDHUD.h
//  Project
//
//  Created by mini on 2018/8/3.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "SVProgressHUD.h"

@interface SVProgressHUD (CDHUD)

#define SV_SHOW [SVProgressHUD show]
#define SV_SUCCESS_STATUS(a) [SVProgressHUD showSuccessWithStatus:a]
#define SV_ERROR_STATUS(a) [SVProgressHUD showErrorWithStatus:a]
#define SV_ERROR(a)  [SVProgressHUD showError:a]
#define SV_DISMISS [SVProgressHUD dismiss]
#define SV_PROGRESS(a,b) [SVProgressHUD showProgress:a status:b]
#define SV_SHOW_STATUS(a)  [SVProgressHUD showWithStatus:a]

+ (void)showError:(NSError *)error;

@end
