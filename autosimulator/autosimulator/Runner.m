//
//  Runner.m
//  autosimulator
//
//  Created by Razer on 14/12/9.
//  Copyright (c) 2014年 Razer. All rights reserved.
//

#import "Runner.h"

@implementation Runner
static Runner *sharedRunner = nil;
+(Runner*)sharedRunner{
    if (!sharedRunner) {
        sharedRunner = [[super alloc] init];
    }
    return sharedRunner;
}

-(id)init{
    if (sharedRunner) {
        return sharedRunner;
    }
    self = [super init];
    return self;
}

-(void)dealloc{
    [super dealloc];
    [self releaseTaskAndPipe];
}

-(void)releaseTaskAndPipe{
    if (mPipe) {
        [mPipe release];
        mPipe = nil;
    }
    
    if (mTask) {
        [mTask terminate];
        [mTask release];
        mTask = nil;
    }
  
    [[NSNotificationCenter defaultCenter] removeObserver:NSTaskDidTerminateNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:NSFileHandleReadCompletionNotification];
}
-(void)run:(NSString *)path argumens:(NSArray*)arguments{
    [self releaseTaskAndPipe];
    mTask = [[NSTask alloc] init];
    mPipe = [NSPipe pipe];
    [mPipe retain];
    [mTask setStandardOutput: mPipe];
    [mTask setStandardError: mPipe];
    NSFileHandle *file = [mPipe fileHandleForReading];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskComplete:) name:NSTaskDidTerminateNotification object:mTask];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(readFromStandardOutput:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:file];
    [file readInBackgroundAndNotify];
    
 
    [mTask setLaunchPath: path];
    [mTask setArguments: arguments];
    [mTask launch];
}



-(NSString*)runSync:(NSString *)path argumens:(NSArray*)arguments{
    [self releaseTaskAndPipe];
    mTask = [[NSTask alloc] init];
    mPipe = [NSPipe pipe];
    [mPipe retain];
    [mTask setStandardOutput: mPipe];
    [mTask setStandardError: mPipe];
    NSFileHandle *file = [mPipe fileHandleForReading];
    [mTask setLaunchPath: path];
    [mTask setArguments: arguments];
    [mTask launch];
    NSData *data= [file readDataToEndOfFile];
    NSString *string= [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

- (void)readFromStandardOutput:(NSNotification*)aNotification{
    [[aNotification object] readInBackgroundAndNotify];
    NSData *data = [[aNotification userInfo] valueForKey:NSFileHandleNotificationDataItem];
    if(data==nil){
        return;
    }
    NSString *bytes = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(bytes==nil || [bytes isEqualToString:@""]) {
        [bytes release];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KReadData" object:bytes];
    [bytes release];
}

-(void)taskComplete:(NSNotification*)aNotification{
     [[NSNotificationCenter defaultCenter] postNotificationName:@"KTaskFinish" object:nil];
}

-(void)terminal{
    [self releaseTaskAndPipe];
}

@end
