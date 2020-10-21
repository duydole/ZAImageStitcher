//
//  ZAScreenshotStitcher.h
//  ZAScreenshotStitcher
//
//  Created by CPU11996 on 8/20/19.
//  Copyright © 2019 vng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IMAGE_STITCHER_DOMAIN @"duydl.stitcher.domain"

// ErrorCode when Stitching:
typedef NS_ENUM(NSInteger, ZAStitchErrorCode) {
    ZAStitchErrorCodeNotEqualWidth,                     // input images not equal width.
    ZAStitchErrorCodeNotOverlap,                        // input images not overlap
    ZAStitchErrorCodeNotEnoughImages                    // < 2 images
};


// Every Stitcher must implement this protocol.
@protocol ZAStitcherProtocol <NSObject>

@required
/**
 Stitch 2 images together.
 
 @param topImage Top Image
 @param botImage Bottom Image
 @param callback return Result and Error
 */
- (void) stitchTopImage:(UIImage*)topImage withBotImage:(UIImage*)botImage completion:(void (^)(UIImage* result, NSError *error))callback;

/**
 Stitch an array of images
 
 @param images input images
 @param callback return Result and Error.
 */
- (void) stitchImages:(NSArray<UIImage*>*)images completion:(void (^)(UIImage* result, NSError *error)) callback;


/**
 errorCode when stitching.
 */
@property ZAStitchErrorCode errorCode;

@end

// Stitcher using Simple Algorithm
@interface ZASimpleStitcher : NSObject<ZAStitcherProtocol>

// required property:
@property ZAStitchErrorCode errorCode;

@end
