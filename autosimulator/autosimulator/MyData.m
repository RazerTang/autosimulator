//
//  MyData.m
//  autosimulator
//
//  Created by Razer on 14/12/9.
//  Copyright (c) 2014年 Razer. All rights reserved.
//

#import "MyData.h"

@implementation MyData
@synthesize  projectPath;
@synthesize  isBuild;
@synthesize  currentTarget;
@synthesize  targets;

#define KProjectPathKey @"projectPath"
#define KResPathKey @"resPath"
#define KIsBuildKey @"isBuild"
#define KCurrentTarget @"currentTarget"
#define KTargets @"targets"

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.projectPath forKey:KProjectPathKey];
    [aCoder encodeObject:self.resPath forKey:KResPathKey];
    [aCoder encodeBool:self.isBuild forKey:KIsBuildKey];
    [aCoder encodeObject:self.currentTarget forKey:KCurrentTarget];
    [aCoder encodeObject:self.targets forKey:KTargets];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.projectPath   = [aDecoder decodeObjectForKey:KProjectPathKey];
        self.resPath       = [aDecoder decodeObjectForKey:KResPathKey];
        self.isBuild       = [aDecoder decodeBoolForKey:KIsBuildKey];
        self.currentTarget = [aDecoder decodeObjectForKey:KCurrentTarget];
        self.targets       = [aDecoder decodeObjectForKey:KTargets];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MyData *copy = [[[self class] allocWithZone:zone] init];
    copy.resPath       = self.resPath;
    copy.projectPath   = self.projectPath;
    copy.isBuild       = self.isBuild;
    copy.currentTarget = self.currentTarget ;
    copy.targets       = self.targets ;
    return copy;
}

-(void)description{
    NSLog(@"projectpaht=%@ isbuild=%d currenttarge=%@  ",self.projectPath,self.isBuild,self.currentTarget);
    for (NSString * string in self.targets) {
        NSLog(@"target=%@",string);
    }
}
@end
