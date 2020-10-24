////
////  UIImage+Rotation.m
////  ZAConversationStitcher
////
////  Created by CPU11996 on 8/13/19.
////  Copyright © 2019 vng. All rights reserved.
////
//
//#import "UIImage+Rotation.h"
//#import "UIImage+OpenCV.h"
//
//@implementation UIImage (Rotation)
//
//- (UIImage*) rotateWithAngle:(NSInteger)degree {
//    
//    cv::Mat imageMat = [self CVMat3];
//    cv::Point2f center((imageMat.cols-1)/2.0, (imageMat.rows-1)/2.0);
//    cv::Mat rot = cv::getRotationMatrix2D(center, degree, 1.0);
//    // determine bounding rectangle, center not relevant
//    cv::Rect bbox = cv::RotatedRect(cv::Point2f(), imageMat.size(), degree).boundingRect();
//    // adjust transformation matrix
//    rot.at<double>(0,2) += bbox.width/2.0 - imageMat.cols/2.0;
//    rot.at<double>(1,2) += bbox.height/2.0 - imageMat.rows/2.0;
//
//    cv::Mat dst;
//    cv::warpAffine(imageMat, dst, rot, bbox.size());
//
//    return [[UIImage alloc] initWithCVMat:dst];
//}
//
//@end
