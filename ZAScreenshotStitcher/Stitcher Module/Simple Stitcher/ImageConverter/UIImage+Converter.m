//
//  UIImage+Converter.m
//  ZAConversationStitcher
//
//  Created by CPU11996 on 8/20/19.
//  Copyright © 2019 vng. All rights reserved.
//

#import "UIImage+Converter.h"

@implementation UIImage (Converter)

- (UIImage *) subImage:(CGRect)rect {
    
    if (self.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * self.scale,
                          rect.origin.y * self.scale,
                          rect.size.width * self.scale,
                          rect.size.height * self.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return result;
}

- (NSArray *) toArrayBySumPixelValue {
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    const int imageWidth = self.size.width;
    const int imageHeight = self.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    uint32_t *curPtr = rgbImageBuf;
    uint8_t* ptr;
    int sum;
    for (int row = 0; row < imageHeight; row++) {
        sum = 0;
        for (int col = 0; col < imageWidth; col++) {
            ptr = (uint8_t*)curPtr;
            sum = sum + col*(ptr[1] + ptr[2] + ptr[3]);
            curPtr++;
        }
        [lines addObject:@(sum)];
    }
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    free(rgbImageBuf);
    
    return lines;
}

@end
