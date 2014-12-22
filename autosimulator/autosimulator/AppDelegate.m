//
//  AppDelegate.m
//  autosimulator
//
//  Created by Razer on 14/12/9.
//  Copyright (c) 2014年 Razer. All rights reserved.
//

#import "AppDelegate.h"
#import "Runner.h"
#import "MyData.h"
#import "iPhoneSimulator.h"

@interface AppDelegate ()

@property (assign) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

-(void)dealloc{
    [super dealloc];
    [mSimulator release];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self loaData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readData:) name:@"KReadData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskFinish:) name:@"KTaskFinish" object:nil];
    mTaskTerminal = YES;
    self.stopBtn.hidden =YES;
    self.runSimutorBtn.hidden = NO;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)onBrowseTouched:(id)sender {
        NSOpenPanel* openDlg = [NSOpenPanel openPanel];
        
        // Enable the selection of directories in the dialog.
        [openDlg setCanChooseDirectories:NO];
        [openDlg setCanChooseFiles:YES];
        [openDlg setAllowedFileTypes:[NSArray arrayWithObject:@"xcodeproj"]];
        if ( [openDlg runModal] == NSModalResponseOK )
        {
            // Get an array containing the full filenames of all
            // files and directories selected.
            NSArray* files = [openDlg URLs];
            assert([files count] >0);
            NSURL *url = [files objectAtIndex:0];
            mProjectPath = [url path];
            NSLog(@"%@ ",[url path]);
            
            
            self.projectPath.stringValue =mProjectPath;
            
            
            NSString *xcodebuildPath = [[NSBundle mainBundle] pathForResource:@"xcodebuild" ofType:nil];
            NSString *content = [[Runner sharedRunner] runSync:xcodebuildPath argumens:@[@"-list",@"-project",mProjectPath]];
            //get the targets array
            NSRange range1 = [content rangeOfString:@"Targets:"];
            NSRange range2 = [content rangeOfString:@"Build Configurations:"];
            
            content = [content substringWithRange:NSMakeRange(range1.location +range1.length, range2.location - range1.location - range1.length)];
            content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray *targetsArray = [content componentsSeparatedByString:@"\n"];
            if ([targetsArray count]==0) {
                [self alert:@"there is not any targets int this project" title:@"Not found targets"];
            }else{
                //remove empty string
                [self.comboxProjTargets removeAllItems];
                for (NSString *tarString in targetsArray) {
                    NSString *newString = [[tarString copy] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [self.comboxProjTargets addItemWithObjectValue:newString];
                }
                self.resPath.stringValue=@"";
                [self.comboxProjTargets selectItemAtIndex:0];
                [self saveData];
            }
        }
}

- (IBAction)onResBrowseTouched:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanChooseFiles:NO];
    if ( [openDlg runModal] == NSModalResponseOK )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg URLs];
        assert([files count] >0);
        NSURL *url = [files objectAtIndex:0];
        mResPath = [url path];
        NSLog(@"%@ ",[url path]);
        self.resPath.stringValue =mResPath;
        [self saveData];
       
    }
}

- (IBAction)onRunTouched:(id)sender {
    if (!mTaskTerminal) {
        return;
    }
    mState = KTaskStatusUnknow;
    self.logTextView.string=@"";
    self.stopBtn.hidden =NO;
    self.runSimutorBtn.hidden = YES;
    [self saveData];
   
//    NSString *derivedDataPath = [@"DSTROOT=/Users/Razer/Library/Developer/Xcode/DerivedData/" stringByAppendingPathComponent:target];
//    NSString *installPath = [derivedDataPath stringByAppendingFormat:@"/build/%@.app",target];
//    NSString *appPath     = [@"/Users/Razer/Library/Developer/Xcode/DerivedData/"  stringByAppendingFormat:@"%@/build/%@.app",target,target];
    BOOL isBuild = [self.buildCheckBox state];
    //build it
    if (isBuild) {
        //1.first build
        [self build];
    }
    else{
        //2 then cp resources
        [self cp];
    }

}

//-(void)runNextSimulator{
//    NSString *appPath =[[mProjectPath stringByDeletingLastPathComponent] stringByAppendingFormat:@"/build/Debug-iphonesimulator/bhdotain.app" ];
//    int argc =6;
//    char *argv[6];
//    argv[1]="launch";
//    argv[2]=(char*)[appPath UTF8String];
//    argv[3]="--timeout";
//    argv[4]="90";
//    argv[5]="--verbose";
//    /* Execute command line handler */
//    [mSimulator runWithArgc: argc argv: argv];
//}



- (IBAction)onStopTouched:(id)sender {
    mState = KTaskStatusUnknow;
    [[Runner sharedRunner] terminal];
    self.stopBtn.hidden =YES;
    self.runSimutorBtn.hidden = NO;
}

- (IBAction)onClearTouched:(id)sender {
    self.logTextView.string = @"";
}

-(void)saveData{
    MyData *data = [[MyData alloc] init];
    data.projectPath        = self.projectPath.stringValue;
    data.isBuild            = self.buildCheckBox.state;
    data.currentTarget      = self.comboxProjTargets.stringValue;
    data.resPath            = self.resPath.stringValue;
    if (data.projectPath==nil) {
        data.projectPath=@"";
    }
    if (data.currentTarget==nil) {
        data.currentTarget=@"";
    }
    if (data.resPath==nil) {
        data.resPath=@"";
    }
    NSMutableArray *targets = [NSMutableArray array];
    for (NSString * string in self.comboxProjTargets.objectValues) {
        [targets addObject:string];
    }
    data.targets = targets;
 
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count]==0) {
        return;
    }
    NSString *fileName = [[paths objectAtIndex:0] stringByAppendingString:@"/autosimulator.bin"];
    BOOL success = [NSKeyedArchiver archiveRootObject:data toFile:fileName];
    [data release];
   
    if (!success) {
        assert(0);
    }
}

