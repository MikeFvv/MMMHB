//
//  CDBaseNet.m
//  Project
//
//  Created by zhyt on 2018/7/10.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "CDBaseNet.h"
#import "AFNetworking.h"

@interface CDBaseNet()
@property (nonatomic ,strong) AFHTTPSessionManager *manager;
@end

static AFHTTPSessionManager *manager;

@implementation CDBaseNet


- (AFHTTPSessionManager *)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 10.0;
    });
    return manager;
}

+ (CDBaseNet *)normalNet{
    CDBaseNet *net = [[CDBaseNet alloc]init];
    return net;
}

+ (CDBaseNet *)securityNet{
    CDBaseNet *net = [[CDBaseNet alloc]init];
    return net;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
//        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"image/jpeg", @"image/png",@"text/plain",@"application/octet-stream", nil];
        _manager.requestSerializer.timeoutInterval = 30;
//        _prefix = @"";
    }
    return self;
}

- (void)doGetSuccess:(void (^)(NSDictionary *))success
             failure:(void (^)(NSError *))failue{
    CDLog(@"GETUrl:----%@",self.path);
    CDLog(@"json:--%@",[self.param mj_JSONString]);
    [_manager GET:self.path parameters:self.param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failue(error);
    }];
}

- (void)doPostSuccess:(void (^)(NSDictionary *))success
              failure:(void (^)(NSError *))failue{
    CDLog(@"GETUrl:----%@",self.path);
    CDLog(@"json:--%@",[self.param mj_JSONString]);
    [_manager POST:self.path parameters:self.param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failue(error);
    }];
}

- (void)upLoadSuccess:(void (^)(NSDictionary *))success
              failure:(void (^)(NSError *))failue{
    CDLog(@"GETUrl:----%@",self.path);
    [_manager POST:self.path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:self.param name:@"file" fileName:@"icon.png" mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failue(error);
    }];
}

@end
