//
//  FlurryAdsCustomRouter.m
//  MoPub Mediates Flurry
//
//  Copyright (c) 2013 Flurry. All rights reserved.
//

#import "FlurryAdsCustomRouter.h"
#import "MPLogging.h"
#import "MPInstanceProvider.h"

#import "Flurry.h"
#import "FlurryAds.h"

#define FlurryAPIKey @"YOUR_APP_FLURRY_API_KEY"
#define FlurryMediationOrigin @"Flurry_Mopub_iOS"
#define FlurryAdapterVersion @"5.1.0.r1"

/*
 * Flurry only provides a shared instance, so only one object may be the FlurryAds delegate at
 * any given time for both banners and takeovers. We therefore need a Router that will communicate
 * delegate callbacks to the correct Banner or Takeover router. This is that class.
 *
 * FlurryAdsCustomRouter is a singleton that is always the global FlurryAd delegate.
 */

@interface FlurryAdsCustomRouter () 

// Map of the ad spaces to the proper router
@property (nonatomic,strong) NSMutableDictionary *adSpaceToRouterMap;

- (id<FlurryAdDelegate>)routerForSpace:(NSString *)space;

@end

@implementation MPInstanceProvider (FlurryAdsRouterBridge)

- (void) delegateFlurry: id
{
    [FlurryAds setAdDelegate:id];
}


- (FlurryAdsCustomRouter *)sharedFlurryAdsCustomRouter
{
    return [self singletonForClass:[FlurryAdsCustomRouter class]
                          provider:^id{
                              return [[FlurryAdsCustomRouter alloc] init];
                          }];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FlurryAdsCustomRouter

@synthesize adSpaceToRouterMap = _adSpaceToRouterMap;
@synthesize adSpaceClickMap = _adSpaceClickMap;

+ (FlurryAdsCustomRouter *)sharedRouter
{
    return [[MPInstanceProvider sharedProvider] sharedFlurryAdsCustomRouter];
}

- (id)init
{
    MPLogInfo(@"Intialize Flurry Ads Router");
    self = [super init];
    if (self) {
        self.adSpaceToRouterMap = [NSMutableDictionary dictionary];
        self.adSpaceClickMap = [NSMutableDictionary dictionary];
        
        [Flurry startSession:FlurryAPIKey];
        [Flurry addOrigin:FlurryMediationOrigin withVersion:FlurryAdapterVersion];
        [Flurry setDebugLogEnabled:NO];
        
        MPLogInfo(@"Intialize Flurry Custom Router, version %@: ",FlurryAdapterVersion );
    }
    
    return self;
}

- (void)dealloc
{
    MPLogInfo(@"dealloc Flurry Ads Router");
    [[MPInstanceProvider sharedProvider] delegateFlurry:nil];
    self.adSpaceToRouterMap = nil;
    self.adSpaceClickMap = nil;
}

- (id<FlurryAdDelegate>)routerForSpace:(NSString *)space
{
    return [self.adSpaceToRouterMap objectForKey:space];
}

- (void)setRouter:(id<FlurryAdDelegate>)router forSpace:(NSString *)space
{
    [self.adSpaceToRouterMap setObject:router forKey:space];
}

- (void)setClickStatus:(BOOL)status forSpace:(NSString*)space
{
    
    if ([self.adSpaceClickMap objectForKey:space] == nil) {
        [self.adSpaceClickMap setObject:[NSNumber numberWithBool:status] forKey:space];
    }
}

#pragma mark - FlurryAdDelegate
- (void)spaceDidReceiveAd:(NSString *)adSpace
{
    MPLogInfo(@"Routing Ad Space [%@] spaceDidReceiveAd", adSpace);
    [[self routerForSpace:adSpace] spaceDidReceiveAd:adSpace];
}

- (void)spaceDidFailToReceiveAd:(NSString*)adSpace error:(NSError *)error
{
    MPLogInfo(@"Routing Ad Space [%@] spaceDidFailToReceiveAd %@", adSpace, error.userInfo[@"NSLocalizedDescription"]);

    [[self routerForSpace:adSpace] spaceDidFailToReceiveAd:adSpace error:error];
}

- (BOOL) spaceShouldDisplay:(NSString*)adSpace interstitial:(BOOL)interstitial {
    MPLogInfo(@"Routing Ad Space [%@] Should Display Ad for interstitial [%d]", adSpace, interstitial);

    return [[self routerForSpace:adSpace] spaceShouldDisplay:adSpace interstitial:interstitial];
}

- (void)spaceDidReceiveClick:(NSString*)adSpace
{
    MPLogInfo(@"Routing Ad Space  %@ Click received", adSpace);
    
    [[self routerForSpace:adSpace] spaceDidReceiveClick:adSpace];
}

- (void) videoDidFinish:(NSString *)adSpace{
    MPLogInfo(@"Routing Ad Space [%@] Video Did Finish", adSpace);
    
    [[self routerForSpace:adSpace] videoDidFinish:adSpace];
}

- (void)spaceWillDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial {
    MPLogInfo(@"Routing Ad Space [%@] Will Dismiss for interstitial [%d]", adSpace, interstitial);
    
    [[self routerForSpace:adSpace] spaceWillDismiss:adSpace interstitial:interstitial];
}

- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial {
    MPLogInfo(@"Routing Ad Space [%@] Did Dismiss for interstitial [%d]", adSpace, interstitial);
    
    [[self routerForSpace:adSpace] spaceDidDismiss:adSpace interstitial:interstitial];
}

- (void)spaceWillLeaveApplication:(NSString *)adSpace {
    MPLogInfo(@"Routing Ad Space [%@] Will Leave Application", adSpace);

    [[self routerForSpace:adSpace] spaceWillLeaveApplication:adSpace];
}

- (void) spaceDidFailToRender:(NSString *) adSpace error:(NSError *)error {
    MPLogInfo(@"Routing Ad Space [%@] Did Fail to Render with error [%@]", adSpace, error);

    [[self routerForSpace:adSpace] spaceDidFailToRender:adSpace error:error];
}

- (void)spaceWillExpand:(NSString *)adSpace {
    MPLogInfo(@"Routing Ad Space [%@] Will Expand", adSpace);
    
    [[self routerForSpace:adSpace] spaceWillExpand:adSpace];
}

- (void)spaceDidCollapse:(NSString *)adSpace {
    MPLogInfo(@"Routing Ad Space [%@] Did Collapse", adSpace);
    
    [[self routerForSpace:adSpace] spaceDidCollapse:adSpace];
}

@end