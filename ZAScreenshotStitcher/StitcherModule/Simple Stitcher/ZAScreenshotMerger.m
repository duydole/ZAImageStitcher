//
//  ZAScreenshotMerger.m
//  ZAScreenshotStitcher
//
//  Created by CPU11996 on 8/20/19.
//  Copyright © 2019 vng. All rights reserved.
//

#import "ZAScreenshotMerger.h"
#import "UIImage+Converter.h"

// Constraint:
#define MIN_OVERLAP_HEIGHT 50
#define MIN_DISTANCE_BETWEEN_OVERLAP_AREAS 100
#define MIN_LOWER_BOUND 0.99

@interface ZAScreenshotMerger()

@property (nonatomic) float upperBound;
@property (nonatomic) float lowerBound;
@property (nonatomic) BOOL isValidOverlapInfors;
@property (nonatomic) BOOL isSameImage;

@end

@implementation ZAScreenshotMerger

- (instancetype) initWithTopImage:(UIImage *)topImage botImage:(UIImage *)botImage {
    
    self = [super init];
    
    if (self) {
        _topImage = topImage;
        _botImage = botImage;
        
        // init bound:
        _lowerBound = 1.0;
        _upperBound = 1.0;
        
        // init array:
        _ZAOverlapAreas = [[NSMutableArray alloc] init];
        
        _isSameImage = false;
        _isValidOverlapInfors = false;
    }
    
    return self;
}

// Find best overlap area and store values:
- (void)findBestOverlapArea {
    
    // find all overlaps:
    [self findAllOverlapAreas];
    
    // select Best Overlap Area:
    [self selectBestOverlapArea];
    
    // swap if images aren't ordered:
    [self checkOrderedOfImages];
}

// Find all overlap areas:
- (void)findAllOverlapAreas {
    
    while (!_isValidOverlapInfors && _lowerBound >= MIN_LOWER_BOUND && !_isSameImage) {
        NSLog(@"dld: Stitching with lowerBound: %f, upperBound: %f", _lowerBound, _upperBound);
        
        // find overlaps:
        [self calcultateOverlap];
        
        // reduce bounds:
        _lowerBound-=0.01;
        _upperBound+=0.01;
        
        // verify detected Overlap Areas:
        [self verifyDetectedOverlapAreas];
    }
    
}

- (void)calcultateOverlap {
    
    if (_topImage && _botImage) {
        
        // 1. Prepare data:
        NSArray *topLines = [_topImage toArrayBySumPixelValue];
        NSArray *botLines = [_botImage toArrayBySumPixelValue];
        
        int topImgHeight = (int)[topLines count];
        int botImgHeight = (int)[botLines count];
        
        // Init matrix (2 x botImgHeight):
        int **matrix = (int **)malloc(sizeof(int *) * 2);
        for (int i = 0; i < 2; i++) {
            matrix[i] = (int *)malloc(sizeof(int) * (size_t)botImgHeight);
        }
        for (NSInteger j = 0; j < botImgHeight; j++) {
            matrix[0][j] = matrix[1][j] = 0;
        }
        
        // 2. Find Overlap Areas using Dynamic Programming.
        // For each row of top image:
        for (int i = 0; i < topImgHeight; i ++) {
            
            int64_t topLineValue = [topLines[i] longLongValue];
            
            // for each row of BOT IMAGE:
            for (int  j = 0; j < botImgHeight; j++) {
                
                int64_t botLineValue = [botLines[j] longLongValue];
                
                // if row i (TopImage) ~ row j (BotImage)
                if ([self isX:topLineValue approximateTo:botLineValue]) {
                    
                    // Calculate new OverlapLength -> Update
                    int currentOverlapHeight = 0;
                    if (j != 0) {
                        int preOverlapHeight = matrix[(i + 1) % 2][j-1];
                        currentOverlapHeight = preOverlapHeight + 1;
                    }
                    
                    // Update OverlapLength at Row i, Col j.
                    matrix[i % 2][j] = currentOverlapHeight;
                    
                    // if DetectedOverlap > MIN_OVERLAP_HEIGHT, then Update array OverlapAreas.
                    if (currentOverlapHeight > MIN_OVERLAP_HEIGHT) {
                        
                        ZAOverlapArea *infor = [[ZAOverlapArea alloc] init];
                        infor.overlapHeight = currentOverlapHeight;
                        infor.beginOverlapTopImage = i - currentOverlapHeight + 1;
                        infor.beginOverlapBotImage = j - currentOverlapHeight + 1;
                        
                        [self addToListInfor:infor];
                    }
                    
                } else {
                    matrix[i % 2][j] = 0;
                }
            }
        }
        
        // 3. Deallocate:
        for (int i = 0; i < 2; i++)
            free(matrix[i]);
        free(matrix);
    }
    
}

