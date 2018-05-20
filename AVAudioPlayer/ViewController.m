//
//  ViewController.m
//  AVAudioPlayer
//
//  Created by Trúc Phương >_< on 03/03/2018.
//  Copyright © 2018 iDev Bao. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@import AVFoundation;

@interface ViewController ()<AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UISlider *slider_showtimeCrrent;
@property (weak, nonatomic) IBOutlet UILabel *timeBaihat;
@property (weak, nonatomic) IBOutlet UILabel *timeConlai;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;

@property (strong,nonatomic)AVAudioPlayer * audioPlayer;
@property(strong ,nonatomic)AVPlayer *player;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController{
    BOOL isPlause;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    isPlause = true;
    //    [self caidatAvplayer:@"Noi" andwithfile:@".mp3"];
    [self enablebtnPlaystop:NO];


    
}
#pragma mark bat su kien play va stop
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setupAVAudioPlayerWriteToDataWithURL:@"http://data.chiasenhac.com/downloads/1871/6/1870418-96d3568d/m4a/Hom%20Nay%20Toi%20Buon%20-%20Phung%20Khanh%20Linh%20[500kbps_M4A].m4a"];
    // kiem tra trang thay ss play
    
    [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    /// bat stop
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(batsukiemhetnhac:)
                                                  name:AVPlayerItemDidPlayToEndTimeNotification
                                                object:_player.currentItem];
}
#pragma mark play
- (IBAction)play:(id)sender {
    [self.timer invalidate];
        _timer = nil;
    if (isPlause) {
        //        [_audioPlayer play];
        isPlause = false;
        [_btnPlay setTitle:@"plause" forState:UIControlStateNormal];
        //        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        
        
        // stream
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getCurrentime) userInfo:nil repeats:YES];
        [_player play];
    }else{
        //        [_audioPlayer pause];
        [_btnPlay setTitle:@"play" forState:UIControlStateNormal];
        isPlause = true;
        
        
        [_player pause];
    }
}

- (IBAction)stop:(id)sender {
    //    [_audioPlayer stop];
    //    [_audioPlayer setCurrentTime:0.0];
    _slider_showtimeCrrent.value = 0.0;
    isPlause =true;
    _timeBaihat.text = @"0:00";
    //    _timeConlai.text = [NSString stringWithFormat:@"%@", [self timeFormat:self.audioPlayer.duration]];
    [_btnPlay setTitle:@"play" forState:UIControlStateNormal];
    // stream
    [_player pause];
    [_player seekToTime:kCMTimeZero]; // ve 0
    
    _timeConlai.text =   [NSString stringWithFormat:@"%@",[self timeFormat:CMTimeGetSeconds(self.player.currentItem.duration)]];
    
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer= nil;
    }
}
#pragma mark valueslider
- (IBAction)slider:(UISlider *)sender {
    //    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateTime) userInfo:nil repeats:NO];
    //    [_audioPlayer setCurrentTime:_slider_showtimeCrrent.value];
    
    // stream
    [_timer invalidate];
    _timer = nil;
    //    [_player pause];
    isPlause =true;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(getCurrentime) userInfo:nil repeats:YES];
    [_btnPlay setTitle:@"play" forState:UIControlStateNormal];
    float timeinSecond= _slider_showtimeCrrent.value;
    [_player play];
    
    CMTime cmtime = CMTimeMake(timeinSecond, 1);
    [_player seekToTime:cmtime];
    
}

#pragma mark caidat avplayer
-(void)caidatAvplayer:(NSString*)nameSong andwithfile:(NSString*)extensionFile{
    NSURL * linkfile = [[NSBundle mainBundle] URLForResource:nameSong withExtension:extensionFile];
    NSError * err;
    _audioPlayer =[[AVAudioPlayer alloc]initWithContentsOfURL:linkfile error:&err];
    NSLog(@"loi %@", err);
    [_audioPlayer prepareToPlay];
    _slider_showtimeCrrent.maximumValue = [_audioPlayer duration];
    _timeBaihat.text = @"0:00";
    _timeConlai.text = @"";
    _timeConlai.text = [NSString stringWithFormat:@"%@", [self timeFormat:self.audioPlayer.duration]];
    
    _audioPlayer.delegate = self; // nhan su kien het bai tu dung
    
    
    
    /* Mix audio */
    self.audioPlayer.enableRate = YES;
    self.audioPlayer.rate = 1; //speed
    self.audioPlayer.numberOfLoops = 0; // 0: play once, 1: play twice, -1: play forever
    self.audioPlayer.volume = 1; // 0 --> 1
    self.audioPlayer.pan = 0; //A value of –1.0 is full left, 0.0 is center, and 1.0 is full right.
    NSLog(@"numberOfChannels: %d",(int)self.audioPlayer.numberOfChannels);
}

