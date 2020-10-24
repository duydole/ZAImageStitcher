//
//  UIImage+Converter.h
//  ZAConversationStitcher
//
//  Created by CPU11996 on 8/20/19.
//  Copyright © 2019 vng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zlib.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Converter)

// Cut Image to subImage with Rect.
- (UIImage*) subImage:(CGRect)rect;

// Convert Image to NSArray of values.
- (NSArray *) toArrayBySumPixelValue;

@end

NS_ASSUME_NONNULL_END
