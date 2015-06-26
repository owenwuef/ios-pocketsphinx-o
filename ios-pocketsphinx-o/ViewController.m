//
//  ViewController.m
//  ios-pocketsphinx-o
//
//  Created by OwenWu on 26/6/15.
//  Copyright (c) 2015 OwenWu. All rights reserved.
//

#import "ViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

- (IBAction)recordPauseTapped:(id)sender;
- (IBAction)stopTapped:(id)sender;
- (IBAction)playTapped:(id)sender;
@end

@implementation ViewController
@synthesize stopButton, playButton, recordPauseButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [stopButton setEnabled:NO];
    [playButton setEnabled:NO];
    
    
    // set Audio file path
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.wav",
                               nil];
    NSURL* outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // setup audio session
    NSError *setOverrideError;
    NSError *setCategoryError;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&setCategoryError];
    
    if(setCategoryError){
        NSLog(@"%@", [setCategoryError description]);
    }
    
    // increase the playing voice when play recorded voice
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&setOverrideError];
    
    
    if(setOverrideError){
        NSLog(@"%@", [setOverrideError description]);
    }
    
    // define the recorder setting
    NSMutableDictionary* recorderSetting = [[NSMutableDictionary alloc] init];
    [recorderSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recorderSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [recorderSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    
    // initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recorderSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordPauseTapped:(id)sender {
    // stop the audio player before recording
    if ( player.playing)
        [player stop];
    
    if(!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        //[session setCategory:AVAudioSessionCategoryRecord error:nil];
        [session setActive:YES error:nil];
        
        // start recording
        [recorder record];
        [recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        // pause recording
        [recorder pause];
        [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    [stopButton setEnabled:YES];
    [playButton setEnabled:NO];
}

- (IBAction)stopTapped:(id)sender {
    [recorder stop];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
}

- (IBAction)playTapped:(id)sender {
    if(!recorder.recording) {
        //        AVAudioSession* session = [AVAudioSession sharedInstance];
        //        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
        
    }
}

#pragma mark -
#pragma mark AVAudioRecorderDelegate
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
    [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [stopButton setEnabled:NO];
    [playButton setEnabled:YES];
}


#pragma mark -
#pragma mark AVAudioPlayerDelegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
