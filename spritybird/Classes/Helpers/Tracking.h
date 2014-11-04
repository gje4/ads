//
//  Tracking.h
//  joeybird
//
//  Created by Dana Basken on 8/22/14.
//  Copyright (c) 2014 Alexis Creuzot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tracking : NSObject

+ (Tracking*)sharedInstance;
- (void)trackEvent:(NSString*)event Name:(NSString*)name Value:(NSString*)value;
- (void)trackUserEvent:(NSString*)name Value:(NSString*)value;

@end
