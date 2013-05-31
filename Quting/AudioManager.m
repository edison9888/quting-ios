//
//  AudioManager.m
//  Quting
//
//  Created by Johnil on 13-5-30.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "AudioManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation AudioManager {
    MPMoviePlayerController *player;
    NSMutableArray *playList;
    int currentIndex;
    NSMutableArray *listener;
    NSTimer *ticker;
    NSString *tempURL;
}

+ (AudioManager *)defaultManager{
    static dispatch_once_t  onceToken;
    static AudioManager * sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[AudioManager alloc] init];
    });
    return sSharedInstance;
}

- (id)init{
    self = [super init];
    if (self) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        player = [[MPMoviePlayerController alloc] init];
        player.movieSourceType = MPMovieSourceTypeStreaming;
        playList = [[NSMutableArray alloc] init];
        listener = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(audiofinished) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    return self;
}

- (void)startTick{
    [self stopTick];
    ticker = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:ticker forMode:NSRunLoopCommonModes];
    for (id delegate in listener) {
        if (delegate && [delegate respondsToSelector:@selector(audioPlay)]) {
            [delegate audioPlay];
        }
    }
}

- (void)stopTick{
    if (ticker) {
        [ticker invalidate];
        ticker = nil;
        for (id delegate in listener) {
            if (delegate && [delegate respondsToSelector:@selector(audioPause)]) {
                [delegate audioPause];
            }
        }
    }
}

- (void)tick{
    for (id delegate in listener) {
        if (delegate && [delegate respondsToSelector:@selector(audioProgress:)]) {
            float currentTime = player.currentPlaybackTime;
            float total = player.duration;
            [delegate audioProgress:currentTime/total];
        }
    }
}

- (void)addListener:(id<AudioManagerDelegate>)delegate{
    [listener addObject:delegate];
}

- (void)removeListener:(id<AudioManagerDelegate>)delegate{
    [listener removeObject:delegate];
}

- (void)playWithURL:(NSString *)url{
    for (id delegate in listener) {
        if (delegate && [delegate respondsToSelector:@selector(audioProgress:)]) {
            [delegate audioProgress:0];
        }
    }
#warning setMediaInfo
//    self setMediaInfo:<#(UIImage *)#> andTitle:<#(NSString *)#> andArtist:<#(NSString *)#>
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [player setContentURL:[NSURL URLWithString:url]];
    [player play];
    [self startTick];
    tempURL = [url copy];
}

- (BOOL)needURL{
    return !tempURL;
}

- (void)audiofinished{
    for (id delegate in listener) {
        if (delegate && [delegate respondsToSelector:@selector(audioProgress:)]) {
            [delegate audioProgress:1];
        }
    }
    tempURL = nil;
    [self stopTick];
    [self next];
}

- (void)setMediaInfo:(UIImage *)img andTitle:(NSString *)title andArtist:(NSString *)artist{
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:title forKey:MPMediaItemPropertyAlbumTitle];
        [dict setObject:artist forKey:MPMediaItemPropertyArtist];
        [dict setObject:[NSNumber numberWithFloat:player.currentPlaybackTime] forKey:MPMediaItemPropertyPlaybackDuration];
        
        MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:img];
        [dict setObject:mArt forKey:MPMediaItemPropertyArtwork];
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}

- (BOOL)changeStat{
    if (player.playbackState == MPMoviePlaybackStatePlaying) {
        [player pause];
        [self stopTick];
        return NO;
    } else {
        [player play];
        [self startTick];
        return YES;
    }
}

- (MPMoviePlaybackState)stat{
    return player.playbackState;
}

- (void)resume{
    if (player.playbackState == MPMoviePlaybackStatePaused) {
        [player play];
        [self startTick];
    }
}

- (void)pause{
    if (player.playbackState == MPMoviePlaybackStatePlaying) {
        [player pause];
        [self stopTick];
    }
}

- (void)next{
    if (playList.count<=0) {
        return;
    }
    ++currentIndex;
    if (currentIndex>playList.count-1) {
        currentIndex = 0;
    }
    NSLog(@"next play index:%d", currentIndex);
    NSString *url = [playList objectAtIndex:currentIndex];
    [self playWithURL:url];
    
    for (id delegate in listener) {
        if (delegate && [delegate respondsToSelector:@selector(audioNext)]) {
            [delegate audioNext];
        }
    }
}

- (void)pre{
    if (playList.count<=0) {
        return;
    }
    --currentIndex;
    if (currentIndex<0) {
        currentIndex = playList.count-1;
    }
    NSLog(@"pre play index:%d", currentIndex);
    [self playWithURL:[playList objectAtIndex:currentIndex]];
    
    for (id delegate in listener) {
        if (delegate && [delegate respondsToSelector:@selector(audioPre)]) {
            [delegate audioPre];
        }
    }
}

- (void)addAudioToList:(NSString *)name{
    [playList addObject:name];
}

- (void)addAudioListToList:(NSArray *)arr{
    [playList addObjectsFromArray:arr];
}

- (void)insertAudioToList:(NSString *)name{
    [playList insertObject:name atIndex:0];
}

- (void)insertAudioListToList:(NSArray *)arr{
    for (int i=arr.count-1; i>=0; i--) {
        NSString *name = [arr objectAtIndex:i];
        [playList insertObject:name atIndex:0];
    }
}

- (void)clearAudioList{
    [playList removeAllObjects];
}

- (void)skipTo:(float)percentage{
    if (percentage >= 1) {
        [self audiofinished];
        return;
    }
    float total = player.duration;
    [player setCurrentPlaybackTime:total*percentage];
}

- (float)duration{
    return player.duration;
}

- (float)currentPlaybackTime{
    return player.currentPlaybackTime;
    
}

- (BOOL)hasNext{
//    return currentIndex<playList.count;
    return YES;
}

- (BOOL)hasPre{
//    return currentIndex>0;
    return YES;
}

- (void)playListAtFirst{
    [self playWithURL:[playList objectAtIndex:currentIndex]];
}

@end
