//
//  ZAStitcherManager.m
//  ZAScreenshotStitcher
//
//  Created by CPU11996 on 8/21/19.
//  Copyright © 2019 vng. All rights reserved.
//

#import "ZAStitcherManager.h"
//#import "OpenCVStitcher.h"

@interface ZAStitcherManager ()

@property ZASimpleStitcher *simpleStitcher;         // stitching by simple algorithm
//@property OpenCVStitcher *opencvStitcher;           // stitching by OpenCV

@end

@implementation ZAStitcherManager

- (instancetype) init {
    self = [super init];
    if (self) {
        _simpleStitcher = [[ZASimpleStitcher alloc] init];
//        _opencvStitcher = [[OpenCVStitcher alloc] init];
    }
    return self;
}

- (void) stitchImages:(NSArray<UIImage *> *)images completion:(void (^)(UIImage * _Nonnull, NSError * _Nonnull))callback {

    NSLog(@"dld: Stitching by Simple Algorithm.....");
    [_simpleStitcher stitchImages:images completion:^(UIImage *result, NSError *error) {
//        if (!error) {
            if (result) {
                NSLog(@"dld: Stitching success by Simple Algorithm");
            }
            callback(result, error);
//        } else {
//            NSLog(@"dld: Simple Algorithm failed => Stitching by OpenCV.....");
//
//            [self.opencvStitcher stitchImages:images completion:^(UIImage *result, NSError *error) {
//                if (result) {
//                    NSLog(@"dld: Stitching success by OpenCV");
//                }
//                callback(result,error);
//            }];
//        }
    }];

}

@end
