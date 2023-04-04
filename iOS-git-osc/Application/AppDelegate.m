//
//  AppDelegate.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-4.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "UIColor+Util.h"

#import "UMSocial.h"
#import "WeiboSDK.h"

#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
//#import "UMSocialSinaSSOHandler.h"
#import "UMMobClick/MobClick.h"

#import "OSCShareManager.h"

#define UMENG_APPKEY        @"5423cd47fd98c58f04000c52"

static NSString * const SINA_APP_KEY = @"3645105737";
static NSString * const SINA_APP_SECRET = @"3fbd38f46f9a2dd0207160c4a8d82149";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UMSocialData setAppKey:UMENG_APPKEY];
    [UMSocialWechatHandler setWXAppId:@"wx850b854f6aad6764" appSecret:@"39859316eb9e664168d2af929e46f971" url:@"http://www.umeng.com/social"];
    
    [UMSocialQQHandler setQQWithAppId:@"1101982202" appKey:@"c7394704798a158208a74ab60104f0ba" url:@"http://www.umeng.com/social"];
    if ([WeiboSDK isWeiboAppInstalled]) {
//        [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:SINA_APP_KEY
//                                                  secret:SINA_APP_SECRET
//                                             RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
//
        /************ 第三方登录设置 *************/
        [WeiboSDK enableDebugMode:YES];
        [WeiboSDK registerApp:SINA_APP_KEY];

    }
    

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.backgroundColor=UIColorFromRGB(0x272727);
	
    self.window.rootViewController = [MainViewController new];
    [self.window makeKeyAndVisible];
	
	[[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x0a5090)];        //UIColorFromRGB(0x1f1f1f)
	NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
	[[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
	[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];               //UIColorFromRGB(0xdadada)
	
    /************ 友盟数据统计分析 *************/
    UMConfigInstance.appKey = UMENG_APPKEY;
    UMConfigInstance.channelId = @"AppStore";
    [MobClick setAppVersion:XcodeAppVersion];
    [MobClick startWithConfigure:UMConfigInstance];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //隐藏分享面板
    OSCShareManager *shareManeger = [OSCShareManager shareManager];
    [shareManeger hiddenShareBoard];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}


- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *title = NSLocalizedString(@"发送结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken)
        {
            self.wbtoken = accessToken;
        }
        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserID = userID;
        }
        [alert show];
    }
//    else if ([response isKindOfClass:WBAuthorizeResponse.class])
//    {
//        NSString *title = NSLocalizedString(@"认证结果", nil);
//        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId: %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken],  NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                              otherButtonTitles:nil];
//        
//        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
//        self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
//        self.wbRefreshToken = [(WBAuthorizeResponse *)response refreshToken];
//        [alert show];
//    }
}

@end
