//
//  AppDelegate.m
//  ios-pocketsphinx-o
//
//  Created by OwenWu on 26/6/15.
//  Copyright (c) 2015 OwenWu. All rights reserved.
//

#import "AppDelegate.h"

//#include "pocketsphinx.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

/*
-(BOOL)initPocketSphinx {
    ps_decoder_t *ps;
    cmd_ln_t *config;
    FILE *fh;
    char const *hyp, *uttid;
    unsigned int buf[512];
    int rv;
    unsigned long score;
    
    config = cmd_ln_init(NULL, ps_args(), TRUE,
                         "-hmm", MODELDIR "/hmm/en_US/hub4wsj_sc_8k",
                         "-lm", MODELDIR "/lm/en/turtle.DMP",
                         "-dict", MODELDIR "/lm/en/turtle.dic",
                         NULL);
    if (config == NULL)
        return YES;

    ps = ps_init(config);
    if (ps == NULL)
        return YES;
    
    fh = fopen("/dev/input/event14", "rb");
    if (fh == NULL) {
        perror("Failed to open goforward.raw");
        return YES;
    }
    
    rv = ps_decode_raw(ps, fh, NULL, -1);
    if (rv < 0)
        return YES;
    
    hyp = ps_get_hyp(ps, &score, &uttid);
    if (hyp == NULL)
        return YES;
    printf("Recognized: %s\n", hyp);
    

    fseek(fh, 0, SEEK_SET);
    rv = ps_start_utt(ps, NULL);
    if (rv < 0)
        return YES;
    while (!feof(fh)) {
        rv = ps_start_utt(ps, NULL);
        if (rv < 0)
            return YES;
        
        printf("ready:\n");
        size_t nsamp;
        nsamp = fread(buf, 2, 512, fh);
        printf("read:\n");

        rv = ps_process_raw(ps, buf, nsamp, FALSE, FALSE);
        printf("process:\n");
    }
    
    rv = ps_end_utt(ps);
    if (rv < 0)
        return YES;
    
    hyp = ps_get_hyp(ps, &score, &uttid);
    if (hyp == NULL)
        return YES;
    printf("Recognized: %s\n", hyp);

    fclose(fh);
    ps_free(ps);
}
 
 http://blog.csdn.net/u012637501/article/details/40875081
*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.
//    return [self initPocketSphinx];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
