//
//  ZAOverlapArea.h
//  ZAScreenshotStitcher
//
//  Created by CPU11996 on 8/22/19.
//  Copyright © 2019 vng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZAOverlapArea : NSObject

/**
 * The beginning overlap index of top image.
 */
@property (nonatomic) NSInteger beginOverlapTopImage;

/**
 * The beginning overlap index of bot image.
 */
@property (nonatomic) NSInteger beginOverlapBotImage;

/**
 * Overlap Height of area.
 */
@property (nonatomic) NSInteger overlapHeight;

/**
 * Distance of beginOverlapTopImage and beginOverlapBotImage
 */
@property (nonatomic) NSInteger distance;
@end
