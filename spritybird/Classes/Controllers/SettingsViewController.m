//
//  SettingsViewController.m
//  joeybird
//
//  Created by Dana Basken on 8/29/14.
//  Copyright (c) 2014 Dana Basken. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize hostType, siteId, qaHost;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([NANTracking getProduction]) {
        self.hostType.selectedSegmentIndex = 0;
    } else {
        self.hostType.selectedSegmentIndex = 1;
        if ([[NANTracking getQA] isEqualToString: @"pqaapi4.nanigans.com"]) {
            [qaHost setSelectedSegmentIndex: 0];
        } else {
            [qaHost setSelectedSegmentIndex: 1];
        }
    }

    self.siteId.text = [NANTracking getNanAppId];
}

-(IBAction)done:(id)sender {
    [self changeSiteId: sender];
    
    if ([NANTracking getProduction]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"PRODUCTION" forKey:@"host"];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NANTracking getQA] forKey:@"host"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NANTracking getNanAppId] forKey:@"appId"];

    [[Tracking sharedInstance] trackUserEvent: @"dismiss_settings" Value: @""];
    [self dismissViewControllerAnimated:YES completion:^(void) {
    }];
}

-(IBAction)selectType:(id)sender {
    NSInteger value = [hostType selectedSegmentIndex];
    if (value == 0) {
        [NANTracking setProduction];
        qaHost.enabled = NO;
    } else {
        [self selectQaHost: sender];
        qaHost.enabled = YES;
    }
}

-(IBAction)selectQaHost:(id)sender {
    NSInteger value = [qaHost selectedSegmentIndex];
    if (value == 0) {
        [NANTracking setQA: @"pqaapi4.nanigans.com"];
    } else {
        [NANTracking setQA: @"pqaapi5.nanigans.com"];
    }
    [self changeSiteId: sender];
}

-(IBAction)changeSiteId:(id)sender {
    [NANTracking setNanigansAppId: siteId.text fbAppId: nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
