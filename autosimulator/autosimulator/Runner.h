//
//  Runner.h
//  autosimulator
//
//  Created by Razer on 14/12/9.
//  Copyright (c) 2014年 Razer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Runner : NSObject{
    NSPipe *mPipe;
    NSTask* mTask;
}
+(Runner*)sharedRunner;
-(void)run:(NSString *)path argumens:(NSArray*)arguments;
-(NSString*)runSync:(NSString *)path argumens:(NSArray *)arguments;
-(void)terminal;
@end
