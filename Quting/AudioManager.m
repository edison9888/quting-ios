//
//  AudioManager.m
//  Quting
//
//  Created by Johnil on 13-5-30.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "AudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import "AlbumsView.h"
#import "AppUtil.h"

@implementation AudioManager {
    MPMoviePlayerController *player;
    NSMutableArray *playList;
    int currentIndex;
    NSTimer *ticker;
    NSString *tempURL;
    AlbumsView *albumsView;
    float needSkipToTime;
    BOOL tryMode;
    NSString *tryURL;
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
        currentIndex = -1;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        player = [[MPMoviePlayerController alloc] init];
        player.movieSourceType = MPMovieSourceTypeStreaming;
        playList = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audiofinished:) name:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey object:nil];
    }
    return self;
}

- (void)startTick{
    if (ticker) {
        [ticker invalidate];
        ticker = nil;
    }
    ticker = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:ticker forMode:NSRunLoopCommonModes];
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayNotification object:nil];
    if (albumsView) {
        [albumsView audioPlay];
    }
}

- (void)stopTick{
    if (ticker) {
        [ticker invalidate];
        ticker = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioPauseNotification object:nil userInfo:@{@"currentIndex":@(currentIndex), @"progress":@([self progress]), @"time": @(player.currentPlaybackTime), @"albumsProgress": @([self albumsProgress])}];
    }
    if (albumsView) {
        [albumsView audioPause];
    }
}

- (float)progress{
    float currentTime = player.currentPlaybackTime;
    float total = player.duration;
    return currentTime/total;
}

- (float)albumsProgress{
    float progress = [self progress];
    float albumsProgress = 100.0/playList.count/100.0;
    return albumsProgress*currentIndex+albumsProgress*progress;
}

- (void)tick{
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioProgressNotification object:[NSNumber numberWithFloat:[self progress]]];
    if (albumsView) {
        [albumsView audioProgress:[self albumsProgress]];
    }
}

- (void)durationAvailable:(NSNotification*)notification{
    NSLog(@"%f", player.duration);
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMovieDurationAvailableNotification  object:nil];
    [player setCurrentPlaybackTime:needSkipToTime];
    needSkipToTime = 0;
}

- (void)playWithURL:(NSString *)url{
    [self playWithURL:url withCurrentTime:0];
}

- (void)playWithURL:(NSString *)url withCurrentTime:(float)time{
    //#warning setMediaInfo
    //    self setMediaInfo:<#(UIImage *)#> andTitle:<#(NSString *)#> andArtist:<#(NSString *)#>
    if (time>0) {
        needSkipToTime = time;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(durationAvailable:)
                                                     name:MPMovieDurationAvailableNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioProgressNotification object:[NSNumber numberWithFloat:time]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioProgressNotification object:[NSNumber numberWithFloat:0]];
    }
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSURL *contentUrl = [NSURL URLWithString:url];
    if (albumsView) {
        NSString *root = [albumsView localRoot];
        NSString *name = [[url componentsSeparatedByString:@"/"] lastObject];
        NSString *path = [root stringByAppendingPathComponent:name];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            contentUrl = [NSURL fileURLWithPath:path];
        }
    } 
    [player setContentURL:contentUrl];//@"http://tome-file.b0.upaiyun.com/3.mp3"
    [player play];
    if (!tryMode) {
        [self startTick];
        tempURL = [url copy];
    }
}

- (BOOL)needURL{
    return !tempURL;
}

- (void)audiofinished:(NSNotification *)notification{
    if (notification==nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioProgressNotification object:[NSNumber numberWithFloat:1]];
        tempURL = nil;
        [self stopTick];
        [self next];
    }
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (reason == MPMovieFinishReasonPlaybackEnded) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioProgressNotification object:[NSNumber numberWithFloat:1]];
        tempURL = nil;
        [self stopTick];
        [self next];
    }
//    else if (reason == MPMovieFinishReasonUserExited) {
//        //user hit the done button
//    }else if (reason == MPMovieFinishReasonPlaybackError) {
//        //error
//    }
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
        [self stopTick];
        [player pause];
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
    if (ticker==nil) {
        [player play];
        [self startTick];
    }
}

- (void)pause{
    if (ticker) {
        [self stopTick];
        [player pause];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioNextNotification object:nil];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioPreNotification object:nil];
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
    tryMode = NO;
    [self stopTick];
    [player stop];
    currentIndex = -1;
    tempURL = nil;
    [playList removeAllObjects];
}

- (void)skipTo:(float)percentage{
    if (percentage >= 1) {
        [self audiofinished:nil];
        return;
    }
    float total = player.duration;
//    [[NSNotificationCenter defaultCenter] postNotificationName:AudioProgressNotification object:[NSNumber numberWithFloat:total*percentage]];
    [player setCurrentPlaybackTime:total*percentage];
}

- (float)duration{
    return player.duration;
}

- (float)currentPlaybackTime{
    return player.currentPlaybackTime;
    
}

- (BOOL)hasNext{
    return currentIndex<playList.count-1;
//    return YES;
}

- (BOOL)hasPre{
    return currentIndex>0;
//    return YES;
}

- (void)playListAtFirst{
    if (playList.count<=0) {
        [AppUtil warning:@"未找到数据" withType:m_error];
        return;
    }
    currentIndex = 0;
    [self playWithURL:[playList objectAtIndex:currentIndex]];
}

- (int)currentIndex{
    return currentIndex;
}

- (void)playIndex:(int)index{
    [self playIndex:index withTime:0];
}

- (void)playIndex:(int)index withTime:(float)time{
    [player stop];
    [self stopTick];
    currentIndex = index;
    if (time == NAN) {
        time = 0;
    }
    [self playWithURL:[playList objectAtIndex:currentIndex] withCurrentTime:time];
}

- (BOOL)playing{
    return ticker!=nil;
}

- (void)setCurrentAlbums:(AlbumsView *)albums{
    [[NSNotificationCenter defaultCenter] addObserver:albums selector:@selector(recordPlayProgress:) name:AudioPauseNotification object:nil];
    albumsView = albums;
}

- (BOOL)clearOtherAlbumsStat:(AlbumsView *)albums{
    if (albumsView==nil) {
        [self setCurrentAlbums:albums];
        [[AudioManager defaultManager] clearAudioList];
        return YES;
    }
    if (albumsView==albums) {
        return NO;
    }
    [[AudioManager defaultManager] clearAudioList];
    [albumsView stop];
    [[NSNotificationCenter defaultCenter] removeObserver:albumsView name:AudioPauseNotification object:nil];
    [self setCurrentAlbums:albums];
    return YES;
}

- (void)tryListen:(NSString *)url{
    tryMode = YES;
    if (player) {
        needSkipToTime = player.currentPlaybackTime;
    }
    [self playWithURL:url];
    ticker = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(pause) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:ticker forMode:NSRunLoopCommonModes];
}

- (void)stopTry{
    tryMode = NO;
    [self stopTick];
    if (needSkipToTime && currentIndex!=-1) {
        [self playIndex:currentIndex withTime:needSkipToTime];
    } else {
        [self clearAudioList];
    }
}

- (BOOL)hasLocal:(int)id1{
    NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    BOOL isDir;
    return ([[NSFileManager defaultManager] fileExistsAtPath:[documentdir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", id1]]isDirectory:&isDir] && isDir);
}

- (BOOL)imCurrentAlbums:(AlbumsView *)albums{
    return albums==albumsView;
}
@end
