//
//  EventSender.h
//  ConversionTracking
//
//  Created by user1 on 12/18/13.
//  Copyright (c) 2013 Kenshoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventSender : NSObject

@property NSURLResponse *urlResponse;
@property NSError *error;


- (void) send : (NSString *) url;

@end
