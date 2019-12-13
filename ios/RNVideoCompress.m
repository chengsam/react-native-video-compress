
#import "RNVideoCompress.h"
#import <AVFoundation/AVFoundation.h>
#import "SDAVAssetExportSession.h"

@implementation RNVideoCompress
{
    bool hasListeners;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"progress"];
}

// Will be called when this module's first listener is added.
-(void)startObserving {
    hasListeners = YES;
    // Set up any upstream listeners or background tasks as necessary
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
    hasListeners = NO;
    // Remove upstream listeners, stop unnecessary background tasks
}

- (void)updateProgress: (float) progress
{
    if (hasListeners) { // Only send events if anyone is listening
        [self sendEventWithName:@"progress" body:@(progress)];
    }
}

RCT_EXPORT_METHOD(compress:(NSString *)source options:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    
    NSDate *methodStart = [NSDate date];
    
    NSURL *url = [[NSURL alloc] initWithString:source];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    CMTime assetTime = [asset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    
    NSNumber *width = @([options[@"width"] floatValue]);
    NSNumber *height = @([options[@"height"] floatValue]);
    NSNumber *bitrate = @([options[@"bitrate"] floatValue]);
    
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    CGSize naturalSize = [videoTrack naturalSize];

    CGFloat originalBitrate = [videoTrack estimatedDataRate];
    
    CGFloat maxWidth = MAX([width floatValue], [height floatValue]);
    CGFloat maxHeight = MAX([width floatValue], [height floatValue]);
    CGFloat outputBitrate = [bitrate floatValue];
    
    CGFloat originalWidth = naturalSize.width;
    CGFloat originalHeight = naturalSize.height;
    
    CGSize transformedVideoSize =
    CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
    bool videoIsPortrait = transformedVideoSize.width < transformedVideoSize.height;

    if (videoIsPortrait && (originalWidth > originalHeight)) {
        originalWidth = naturalSize.height;
        originalHeight = naturalSize.width;
    }
    
    CGFloat widthRatio = maxWidth / originalWidth;
    CGFloat heightRatio = maxHeight / originalHeight;
    CGFloat bestRatio = MIN(widthRatio, heightRatio);
    CGFloat finalRatio = bestRatio < 1 ? bestRatio : 1;
    // output
    CGFloat outputWidth = originalWidth * finalRatio;
    CGFloat outputHeight = originalHeight * finalRatio;

    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:asset];
    
    CMTime startTime = CMTimeMake(0, 1);
    CMTime stopTime = CMTimeMake(duration, 1);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    encoder.timeRange = exportTimeRange;
    
    encoder.videoSettings = @{
      AVVideoCodecKey: AVVideoCodecH264,
      AVVideoWidthKey: @(outputWidth),
      AVVideoHeightKey: @(outputHeight),
      AVVideoCompressionPropertiesKey: @{
              AVVideoAverageBitRateKey: @(outputBitrate > originalBitrate ? originalBitrate : outputBitrate),
          AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel,
        },
    };
    
    encoder.audioSettings = @{
      AVFormatIDKey: @(kAudioFormatMPEG4AAC),
      AVNumberOfChannelsKey: @1,
      AVSampleRateKey: @44100,
      AVEncoderBitRateKey: @128000,
    };
    
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = [NSURL fileURLWithPath:
                         [NSTemporaryDirectory() stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"compressed_%@.mov", [[NSProcessInfo processInfo] globallyUniqueString]
                          ]]];
    encoder.shouldOptimizeForNetworkUse = true;
    
    __block NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self updateProgress:encoder.progress];
    }];
    
    [encoder exportAsynchronouslyWithCompletionHandler:^
     {
         [timer invalidate];
         timer = nil;
         
         if (encoder.status == AVAssetExportSessionStatusCompleted)
         {
             NSDate *methodFinish = [NSDate date];
             NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
             NSLog(@"executionTime = %f", executionTime);
             
             NSLog(@"Video export succeeded");
             resolve(encoder.outputURL.absoluteString);
         } else {
             NSLog(@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, encoder.error.code);
             reject(@"video_export_error", [NSString stringWithFormat:@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, encoder.error.code], nil);
         }
     }];
    
}

@end
