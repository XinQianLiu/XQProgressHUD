//
//  XQBeingLoadedGifImageView.m
//  XQBeingLoadedHud
//
//  Created by 用户 on 16/7/23.
//  Copyright © 2016年 com.xinqianliu. All rights reserved.
//

#import "XQBeingLoadedGifImageView.h"

@implementation XQBeingLoadedGifImageView

- (instancetype)initWithGifNamed:(NSString *)gifNamed
{
    self = [super init];
    if (self) {
        [self loadingGifWithName:gifNamed];
    }
    return self;
}

// loading Gif
- (void)loadingGifWithName:(NSString *)name
{
    if (!name || [name isEqualToString:@""]) {
        name = @"u8";
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
    if (!path) {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Resource" ofType:@"bundle"]];
        path = [bundle pathForResource:name ofType:@"gif"];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    path = nil;
    
    if (data) {
        self.image = [self animatedGIFWithData:data];
    } else {
        self.image = [UIImage imageNamed:name];
    }
}

// GIFWithData
- (UIImage *)animatedGIFWithData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef    source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t              count = CGImageSourceGetCount(source);
    UIImage             *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    } else {
        NSMutableArray  *images = [NSMutableArray array];
        NSTimeInterval  duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            duration += [self durationAtIndex:i source:source];
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    return animatedImage;
}

// durationAtIndex
- (float)durationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source
{
    float           duration = 0.1f;
    CFDictionaryRef cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, NULL);
    NSDictionary    *properties = (__bridge NSDictionary *)cfProperties;
    NSDictionary    *gifProperties = properties[(NSString *)kCGImagePropertyGIFDictionary];
    NSNumber        *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    
    if (delayTimeUnclampedProp) {
        duration = [delayTimeUnclampedProp floatValue];
    } else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        
        if (delayTimeProp) {
            duration = [delayTimeProp floatValue];
        }
    }
    
    if (duration < 0.011f) {
        duration = 0.100f;
    }
    
    CFRelease(cfProperties);
    return duration;
}

//#ifdef DEBUG
//- (void)dealloc
//{
//    NSLog(@"\nImageView Dealloc");
//}
//#endif
@end
