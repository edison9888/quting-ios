//
//  AudioManager.h
//  Quting
//
//  Created by Johnil on 13-5-30.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol AudioManagerDelegate <NSObject>

@optional
- (void)audioProgress:(float)progress;
- (void)audioPlay;
- (void)audioPause;
- (void)audioNext;
- (void)audioPre;

@end

@interface AudioManager : NSObject

+ (AudioManager *)defaultManager;
- (void)addListener:(id<AudioManagerDelegate>)delegate;
- (void)removeListener:(id<AudioManagerDelegate>)delegate;
- (void)playWithURL:(NSString *)url;
- (BOOL)needURL;
- (BOOL)changeStat;
- (MPMoviePlaybackState)stat;
- (void)resume;
- (void)pause;
- (void)next;
- (void)pre;
- (void)addAudioToList:(NSString *)name;
- (void)addAudioListToList:(NSArray *)arr;
- (void)insertAudioToList:(NSString *)name;
- (void)insertAudioListToList:(NSArray *)arr;
- (void)clearAudioList;
- (void)skipTo:(float)percentage;
- (float)duration;
- (float)currentPlaybackTime;
- (BOOL)hasNext;
- (BOOL)hasPre;
- (void)playListAtFirst;

@end
