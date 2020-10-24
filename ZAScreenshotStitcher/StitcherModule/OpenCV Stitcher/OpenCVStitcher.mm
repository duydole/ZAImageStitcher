////
////  OpenCVStitcher.m
////  ZAConversationStitcher
////
////  Created by CPU11996 on 8/13/19.
////  Copyright © 2019 vng. All rights reserved.
////
//
//#import "UIImage+OpenCV.h"
//#import "UIImage+Rotation.h"
//#import "OpenCVStitcher.h"
//#import "Stitcher.hpp"
//
//@implementation OpenCVStitcher
//
//- (void) stitchImages:(NSArray<UIImage *> *)images completion:(void (^)(UIImage *, NSError *))callback {
//    
//    if (!images || images.count < 2) {
//        _errorCode = ZAStitchErrorCodeNotEnoughImages;
//        NSError *error = [NSError errorWithDomain:IMAGE_STITCHER_DOMAIN code:_errorCode userInfo:nil];
//        callback(nil,error);
//    }
//    
//    std::vector<cv::Mat> imageMats;
//    for (UIImage *image in images) {
//        
//        // rotate
//        UIImage *rotatedImage = [image rotateWithAngle:90];
//        
//        // UIImage to Mat
//        cv::Mat imageMat = [rotatedImage CVMat3];
//        
//        // add to ImageMatrix Array.
//        imageMats.push_back(imageMat);
//    }
//    
//    // Stitching by OpenCV:
//    cv::Mat stitchedMat = stitch(imageMats);
//    
//    UIImage *result = [UIImage imageWithCVMat:stitchedMat];
//    
//    if (result) {
//        callback([result rotateWithAngle:-90],nil);
//    } else {
//        _errorCode = ZAStitchErrorCodeNotOverlap;
//        NSError *error = [NSError errorWithDomain:IMAGE_STITCHER_DOMAIN code:_errorCode userInfo:nil];
//        callback(nil,error);
//    }
//}
//
//- (void) stitchTopImage:(UIImage *)topImage withBotImage:(UIImage *)botImage completion:(void (^)(UIImage *, NSError *))callback {
//    NSArray *images = [NSArray arrayWithObjects:topImage, botImage, nil];
//    [self stitchImages:images completion:callback];
//}
//
//@end