/* Dowload Audio Stream URL, Write to File, Must setup in Info.plist if URL is http:// */
- (void)setupAVAudioPlayerWriteToDataWithURL: (NSString*)stringURL {
    NSURL *url = [NSURL URLWithString:stringURL];
    _player =[[AVPlayer alloc] initWithURL:url];
    
    [self.audioPlayer prepareToPlay];
    //    self.slider_showtimeCrre`nt.maximumValue = [self.audioPlayer duration];
    
    self.slider_showtimeCrrent.maximumValue = CMTimeGetSeconds(_player.currentItem.asset.duration);
    self.slider_showtimeCrrent.maximumTrackTintColor = [UIColor blackColor];
    _timeBaihat.text = @"0:00";
    _timeConlai.text = @"";
    self.timeConlai.text = [NSString stringWithFormat:@"%@", [self timeFormat:CMTimeGetSeconds(_player.currentItem.asset.duration)]];
}


- (NSString*)timeFormat: (float)time {
    int minutes = time/60;
    int seconds = (int)time % 60;
    return [NSString stringWithFormat:@"%@%d:%@%d", minutes/10 ? [NSString stringWithFormat:@"%d",minutes/10] : @"", minutes%10, [NSString stringWithFormat:@"%d", seconds/10], seconds%10];
}
- (void)updateTime {
    _slider_showtimeCrrent.value = [self.audioPlayer currentTime];
    _timeBaihat.text = [NSString stringWithFormat:@"%@",[self timeFormat:[self.audioPlayer currentTime]]];
    _timeConlai.text = [NSString stringWithFormat:@"%@", [self timeFormat:self.audioPlayer.duration - self.audioPlayer.currentTime]];
    
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [_timer invalidate];
    _timer= nil;
    [_audioPlayer setCurrentTime:0.0];
    _slider_showtimeCrrent.value = 0.0;
    isPlause =true;
    
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object ==_player.currentItem && [keyPath isEqualToString:@"status"]) {
        if (_player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            [self enablebtnPlaystop:YES];
            NSLog(@"ss");
        }else if (_player.currentItem.status == AVPlayerItemStatusFailed) {
            [self enablebtnPlaystop:NO];
            NSLog(@"fail");
        }else if (_player.currentItem.status == AVPlayerItemStatusUnknown) {
            [self enablebtnPlaystop:NO];
            NSLog(@"fail");
        }
    }
}
-(void)enablebtnPlaystop:(BOOL)yesno{
    [_btnPlay setEnabled:yesno];
    [_btnStop setEnabled:yesno];
    [_slider_showtimeCrrent setEnabled:yesno];
}


-(void)getCurrentime{
    AVPlayerItem * currentitem = _player.currentItem;
    CMTime duration = currentitem.asset.duration; // tong time
    CMTime currtime = currentitem.currentTime;
    _slider_showtimeCrrent.value = CMTimeGetSeconds(currtime);
    _timeBaihat.text =   [NSString stringWithFormat:@"%@",[self timeFormat:CMTimeGetSeconds(currtime)]];
    _timeConlai.text =   [NSString stringWithFormat:@"%@",[self timeFormat:CMTimeGetSeconds(duration) -CMTimeGetSeconds(currtime)]];
}

-(void)batsukiemhetnhac:(NSNotification*)notification{
    [_timer invalidate];
    _timer= nil;
    [_btnPlay setTitle:@"play" forState:UIControlStateNormal];
    _slider_showtimeCrrent.value = 0;
    
    NSLog(@"finish");
    
    [_player seekToTime:kCMTimeZero];
    isPlause = true;
}
@end