// update array of ZAOverlapAreas:
- (void)addToListInfor:(ZAOverlapArea*)inputInfor {
    
    BOOL isExisted = false;
    
    // for each existed Infors:
    for (ZAOverlapArea *infor in self.ZAOverlapAreas) {
        
        if (([self isIndex:inputInfor.beginOverlapBotImage approximateIndex:infor.beginOverlapBotImage] ||
             [self isIndex:inputInfor.beginOverlapTopImage approximateIndex:infor.beginOverlapTopImage]) &&
            [self isIndex:inputInfor.overlapHeight approximateIndex:infor.overlapHeight] ) {
            
            isExisted = true;
            
            if (inputInfor.overlapHeight > infor.overlapHeight) {
                infor.overlapHeight = inputInfor.overlapHeight;
                
                if (inputInfor.beginOverlapTopImage < infor.beginOverlapTopImage) {
                    infor.beginOverlapTopImage = inputInfor.beginOverlapTopImage;
                }
                
                if (inputInfor.beginOverlapBotImage > infor.beginOverlapBotImage) {
                    infor.beginOverlapBotImage = inputInfor.beginOverlapBotImage;
                }
                break;
            }
            
        }
    }
    
    if (!isExisted) {
        [_ZAOverlapAreas addObject:inputInfor];
    }
    
}

- (void)selectBestOverlapArea {
    
    // for each OverlapArea:
    for (ZAOverlapArea *infor in _ZAOverlapAreas) {
        
        // case 1: in the mid has the big overlap:
        if (infor.overlapHeight > [self sufficientOverlapHeight]) {
            
            _overlapLength = infor.overlapHeight;
            _beginOverlapTopImageRow = infor.beginOverlapTopImage;
            _beginOverlapBotImageRow = infor.beginOverlapBotImage;
            break;
            
            // case 2: select the max distance overlap infor:
        } else if (infor.distance > [self currentDistance]){
            
            _overlapLength = infor.overlapHeight;
            _beginOverlapTopImageRow = infor.beginOverlapTopImage;
            _beginOverlapBotImageRow = infor.beginOverlapBotImage;
        }
    }
}

- (void)checkOrderedOfImages {
    
    if (_beginOverlapTopImageRow < _beginOverlapBotImageRow) {
        NSInteger tempIndex = _beginOverlapTopImageRow;
        UIImage *tempImg = _topImage;
        
        _beginOverlapTopImageRow = _beginOverlapBotImageRow;
        _beginOverlapBotImageRow = tempIndex;
        _topImage = _botImage;
        _botImage = tempImg;
    }
}

// approximate 2 rows value:
- (BOOL)isX:(int64_t)x approximateTo:(int64_t)y {
    return y >= x*_lowerBound && y <= x*_upperBound;
}

- (BOOL)isIndex:(NSInteger)x approximateIndex:(NSInteger)y {
    return x >= y-8 && x <= y +8;
}

- (void)verifyDetectedOverlapAreas {
    
    NSMutableArray *validOverlapAreas = [[NSMutableArray alloc] init];
    
    for (ZAOverlapArea *infor in _ZAOverlapAreas) {
        
        // if is the same image:
        if (infor.distance == 0 && infor.overlapHeight > 0.99*_topImage.size.height) {
            _isSameImage = YES;
            [validOverlapAreas addObject:infor];
            break;
        }
        
        if (infor.distance > 100) {
            _isValidOverlapInfors = YES;
            [validOverlapAreas addObject:infor];
        }
        
    }
    
    _ZAOverlapAreas = validOverlapAreas;
}

- (NSInteger)currentDistance {
    return _beginOverlapTopImageRow - _beginOverlapBotImageRow;
}

- (NSInteger)sufficientOverlapHeight {
    return 0.3*_topImage.size.height;   // 30% height of TopImage
}

@end
