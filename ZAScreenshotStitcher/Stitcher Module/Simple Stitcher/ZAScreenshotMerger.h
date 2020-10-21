//
//  ZAScreenshotMerger.h
//  ZAScreenshotStitcher
//
//  Created by CPU11996 on 8/20/19.
//  Copyright © 2019 vng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIImage+Converter.h"
#import "ZAOverlapArea.h"

// Merger is response for finding the overlap areas between 2 images.
@interface ZAScreenshotMerger : NSObject

/**
 Init MergeInfo
 
 @param topImage Top Image
 @param botImage Bottom Image
 @return instance
 */
- (instancetype) initWithTopImage:(UIImage*)topImage
                         botImage:(UIImage*)botImage;

// Input
@property (nonatomic,strong) UIImage *topImage;
@property (nonatomic,strong) UIImage *botImage;

// Output
@property (nonatomic,assign) NSInteger beginOverlapTopImageRow; // the beginning overlap index of TopImage.
@property (nonatomic,assign) NSInteger beginOverlapBotImageRow; // the beginning overlap index of BotImage.
@property (nonatomic,assign) NSInteger overlapLength;           // overlap length.
@property NSMutableArray<ZAOverlapArea*> *ZAOverlapAreas;

// calculate Overlap Area of 2 images, then store in output params.
- (void) findBestOverlapArea;

@end
