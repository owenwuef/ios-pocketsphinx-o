//
//  ViewController.h
//  ios-pocketsphinx-o
//
//  Created by OwenWu on 26/6/15.
//  Copyright (c) 2015 OwenWu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenEars/OEEventsObserver.h>
#import <OpenEars/OEPocketsphinxController.h>

@protocol ETASREngineWrapperDelegate <NSObject>
- (void)engineWrapperEndsRecognitionWithResults:(NSString *)resultStrings;
@end

@interface ViewController : UIViewController <OEEventsObserverDelegate>

@property (weak, nonatomic) IBOutlet UILabel *feedbackTextLabel;

@property (nonatomic, strong) id<ETASREngineWrapperDelegate>wrapperDelegate;

@end

