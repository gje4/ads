//
//  Score.m
//  spritybird
//
//  Created by Alexis Creuzot on 16/02/2014.
//  Copyright (c) 2014 Alexis Creuzot. All rights reserved.
//

#import "Score.h"

@implementation Score

+ (void)registerScore:(NSInteger)score {

    if(score > [Score bestScore]){
        [Score setBestScore:score];
    }
}

+ (void) setBestScore:(NSInteger) bestScore {
    [[NSUserDefaults standardUserDefaults] setInteger:bestScore forKey:kBestScoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[Tracking sharedInstance] trackUserEvent: @"personal_best" Value: [NSString stringWithFormat:@"%d", (int)bestScore]];
}

+ (NSInteger) bestScore {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kBestScoreKey];
}

@end
