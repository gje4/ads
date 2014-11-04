//
//  KenshooTracking.h
//  KenshooTracking
//
//  Created by Avihay Tsayeg on 1/20/14.
//  Copyright (c) 2014 Kenshoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UrlGenerator.h"

@interface KenshooTracking : NSObject

-(void) trackInstall;

-(void) trackInstall: (double)revenue : (NSString *)currency;

-(void) trackEvent: (NSString *)event : (double)revenue : (NSString *)currency;

-(void) trackEvent: (NSString *)event : (double)revenue : (NSString *)currency : (NSDictionary*)additionalParameters;

@end
