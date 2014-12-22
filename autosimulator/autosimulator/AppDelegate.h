//
//  AppDelegate.h
//  autosimulator
//
//  Created by Razer on 14/12/9.
//  Copyright (c) 2014年 Razer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum : NSUInteger {
    KTaskStatusUnknow,
    KTaskStatusBuild,
    KTaskStatusCopy,
    KTaskStatusRunSimulator,
} kTaskState;

@class iPhoneSimulator;
@interface AppDelegate : NSObject <NSApplicationDelegate>{
    NSString *mProjectPath;
    NSString *mResPath;
    iPhoneSimulator *mSimulator;
    int mState;//操作状态
    BOOL mTaskTerminal;
    BOOL mBuildSuccess;
}

@property (assign) IBOutlet NSTextField *projectPath;
- (IBAction)onBrowseTouched:(id)sender;
@property (assign) IBOutlet NSButton *buildCheckBox;
- (IBAction)onRunTouched:(id)sender;
@property (assign) IBOutlet NSTextView *logTextView;
@property (assign) IBOutlet NSTextField *resPath;
- (IBAction)onResBrowseTouched:(id)sender;

@property (assign) IBOutlet NSComboBox *comboxProjTargets;
@property (assign) IBOutlet NSButton *stopBtn;
@property (assign) IBOutlet NSButton *runSimutorBtn;
@property (assign) IBOutlet NSScrollView *scrollView;

- (IBAction)onStopTouched:(id)sender;

- (IBAction)onClearTouched:(id)sender;
-(void)saveData;
-(void)loaData;
@end

