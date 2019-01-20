//
//  GifAssembler.swift
//  Maverick
//
//  Created by Garrett Fritz on 10/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import AVFoundation

class GifAssembler {
    
    func mixVideoAsset (videoAsset : AVAsset) {
        
        
        let begin = Date()
        
        // 2 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        // 3 - Video track
        guard let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
        do {
            
            if let track = videoAsset.tracks(withMediaType: AVMediaType.video).first {
                
                try videoTrack.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: videoAsset.duration), of: track, at: kCMTimeZero)
                
            }
            
            
            
            // - Audio
            let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            
            if let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first, let duration = audioCompositionTrack?.timeRange.duration {
                
                try audioCompositionTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: duration), of: audioTrack, at: kCMTimeZero)
                
            }
            
            
            //    // 3.1 - Create AVMutableVideoCompositionInstruction
            
            let mainInstruction = AVMutableVideoCompositionInstruction()
            
            mainInstruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: videoAsset.duration)
            
            //    // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
            let videolayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            let videoAssetTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first
            
            
            let videoAssetOrientation_  = UIImageOrientation.up
            let isVideoAssetPortrait_ = false
            
            let videoTransform = videoAssetTrack?.preferredTransform
            
//            if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
//                videoAssetOrientation_ = UIImageOrientation.right
//                isVideoAssetPortrait_ = true
//            }
//            if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
//                videoAssetOrientation_ =  UIImageOrientation.left
//                isVideoAssetPortrait_ = true
//            }
//            if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
//                videoAssetOrientation_ =  UIImageOrientation.up
//            }
//            if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
//                videoAssetOrientation_ = UIImageOrientation.down
//            }
            
            //    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
            //    [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
            //
            //    // 3.3 - Add instructions
            //    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
            //
            //    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
            //
            //    CGSize naturalSize;
            //    if(isVideoAssetPortrait_){
            //        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
            //    } else {
            //        naturalSize = videoAssetTrack.naturalSize;
            //    }
            //
            //    float renderWidth, renderHeight;
            //    renderWidth = naturalSize.width;
            //    renderHeight = naturalSize.height;
            //    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
            //    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
            //    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
            //
            //    // Watermark Layers
            //    [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize];
            //
            //    // 4 - Get path
            //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            //    NSString *documentsDirectory = [paths objectAtIndex:0];
            //    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
            //    [NSString stringWithFormat:@"FinalVideo-%d.mov",arc4random() % 1000]];
            //    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
            //    //    NSURL * url = TempVideoURL();
            //
            //    // 5 - Create exporter
            //    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
            //    presetName:AVAssetExportPresetHighestQuality];
            //    exporter.outputURL=url;
            //    exporter.outputFileType = AVFileTypeMPEG4;
            //    exporter.shouldOptimizeForNetworkUse = YES;
            //    exporter.videoComposition = mainCompositionInst;
            //    [exporter exportAsynchronouslyWithCompletionHandler:^{
            //    dispatch_async(dispatch_get_main_queue(), ^{
            //    NSDate * endDate = [NSDate date];
            //    NSTimeInterval interval = [endDate timeIntervalSinceDate:begin];
            //    NSLog(@"completed %f senconds",interval);
            //
            //    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            //    if ([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:exporter.outputURL]) {
            //    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:exporter.outputURL completionBlock:NULL];
            //    }
            //    });
            //    }];
            
        } catch {
            
            
        }
        
    }
    
    
    //    - (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
    //{
    //
    //    // - set up the parent layer
    //    CALayer *parentLayer = [CALayer layer];
    //    CALayer *videoLayer = [CALayer layer];
    //    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    //    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    //    [parentLayer addSublayer:videoLayer];
    //
    //    size.width = 100;
    //    size.height = 100;
    //
    //    // - set up the overlay
    //    CALayer *overlayLayer = [CALayer layer];
    //    overlayLayer.frame = CGRectMake(0, 100, size.width, size.height);
    //
    //    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"jiafei" withExtension:@"gif"];
    //    [self startGifAnimationWithURL:fileUrl inLayer:overlayLayer];
    //
    //    //    UIImage * image = [UIImage imageNamed:@"gifImage.gif"];
    //    //    [overlayLayer setContents:(id)[image CGImage]];
    //    //    [overlayLayer setMasksToBounds:YES];
    //
    //    [parentLayer addSublayer:overlayLayer];
    //
    //    // - apply magic
    //    composition.animationTool = [AVVideoCompositionCoreAnimationTool
    //        videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    //
    //    }
    //
    //    - (void)startGifAnimationWithURL:(NSURL *)url inLayer:(CALayer *)layer {
    //        CAKeyframeAnimation * animation = [self animationForGifWithURL:url];
    //        [layer addAnimation:animation forKey:@"contents"];
    //        }
    //
    //        - (CAKeyframeAnimation *)animationForGifWithURL:(NSURL *)url {
    //
    //            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    //
    //            NSMutableArray * frames = [NSMutableArray new];
    //            NSMutableArray *delayTimes = [NSMutableArray new];
    //
    //            CGFloat totalTime = 0.0;
    //            CGFloat gifWidth;
    //            CGFloat gifHeight;
    //
    //            CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    //
    //            // get frame count
    //            size_t frameCount = CGImageSourceGetCount(gifSource);
    //            for (size_t i = 0; i < frameCount; ++i) {
    //                // get each frame
    //                CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
    //                [frames addObject:(__bridge id)frame];
    //                CGImageRelease(frame);
    //
    //                // get gif info with each frame
    //                NSDictionary *dict = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL));
    //                NSLog(@"kCGImagePropertyGIFDictionary %@", [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary]);
    //
    //                // get gif size
    //                gifWidth = [[dict valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
    //                gifHeight = [[dict valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
    //
    //                // kCGImagePropertyGIFDictionary中kCGImagePropertyGIFDelayTime，kCGImagePropertyGIFUnclampedDelayTime值是一样的
    //                NSDictionary *gifDict = [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
    //                [delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
    //
    //                totalTime = totalTime + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
    //
    //                CFRelease((__bridge CFTypeRef)(dict));
    //            }
    //
    //            if (gifSource) {
    //                CFRelease(gifSource);
    //            }
    //
    //            NSMutableArray *times = [NSMutableArray arrayWithCapacity:3];
    //            CGFloat currentTime = 0;
    //            NSInteger count = delayTimes.count;
    //            for (int i = 0; i < count; ++i) {
    //                [times addObject:[NSNumber numberWithFloat:(currentTime / totalTime)]];
    //                currentTime += [[delayTimes objectAtIndex:i] floatValue];
    //            }
    //
    //            NSMutableArray *images = [NSMutableArray arrayWithCapacity:3];
    //            for (int i = 0; i < count; ++i) {
    //                [images addObject:[frames objectAtIndex:i]];
    //            }
    //
    //            animation.keyTimes = times;
    //            animation.values = images;
    //            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    //            animation.duration = totalTime;
    //            animation.repeatCount = HUGE_VALF;
    //
    //            animation.beginTime = AVCoreAnimationBeginTimeAtZero;
    //            animation.removedOnCompletion = NO;
    //
    //            return animation;
    //}
    //
}
