//
//  AudioManager.h
//  Quting
//
//  Created by Johnil on 13-5-30.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
@class AlbumsView;
#define AudioPlayNotification @"audioPaly"
#define AudioPauseNotification @"audioPause"
#define AudioNextNotification @"audioNext"
#define AudioPreNotification @"audioPre"
#define AudioProgressNotification @"audioProgress"


@interface AudioManager : NSObject

+ (AudioManager *)defaultManager;
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
- (int)currentIndex;
- (void)playIndex:(int)index;
- (BOOL)playing;
- (void)setCurrentAlbums:(AlbumsView *)albums;
- (BOOL)clearOtherAlbumsStat:(AlbumsView *)albums;
- (float)progress;

@end
