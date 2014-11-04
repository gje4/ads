//
//  FlurryTakoverCustomEvent.m
//  MoPub Mediates Flurry
//
//  Created by Bisera Ferrero on 10/1/13.
//  Copyright (c) 2013 Flurry. All rights reserved.
//

#import "FlurryInterstitialCustomEvent.h"
#import "FlurryAdDelegate.h"
#import "FlurryAds.h"
#import "FlurryAdsCustomRouter.h"

#import "MPLogging.h"
#import "MPInstanceProvider.h"

/* 
 * Provde adSpaceName param when configuring Flurry as the Custom Native Network
 * in the MoPub web interface {"adSpaceName": "YOUR_FLURRY_AD_SPACE_NAME"}.
 * If adSpaceName is not found, this adapter will use "TAKOVER_AD" as the Flurry ad space name 
 */
#define FlurryAdSpaceTakeoverName @"TAKOVER_AD"
#define FlurryAdPlacement FULLSCREEN


////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPFlurryInterstitialRouter : FlurryAdsCustomRouter

@property (nonatomic, strong) NSMutableDictionary *adspaceToEventsMap;

+ (MPFlurryInterstitialRouter *)sharedRouter;


- (void)fetchTakeoverForSpace:(NSString *)adSpace
                  forFlurryTakoverCustomEvent:(FlurryInterstitialCustomEvent *)event;

- (BOOL)isTakeoverAvailableForSpace:(NSString *) adSpace;

- (void)displayTakeoverForSpace:(NSString *)adSpace
                    onViewController:(UIViewController *)adViewController
                  forFlurryTakoverCustomEvent:(FlurryInterstitialCustomEvent *)event;
- (FlurryInterstitialCustomEvent *)eventForSpace:(NSString *)space;
- (void)setEvent:(FlurryInterstitialCustomEvent *)event forSpace:(NSString *)space;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPInstanceProvider (FlurryTakeovers)

- (MPFlurryInterstitialRouter *)sharedMPFlurryTakoverRouter;
@end

@implementation MPInstanceProvider (FlurryTakeovers)

- (MPFlurryInterstitialRouter *)sharedMPFlurryTakoverRouter
{
    return [self singletonForClass:[MPFlurryInterstitialRouter class]
                          provider:^id{
                              return [[MPFlurryInterstitialRouter alloc] init];
                          }];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////


@interface  FlurryInterstitialCustomEvent()

@property (nonatomic, strong) NSString *adSpaceName;

@end

@implementation FlurryInterstitialCustomEvent

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    self.adSpaceName = [info objectForKey:@"adSpaceName"];
    if (!self.adSpaceName) {
        self.adSpaceName = FlurryAdSpaceTakeoverName;
    }
    
    [[MPInstanceProvider sharedProvider] delegateFlurry:[MPFlurryInterstitialRouter sharedRouter]];
    
    [[MPFlurryInterstitialRouter sharedRouter] fetchTakeoverForSpace:self.adSpaceName
                                     forFlurryTakoverCustomEvent:self];
}


- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if ([[MPFlurryInterstitialRouter sharedRouter]isTakeoverAvailableForSpace:self.adSpaceName] )
    {
        [[MPFlurryInterstitialRouter sharedRouter] displayTakeoverForSpace:self.adSpaceName
                                                               onViewController:rootViewController
                                                              forFlurryTakoverCustomEvent:self];
    } 
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

@end
////////////////////////////////////////////////////////////////////////////////////////////////////

/*
 * Flurry only provides a shared instance, so only one object may be the FlurryAds delegate at
 * any given time. However, because it is common to request Flurry Takeovers for separate
 * adSpaces in a single app session, we may have multiple instances of our custom event class,
 * all of which are interested in delegate callbacks.
 *
 * MPFlurryTakoverRouter is a singleton that is always the FlurryAd delegate, and dispatches
 * events to all of the custom event instances.
 */

@implementation MPFlurryInterstitialRouter

@synthesize adspaceToEventsMap = _adspaceToEventsMap;


