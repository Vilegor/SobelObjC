//
//  SobelCPCalculation.m
//  AR_Demo
//
//  Created by Egor Vilkin on 10/16/15.
//  Copyright (c) 2015 EVil corp. All rights reserved.
//

#import "SobelCPU.h"
#import <UIKit/UIKit.h>

const uint kRGBA = 4;
typedef struct {
    Byte r;
    Byte g;
    Byte b;
    Byte a;
} RGBAColor;

@interface SobelCPU() {
    int **GX;
    int **GY;
    
    unsigned long curWidth;
    unsigned long curHeight;
}

@end

/*
      |-1 0 1|        |-1 -2 -1|
 Gx = |-2 0 2|   Gy = | 0  0  0|
      |-1 0 1|        | 1  2  1|
 */

@implementation SobelCPU

+ (SobelCPU *)imageProcessor
{
    return [SobelCPU new];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        GX = calloc(3, sizeof(int *));
        for (int i = 0; i < 3; i++) {
            GX[i] = calloc(3, sizeof(int));
        }
        GX[0][0] = -1;
        GX[1][0] = -2;
        GX[2][0] = -1;
        
        GX[0][2] = 1;
        GX[1][2] = 2;
        GX[2][2] = 1;
        
        GY = calloc(3, sizeof(int *));
        for (int i = 0; i < 3; i++) {
            GY[i] = calloc(3, sizeof(int));
        }
        GY[0][0] = -1;
        GY[0][1] = -2;
        GY[0][2] = -1;
        
        GY[2][0] = 1;
        GY[2][1] = 2;
        GY[2][2] = 1;
    }
    return self;
}

- (CGImageRef)processImage:(CGImageRef)source
{
    curWidth = CGImageGetWidth(source);
    curHeight  = CGImageGetHeight(source);
    
    Byte *data = [self getImageData:source];
    Byte *newData = malloc(curWidth * curHeight * kRGBA);
    
    for (int y = 0; y < curHeight; y++)
    {
        for (int x = 0; x < curWidth; x++)
        {
            int gx = [self xGradient:data atX:x Y:y];
            int gy = [self yGradient:data atX:x Y:y];
            int g = sqrt(gx*gx + gy*gy);
            
            if (g > 255) {
                g = 255;
            }
            [self setPixelColorTo:g forImage:newData atX:x Y:y];
        }
    }
    CGImageRef output = [self setImageData:newData fromImage:source];
    
    free(data);
    curWidth = curHeight = 0;
    
    return output;
}

- (int)xGradient:(Byte *)imgData atX:(int)x Y:(int)y
{
    int sum = 0;
    for (int dx = -1; dx <= 1; dx++)
    {
        for (int dy = -1; dy <= 1; dy++)
        {
            sum += ((int)[self pixelLumaFromData:imgData atX:x+dx Y:y+dy]) * GX[dx+1][dy+1];
        }
    }
    
    return sum;
}

- (int)yGradient:(Byte *)imgData atX:(int)x Y:(int)y
{
    int sum = 0;
    for (int dx = -1; dx <= 1; dx++)
    {
        for (int dy = -1; dy <= 1; dy++)
        {
            sum += ((int)[self pixelLumaFromData:imgData atX:x+dx Y:y+dy]) * GY[dx+1][dy+1];
        }
    }
    
    return sum;
}

- (Byte)pixelLumaFromData:(Byte *)imgData atX:(int)x Y:(int)y
{
    Byte L = 0;
    if (x >= 0 && x < curWidth && y >= 0 && y < curHeight)
    {
        long bi = (y * curWidth + x) * kRGBA;
        L = imgData[bi];
    }
    else
    {
        L = 127;
    }
    
    return L;
}

- (void)setPixelColorTo:(Byte)color forImage:(Byte *)imgData atX:(int)x Y:(int)y
{
    if (x >= 0 && x < curWidth && y >= 0 && y < curHeight)
    {
        long bi = (y * curWidth + x) * kRGBA;
        imgData[bi] = color;
        imgData[bi+1] = color;
        imgData[bi+2] = color;
        imgData[bi+3] = 255;
    }
}

- (Byte *)getImageData:(CGImageRef)image
{
    unsigned long width = CGImageGetWidth(image);
    unsigned long height  = CGImageGetHeight(image);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    Byte *rawData = malloc(height * width * kRGBA);
    NSUInteger bytesPerPixel = kRGBA;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, rect, image);
    CGContextRelease(context);
    
    Byte *imageData = malloc(height * width * kRGBA);
    int byteIndex = 0;
    for (int i = 0; i < width * height; ++i)
    {
        Byte R = rawData[byteIndex];
        Byte G = rawData[byteIndex+1];
        Byte B = rawData[byteIndex+2];
        
        int color = (R + G + B) / 3;
        imageData[byteIndex] = (Byte)color;
        imageData[byteIndex+1] = (Byte)color;
        imageData[byteIndex+2] = (Byte)color;
        imageData[byteIndex+3] = 255;
        
        byteIndex += kRGBA;
    }
    free(rawData);
    
    return imageData;
}

- (CGImageRef)setImageData:(Byte *)data fromImage:(CGImageRef)image
{
    CGContextRef context = CGBitmapContextCreate(data, CGImageGetWidth(image), CGImageGetHeight(image), 8, CGImageGetBytesPerRow(image), CGImageGetColorSpace(image), 1);
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return newImage;
}

@end
