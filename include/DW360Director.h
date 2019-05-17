//
//  DW360Director.h
//  DW360Player4IOS
//
//  Created by ashqal on 16/4/7.
//  Copyright © 2016年 ashqal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DW360Program.h"
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "DWVRHeader.h"

#pragma mark DW360Director
@interface DW360Director : NSObject<IMDDestroyable>
- (instancetype)init;
- (void) shot:(DW360Program*) program;
- (void) reset;
- (void) updateProjection:(int)width height:(int)height;
- (void) updateProjectionNearScale:(float)scale;
- (void) updateProjection;
- (void) updateSensorMatrix:(GLKMatrix4)sensor;
- (void) updateTouch:(float)distX distY:(int)distY;

- (float) getRatio;
- (float) getNear;

- (void) setProjection:(GLKMatrix4)project;
- (void) setLookX:(float)lookX;
- (void) setEyeX:(float)eyeX;
- (void) setAngleX:(float)angleX;
- (void) setAngleY:(float)angleY;
- (void) setup;

@end

#pragma mark DW360DirectorFactory
@protocol DW360DirectorFactory <NSObject>
@required
- (DW360Director*) createDirector:(int) index;
@end

#pragma mark DW360DirectorFactory
@interface DW360DefaultDirectorFactory : NSObject<DW360DirectorFactory>

@end



