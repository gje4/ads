//
//  SettingsViewController.h
//  joeybird
//
//  Created by Dana Basken on 8/29/14.
//  Copyright (c) 2014 Dana Basken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController;

@property (nonatomic) IBOutlet UISegmentedControl *hostType;
@property (nonatomic) IBOutlet UISegmentedControl *qaHost;
@property (nonatomic) IBOutlet UITextField *siteId;

-(IBAction)done:(id)sender;
-(IBAction)selectType:(id)sender;
-(IBAction)selectQaHost:(id)sender;
-(IBAction)changeSiteId:(id)sender;

@end
