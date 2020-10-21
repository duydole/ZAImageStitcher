//
//  ZAScreenshotStitcher.m
//  ZAScreenshotStitcher
//
//  Created by CPU11996 on 8/20/19.
//  Copyright © 2019 vng. All rights reserved.
//

#import "ZASimpleStitcher.h"
#import "ZAScreenshotMerger.h"
#import "UIImage+Converter.h"
#import "ZAOverlapArea.h"

@interface ZASimpleStitcher()

@property NSMutableArray<ZAScreenshotMerger*> *listMergeInfors;
@property NSArray<UIImage*> *images;

@end

@implementation ZASimpleStitcher

- (instancetype)init
{
    self = [super init];
    if (self) {
        _listMergeInfors = [[NSMutableArray alloc] init];
    }
    return self;
}

// Stitch array of UIImages:
- (void) stitchImages:(NSArray<UIImage *> *)images completion:(void (^)(UIImage *, NSError *))callback {
    
    if (callback) {

        // validate images array:
        if ([self isValidImages:images]) {
            
            _images = images;
            [_listMergeInfors removeAllObjects];
            
            // cal Infors:
            [self calculateMergeInfors];
            
            UIImage *result = [self stitch];
            
            callback(result,nil);
            
//            NSInteger numbOfImages = images.count;
//            UIImage *resultImage = images[0];
//            ZAScreenshotMerger *mergeInfor;
//
//            // Stitch from TOP to DOWN.
//            for (int i = 0; i < numbOfImages-1; i++) {
//
//                // Calculate merge information by SumPixelValue method.
//                mergeInfor = [[ZAScreenshotMerger alloc] initWithTopImage:resultImage botImage:images[i+1]];
//                [mergeInfor findBestOverlapArea];
//
//                // Calidate mergeInfor:
//                if (![self isValidMergeInfor:mergeInfor]) {
//                    self.errorCode = ZAStitchErrorCodeNotOverlap;
//                    NSError *error = [NSError errorWithDomain:IMAGE_STITCHER_DOMAIN code:self.errorCode userInfo:nil];
//                    callback(nil,error);
//                    return;
//                }
//
//                resultImage = [self generateImageWithMergeInfor:mergeInfor];
//            }
//
//            // stitch successful:
//            callback(resultImage, nil);
            
        } else {
            NSError *error = [NSError errorWithDomain:IMAGE_STITCHER_DOMAIN code:self.errorCode userInfo:nil];
            callback(nil,error);
        }
    }

}

// Stitch 2 images:
- (void) stitchTopImage:(UIImage *)topImage withBotImage:(UIImage *)botImage completion:(void (^)(UIImage *, NSError *))callback {
    NSArray *images = [NSArray arrayWithObjects:topImage,botImage, nil];
    [self stitchImages:images completion:callback];
}

// generate image with MergeInfor
- (UIImage*) generateImageWithMergeInfor:(ZAScreenshotMerger*)mergeInfor {
    
    UIImage *result;
    UIImage *topImage = mergeInfor.topImage;
    UIImage *botImage = mergeInfor.botImage;
    
    NSRange overlapTopImageRange = NSMakeRange(mergeInfor.beginOverlapTopImageRow, mergeInfor.overlapLength);
    NSRange overlapBotImageRange = NSMakeRange(mergeInfor.beginOverlapBotImageRow, mergeInfor.overlapLength);

    // prepare context:
    CGSize resultSize = CGSizeMake(mergeInfor.topImage.size.width, overlapTopImageRange.location + botImage.size.height - overlapBotImageRange.location);
    CGFloat scale = mergeInfor.topImage.scale;
    UIGraphicsBeginImageContextWithOptions(resultSize, NO, scale);
    
    // draw TopImage first:
    [topImage drawInRect:CGRectMake(0, 0, topImage.size.width, topImage.size.height)];
    
    // draw BotImage:
    UIImage *subSecondImage = [botImage subImage:CGRectMake(0, overlapBotImageRange .location, botImage.size.width, botImage.size.height - overlapBotImageRange .location)];
    [subSecondImage drawInRect:CGRectMake(0, overlapTopImageRange.location, resultSize.width, subSecondImage.size.height)];
    
    // get result:
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    mergeInfor = nil;

    
    return result;
}

// check MergeInfor is valid or not
- (BOOL) isValidMergeInfor:(ZAScreenshotMerger*)mergeInfor {
    if (mergeInfor.overlapLength <= 0 || mergeInfor.beginOverlapBotImageRow == mergeInfor.beginOverlapTopImageRow) {
        return false;
    }
    return true;
}

// check input images is valid or not
- (BOOL) isValidImages:(NSArray<UIImage*>*)images {
    BOOL isValid = false;
    if (images.count >= 2) {
        NSInteger width = images[0].size.width;
        for (UIImage *image in images) {
            if (image.size.width != width) {
                self.errorCode = ZAStitchErrorCodeNotEqualWidth;
                isValid = false;
                break;
            } else {
                isValid = true;
            }
        }
    } else {
        self.errorCode = ZAStitchErrorCodeNotEnoughImages;
    }
    return isValid;
}

- (void) calculateMergeInfors {
    
    // for each pair of images:
    for (int i = 0 ; i < _images.count - 1; i++) {
        ZAScreenshotMerger *merger = [[ZAScreenshotMerger alloc] initWithTopImage:_images[i] botImage:_images[i+1]];
        [merger findBestOverlapArea];
        [_listMergeInfors addObject:merger];
    }
    
}

- (UIImage*) stitch {
    
    UIImage *result;
    
    for (int i = 0; i < _listMergeInfors.count; i++) {
    
        if (i != 0) {
            _listMergeInfors[i].beginOverlapTopImageRow = _listMergeInfors[i-1].beginOverlapTopImageRow +  _listMergeInfors[i].beginOverlapTopImageRow - _listMergeInfors[i-1].beginOverlapBotImageRow;
            _listMergeInfors[i].topImage = result;
            result = [self generateImageWithMergeInfor:_listMergeInfors[i]];
        } else {
            result = [self generateImageWithMergeInfor:_listMergeInfors[i]];
        }
    
        if (!result) {
            return result;
        }
    }
    
    return result;
}

@end
