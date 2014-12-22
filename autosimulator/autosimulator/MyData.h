//
//  MyData.h
//  autosimulator
//
//  Created by Razer on 14/12/9.
//  Copyright (c) 2014年 Razer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyData : NSObject<NSCoding>{
    
}

@property (copy,nonatomic) NSString *projectPath;
@property (copy,nonatomic) NSString *resPath;
@property (assign) BOOL isBuild;
@property (copy,nonatomic) NSString *currentTarget;
@property (copy,nonatomic) NSMutableArray *targets;

-(void)description;
@end
