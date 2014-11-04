//
//  UrlGenerator.h
//  ConversionTracking
//
//  Created by user1 on 12/3/13.
//  Copyright (c) 2013 Kenshoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UrlGenerator : NSObject

- (NSString *) generateFrom:(NSString *) event : (double) revenue : (NSString *) currency : (NSString *) fbAttribution :
(NSString *) bundleId : (NSString *) advertiserId : (float) osVersion : (NSDictionary *) additionalParameters;

@end