-(void)loaData{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count]==0) {
        return;
    }
    NSString *fileName = [[paths objectAtIndex:0] stringByAppendingString:@"/autosimulator.bin"];
    
    MyData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    mProjectPath                        = data.projectPath;
    mResPath                            = data.resPath;
    self.projectPath.stringValue        = data.projectPath;
    self.buildCheckBox.state            = data.isBuild;
    self.comboxProjTargets.stringValue  = data.currentTarget;
    self.resPath.stringValue            = data.resPath;
    for (NSString * string in data.targets) {
        [self.comboxProjTargets addItemWithObjectValue:string];
    }
}

#pragma mark -
-(void)build{
    if(!mTaskTerminal) return;
    mState = KTaskStatusUnknow;
    NSString *target = self.comboxProjTargets.stringValue;
    NSString *xcodebuildPath = [[NSBundle mainBundle] pathForResource:@"xcodebuild" ofType:nil];
    NSString* sdks=[[Runner sharedRunner] runSync:xcodebuildPath argumens:@[@"-showsdks"]];
    sdks = [sdks stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([sdks length] == 0) {
        sdks = nil;
    } else {
        NSArray* parts = [sdks componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        for (NSString *simver in parts) {
            if ([simver isEqualToString:@""]==NO && [simver rangeOfString:@"iphonesimulator"].location!=NSNotFound) {
                sdks = simver;//use min sdk
            }
        }
    }
    if (sdks) {
        mTaskTerminal = NO;
        mState = KTaskStatusBuild;
        mBuildSuccess = NO;
        ///*,@"install",installPath*/
        [[Runner sharedRunner] run:xcodebuildPath argumens:@[@"-sdk",sdks,@"-configuration",@"Debug",@"-target",target,@"-project",mProjectPath]];
    }else{
        [self alert:@"Not find sdk" title:@"can not find iphonesimulator sdk"];
    }
    
    //install need code sign,use appscript may effect
}

-(void)cp{
    if(!mTaskTerminal) return;
    BOOL isDirectory;
    if([[NSFileManager defaultManager] fileExistsAtPath:mResPath isDirectory:&isDirectory]){
        mState = KTaskStatusCopy;
        mTaskTerminal = NO;
        NSString *target = self.comboxProjTargets.stringValue;
        NSString *resourcesPath = [mResPath stringByAppendingString:@"/*"];
        NSString *appPath =[[mProjectPath stringByDeletingLastPathComponent] stringByAppendingFormat:@"/build/Debug-iphonesimulator/%@.app",target ];
        NSString *cpCommand = [NSString stringWithFormat:@"cp -rfv %@ %@ ",resourcesPath,appPath];
        [[Runner sharedRunner] run:@"/bin/bash" argumens:@[@"-c",cpCommand]];
    }else{
        [self runSimulator];
    }
}

-(void)runSimulator{
    if(!mTaskTerminal) return;
    NSString *target = self.comboxProjTargets.stringValue;
    NSString *appPath =[[mProjectPath stringByDeletingLastPathComponent] stringByAppendingFormat:@"/build/Debug-iphonesimulator/%@.app",target ];
    BOOL isDirectory;
    if([[NSFileManager defaultManager] fileExistsAtPath:appPath isDirectory:&isDirectory]){
        mState = KTaskStatusRunSimulator;
        mTaskTerminal = NO;
        NSString *iossim  = [[NSBundle mainBundle] pathForResource:@"ios-sim" ofType:nil];
        NSString *exec= [iossim stringByAppendingFormat:@" launch %@ --timeout 60 --verbose",appPath];
        [[Runner sharedRunner] run:@"/bin/bash" argumens:@[@"-c",exec,]];
    }else{
        [self alert:appPath title:@"Not Found App"];
    }
}


#pragma mark -
-(void)readData:(NSNotification*) aNotification{
    NSString *bytes = [aNotification object];
    if (bytes ==nil || [bytes isEqualToString:@""]) {
        return;
    }
    
    if ([bytes rangeOfString:@"BUILD SUCCEEDED"].location !=NSNotFound && !mBuildSuccess) {
        mBuildSuccess = YES;
    }

    if(self.logTextView.string.length > 50000 ){
        self.logTextView.string = @"";
    }
  
    NSScroller *scroller = [self.scrollView verticalScroller];
    float position = [scroller floatValue];
    self.logTextView.string =  [self.logTextView.string stringByAppendingString:bytes];
    if (position  >= 1) {
         [self.logTextView scrollRangeToVisible: NSMakeRange(self.logTextView.string.length, 0)];
    }

}

-(void)taskFinish:(NSNotification*) aNotification{
    mTaskTerminal = YES;
    if(mState == KTaskStatusBuild  && mBuildSuccess){
//        [self cp];
    }else if (mState == KTaskStatusCopy) {
        [self runSimulator];
    }
}



-(void) alert:(NSString*)msg title:(NSString*)title
{
    NSAlert * messageBox = [[NSAlert alloc] init];
    [messageBox setMessageText:msg];
    [messageBox setInformativeText:title];
    [messageBox addButtonWithTitle:@"ok"];
    [messageBox runModal];
}

@end
