//
//  Tracking.m
//  joeybird
//
//  Created by Dana Basken on 8/22/14.
//  Copyright (c) 2014 Alexis Creuzot. All rights reserved.
//

#import "Tracking.h"

@implementation Tracking

static Tracking* _sharedInstance = nil;

+ (Tracking*)sharedInstance {
	@synchronized(self)     {
		if (!_sharedInstance) {
			_sharedInstance = [[Tracking alloc] init];
		}
	}
	return _sharedInstance;
}

- (void)trackEvent:(NSString*)event Name:(NSString*)name Value:(NSString*)value {
    NSDictionary *params = @{@"sku": @"joeybird", @"value": value};
    [NANTracking trackNanigansEvent: event name: name extraParams: params];
}

- (void)trackUserEvent:(NSString*)name Value:(NSString*)value {
    [self trackEvent: @"user" Name: name Value: value];
}

@end
