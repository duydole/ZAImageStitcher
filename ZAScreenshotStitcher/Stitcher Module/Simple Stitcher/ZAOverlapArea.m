//
//  ZAOverlapArea.m
//  ZAScreenshotStitcher
//
//  Created by CPU11996 on 8/22/19.
//  Copyright © 2019 vng. All rights reserved.
//

#import "ZAOverlapArea.h"

@implementation ZAOverlapArea

- (NSInteger) distance {
    
    NSInteger distance = _beginOverlapTopImage - _beginOverlapBotImage;
    
    return distance;
    
}

@end
