//
//  ViewController.m
//  AR_Demo
//
//  Created by Egor Vilkin on 10/16/15.
//  Copyright (c) 2015 EVil corp. All rights reserved.
//

#import "ViewController.h"
#import "SobelCPU.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // prepare views
    //self.imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // 1. Sobel
    UIImage *img = [UIImage imageNamed:@"test0.png"];
    SobelCPU *imgProc = [SobelCPU imageProcessor];
    CGImageRef filteredImg = [imgProc processImage:img.CGImage];
    UIImage *newImg = [UIImage imageWithCGImage:filteredImg];
    self.imageView.image = newImg;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
