//
//  ViewController.m
//  ios-pocketsphinx-o
//
//  Created by OwenWu on 26/6/15.
//  Copyright (c) 2015 OwenWu. All rights reserved.
//

#import "ViewController.h"
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OELogging.h>
#import <OpenEars/OEAcousticModel.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
    NSMutableArray * currentWords;
    NSMutableDictionary * currentSentences;
    bool isSpeechDetected;
}

@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic, copy) NSString * pathToGrammarToStartAppWith;
@property (nonatomic, copy) NSString * pathToDictionaryToStartAppWith;

@property (nonatomic, assign) int restartAttemptsDueToPermissionRequests;
@property (nonatomic, assign) BOOL startupFailedDueToLackOfPermissions;
@property (nonatomic, strong) OEPocketsphinxController * sphinxController;

- (IBAction)recordPauseTapped:(id)sender;
- (IBAction)stopTapped:(id)sender;
- (IBAction)playTapped:(id)sender;
@end

@implementation ViewController
@synthesize stopButton, playButton, recordPauseButton;

#pragma mark -
#pragma mark VC Lifecycle
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
    [recorderSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
    [recorderSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    
//    [settings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
//    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
//    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

    // initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recorderSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
    _feedbackTextLabel.text = @"Say Hello!";
    
    [self createLanguageModelWithWords:@[@"HELLO"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark IBActions
- (IBAction)recordPauseTapped:(id)sender {
    // stop the audio player before recording
    if ( player.playing)
        [player stop];
    
    if(!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
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
    
    _feedbackTextLabel.text = @"...";
}

- (IBAction)stopTapped:(id)sender {
    [recorder stop];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
    
}

- (IBAction)playTapped:(id)sender {
    if(!recorder.recording) {
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
    
    id temp = [self init];
    NSLog(@"%s---%@",__FUNCTION__, temp);
    
    [self startListening];
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

#pragma mark Private Methods
-(void)createLanguageModelWithWords:(NSArray*)words
{
    
    
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    NSString *name = @"generatedLanguageModel";
    NSDictionary *grammarDict =  @{OneOfTheseCanBeSaidOnce : words};
    
    NSError *err = [lmGenerator generateGrammarFromDictionary:grammarDict withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    if(err == nil) {
        

        self.pathToGrammarToStartAppWith = [lmGenerator pathToSuccessfullyGeneratedGrammarWithRequestedName:name];
        self.pathToDictionaryToStartAppWith = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:name];
        NSLog(@"grammar %@ \nDictionary %@", [NSString stringWithContentsOfFile:self.pathToGrammarToStartAppWith encoding:NSUTF8StringEncoding error:nil],[NSString stringWithContentsOfFile:self.pathToDictionaryToStartAppWith encoding:NSUTF8StringEncoding error:nil]);
        [self startListening];
        
        
    } else {
        NSLog(@"Error Model: %@",[err localizedDescription]);
    }
    
    
}

- (void)startListening {
    
    [self.sphinxController setActive:TRUE error:nil];
    
    //self.sphinxController.pathToTestFile = wavFilePath;
    self.sphinxController.returnNbest= YES;
    self.sphinxController.nBestNumber= 150;
    self.sphinxController.returnNullHypotheses = YES;
    
    
    [self.sphinxController runRecognitionOnWavFileAtPath:[recorder.url path] usingLanguageModelAtPath:self.pathToGrammarToStartAppWith dictionaryAtPath:self.pathToDictionaryToStartAppWith acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:YES];
    
}

#pragma mark Overrides

- (id)init
{
    self = [super init];
    
    self.restartAttemptsDueToPermissionRequests = 0;
    self.startupFailedDueToLackOfPermissions = FALSE;
    
    [OELogging startOpenEarsLogging];
    self.sphinxController = [OEPocketsphinxController new];
    self.sphinxController.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    self.sphinxController.openEarsEventsObserver.delegate = self;
    
    return self;
}

- (void)dealloc
{
    self.sphinxController.openEarsEventsObserver.delegate = nil;
}


#pragma mark OpenEarsEventsObserver delegate methods

- (void) pocketsphinxDidStartListening {
    isSpeechDetected = NO;
}

- (void) pocketsphinxDidDetectSpeech {
    isSpeechDetected = YES;
}


-(void) pocketsphinxTestRecognitionCompleted {
    if(!isSpeechDetected)
    {
        [self.sphinxController stopListening];
        
    }
    
}

-(void) pocketsphinxDidReceiveNBestHypothesisArray:(NSArray *)hypothesisArray
{
    NSLog(@"hypothesis %@", hypothesisArray);
//    [self.sphinxController stopListening];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSDictionary * hypoDict in hypothesisArray) {
            _feedbackTextLabel.text = [hypoDict objectForKey:@"Hypothesis"];
         }
//        [self compareWithHypothesisArray:hypothesisArray];
        
    });
    
}


- (void) pocketsphinxFailedNoMicPermissions {
    
    self.startupFailedDueToLackOfPermissions = TRUE;
}


- (void) micPermissionCheckCompleted:(BOOL)result {
    if(result == TRUE) {
        self.restartAttemptsDueToPermissionRequests++;
        if(self.restartAttemptsDueToPermissionRequests == 1 && self.startupFailedDueToLackOfPermissions == TRUE) {
            [self startListening]; // Only do this once.
            self.startupFailedDueToLackOfPermissions = FALSE;
        }
    }
}

@end
