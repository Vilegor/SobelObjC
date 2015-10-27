//
//  SobelCPCalculation.h
//  AR_Demo
//
//  Created by Egor Vilkin on 10/16/15.
//  Copyright (c) 2015 EVil corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface SobelCPU : NSObject

+ (SobelCPU *)imageProcessor;
- (CGImageRef)processImage:(CGImageRef)sourceImage;

@end