+ (MPFlurryInterstitialRouter *)sharedRouter
{
    return [[MPInstanceProvider sharedProvider] sharedMPFlurryTakoverRouter];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.adspaceToEventsMap = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc
{
    MPLogInfo(@"dealloc Flurry Takover Router");
    
    // Remove all pre-cached ads
    [self removeAdsFromFlurryCache];
    
    self.adspaceToEventsMap = nil;
}

- (void)fetchTakeoverForSpace:(NSString *)adSpace
 forFlurryTakoverCustomEvent:(FlurryInterstitialCustomEvent *)event {
    
    MPLogInfo(@"Flurry Ads being fethced for [%@]" , adSpace);
    
    [self setEvent:event forSpace:adSpace];
    [self setRouter:self forSpace:adSpace];
    
    CGSize size =    [[UIScreen mainScreen] bounds].size;
    CGRect theRect = CGRectMake(0, 0, size.width, size.height);
    
    [FlurryAds fetchAdForSpace:adSpace frame:theRect size:FlurryAdPlacement];
    
}

- (BOOL)isTakeoverAvailableForSpace:(NSString *) adSpace;
{
    return [FlurryAds adReadyForSpace:adSpace];
}

-(void)displayTakeoverForSpace:(NSString *)adSpace
                   onViewController:(UIViewController *)adViewController
  forFlurryTakoverCustomEvent:(FlurryInterstitialCustomEvent *)event
{
    MPLogInfo(@"Flurry Ads being displayed for [%@]" , adSpace);
    
    [self setEvent:event forSpace:adSpace];
    
    [FlurryAds displayAdForSpace:adSpace onView:adViewController.view];
}

- (FlurryInterstitialCustomEvent *)eventForSpace:(NSString *)space{
    return [self.adspaceToEventsMap objectForKey:space];
}

- (void)setEvent:(FlurryInterstitialCustomEvent *)event forSpace:(NSString *)space {
    [self.adspaceToEventsMap setObject:event forKey:space];
}

- (void)removeAdsFromFlurryCache {
    for (NSString *adspace in [self.adspaceToEventsMap keyEnumerator]) {
        [FlurryAds removeAdFromSpace:adspace];
    }
}

#pragma mark - FlurryAdDelegate

- (void)spaceDidReceiveAd:(NSString *)adSpace {
    MPLogInfo(@"FlurryTakover Ad Space [%@] Did Receive Ad  ", adSpace);
    
    [[self eventForSpace:adSpace].delegate  interstitialCustomEvent:[self eventForSpace:adSpace] didLoadAd:nil];
}

- (void)spaceDidFailToReceiveAd:(NSString *)adSpace error:(NSError *)error {
    MPLogInfo(@"FlurryTakover Ad Space [%@] Did Fail to Receive Ad with error [%@]  ", adSpace, error);
    [[self eventForSpace:adSpace].delegate interstitialCustomEvent:[self eventForSpace:adSpace] didFailToLoadAdWithError:error];
}

- (void) videoDidFinish:(NSString *)adSpace{
    MPLogInfo(@"FlurryTakover Ad Space [%@] Video Did Finish   ", adSpace);
}

- (BOOL) spaceShouldDisplay:(NSString*)adSpace interstitial:(BOOL)interstitial {
    MPLogInfo(@"FlurryTakover Ad Space [%@] Should Display Ad for interstitial [%d]  ", adSpace, interstitial);
    
    return YES;
}

- (void)spaceWillDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial {
    MPLogInfo(@"FlurryTakover Ad Space [%@] Will Dismiss for interstitial [%d]  ", adSpace, interstitial);
    [[self eventForSpace:adSpace].delegate interstitialCustomEventWillDisappear:[self eventForSpace:adSpace]];
    
}

- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial {
    MPLogInfo(@"FlurryTakover Ad Space [%@] Did Dismiss for interstitial [%d]  ", adSpace, interstitial);
    [[self eventForSpace:adSpace].delegate interstitialCustomEventDidDisappear:[self eventForSpace:adSpace]];
}

- (void)spaceWillLeaveApplication:(NSString *)adSpace {
    MPLogInfo(@"FlurryTakover Ad Space [%@] Will Leave Application  ", adSpace);
    
    
    FlurryInterstitialCustomEvent *customEvent = [self eventForSpace:adSpace];
    
    if (![[self.adSpaceClickMap objectForKey:adSpace] boolValue]) {
        [customEvent.delegate trackClick];
        [self.adSpaceClickMap setObject:[NSNumber numberWithBool:YES] forKey:adSpace];
    }
    
    [customEvent.delegate interstitialCustomEventWillLeaveApplication:[self eventForSpace:adSpace]];
}

- (void) spaceDidRender:(NSString *)space interstitial:(BOOL)interstitial {
    MPLogInfo(@"FlurryTakover Ad Space [%@] did render Ad for interstitial [%d]  ", space, interstitial);
    FlurryInterstitialCustomEvent * customEvent = [self eventForSpace:space];
    
    // Tell MoPub Flurry ad is about to be rendered
    if (customEvent != nil)
    {
        [customEvent.delegate trackImpression];
        [customEvent.delegate  interstitialCustomEventWillAppear:[self eventForSpace:space]];
        
        //  Set the ad space click map to unclicked as we have new ad to show
        [self.adSpaceClickMap setObject:[NSNumber numberWithBool:NO] forKey:space];
    }
}

- (void) spaceDidFailToRender:(NSString *) adSpace error:(NSError *)error {
    MPLogInfo(@"FlurryTakover Ad Space [%@] Did Fail to Render with error [%@]  ", adSpace, error);
}

- (void) spaceDidReceiveClick:(NSString *)adSpace {
    MPLogInfo(@"FlurryTakover Ad Space [%@] Did Receive Click  ", adSpace);
    
    if (![[self.adSpaceClickMap objectForKey:adSpace] boolValue]) {
        [[self eventForSpace:adSpace].delegate trackClick];
        [self.adSpaceClickMap setObject:[NSNumber numberWithBool:YES] forKey:adSpace];
    }
}

- (void)spaceWillExpand:(NSString *)adSpace {
    MPLogInfo(@"FlurryTakover Ad Space [%@] Will Expand  ", adSpace);
}

- (void)spaceDidCollapse:(NSString *)adSpace {
    MPLogInfo(@"FlurryTakover Ad Space [%@] Did Collapse  ", adSpace);
}

@end


