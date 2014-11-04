//
//  ViewController.h
//  spritybird
//
//  Created by Alexis Creuzot on 09/02/2014.
//  Copyright (c) 2014 Alexis Creuzot. All rights reserved.
//

#import "Scene.h"
#import "MPAdView.h"



@interface ViewController : UIViewController<SceneDelegate , MPAdViewDelegate> {
    IBOutlet UIButton *settingsButton;
}

-(IBAction)openSettings:(id)sender;

@property (nonatomic, retain) MPAdView *adView;


@end
