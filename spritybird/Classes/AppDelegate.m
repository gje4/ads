//
//  AppDelegate.m
//  spritybird
//
//  Created by Alexis Creuzot on 09/02/2014.
//  Copyright (c) 2014 Alexis Creuzot. All rights reserved.
//

#import "AppDelegate.h"
#import "Flurry.h"
#import "FlurryAds.h"
#import <FacebookSDK/FacebookSDK.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //[NANTracking setDebugMode: YES];
    
    [NANTracking setNanigansAppId:@"1223" fbAppId:@"12321"];
    
    [NANTracking setUserId: [MCSMApplicationUUIDKeychainItem applicationUUID]];

    [NANTracking trackAppLaunch: nil];

    [[Tracking sharedInstance] trackUserEvent: @"game_launch" Value: @""];
    
    
//    [Flurry startSession:@"RBZ3NZ45DB5846SBV632"];
//    
//    //initialize Flurry ad serving, required to provide ViewController
//    [FlurryAds initialize:self.window.rootViewController];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    [[Tracking sharedInstance] trackUserEvent: @"game_resign_active" Value: @""];

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[Tracking sharedInstance] trackUserEvent: @"game_enter_background" Value: @""];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[Tracking sharedInstance] trackUserEvent: @"game_enter_foreground" Value: @""];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[Tracking sharedInstance] trackUserEvent: @"game_become_active" Value: @""];
    
    
    // Logs 'install' and 'app activate' App Events.
    [FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[Tracking sharedInstance] trackUserEvent: @"game_terminate" Value: @""];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [NANTracking trackAppLaunch: url];
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];

    return YES;
}

@end
