//
//  ZAStitcherManager.h
//  ZAScreenshotStitcher
//
//  Created by CPU11996 on 8/21/19.
//  Copyright © 2019 vng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZASimpleStitcher.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZAStitcherManager : NSObject

- (void)stitchImages:(NSArray<UIImage *> *)images completion:(void (^)(UIImage *result, NSError *error)) callback;

@end

NS_ASSUME_NONNULL_END
