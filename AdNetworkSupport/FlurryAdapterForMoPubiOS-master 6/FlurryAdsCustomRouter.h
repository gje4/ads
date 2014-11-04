//
//  FlurryAdsCustomRouter.h
//  MoPub Mediates Flurry
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FlurryAdDelegate.h"
#import "MPInstanceProvider.h"

@interface FlurryAdsCustomRouter : NSObject <FlurryAdDelegate>

// Map of the ad spaces that holds click status
@property (nonatomic,strong) NSMutableDictionary *adSpaceClickMap;

+ (FlurryAdsCustomRouter *)sharedRouter;

- (void)setRouter:(id<FlurryAdDelegate>)router forSpace:(NSString *)space;
- (void)setClickStatus:(BOOL)status forSpace:(NSString*)space;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPInstanceProvider (FlurryAdsRouterBridge)

- (FlurryAdsCustomRouter *)sharedFlurryAdsCustomRouter;
- (void) delegateFlurry: id;

@end