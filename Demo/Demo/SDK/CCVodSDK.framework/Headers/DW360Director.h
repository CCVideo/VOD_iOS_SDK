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

/*!
 * @method
 * @abstract 初始化对象
 * @discussion 初始化对象
 * @result DW360Director对象
 */
-(instancetype)init;

/*!
 * @method
 * @abstract 传递DW360Program
 * @discussion 传递DW360Program
 * @param program DW360Program对象
 */
-(void)shot:(DW360Program*)program;

/*!
 * @method
 * @abstract 恢复初始值
 * @discussion 恢复初始值
 */
-(void)reset;

/*!
 * @method
 * @abstract 更新投影宽高
 * @discussion 更新投影宽高
 * @param width 宽
 * @param height 高
 */
-(void)updateProjection:(int)width height:(int)height;

/*!
 * @method
 * @abstract 更新投影比例
 * @discussion 更新投影比例
 * @param scale 比例
 */
-(void)updateProjectionNearScale:(float)scale;

/*!
 * @method
 * @abstract 更新投影
 * @discussion 更新投影
 */
-(void)updateProjection;

/*!
 * @method
 * @abstract 更新矩阵
 * @discussion 更新矩阵
 * @param sensor 矩阵
 */
-(void)updateSensorMatrix:(GLKMatrix4)sensor;

/*!
 * @method
 * @abstract 更新touch坐标
 * @discussion 更新touch坐标
 * @param distX X坐标
 * @param distY Y坐标
 */
-(void)updateTouch:(float)distX distY:(int)distY;

/*!
 * @method
 * @abstract 获取比率
 * @discussion 获取比率
 * @result 比率
 */
-(float)getRatio;

/*!
 * @method
 * @abstract 获取投影比例
 * @discussion 获取投影比例
 * @result 投影比例
 */
-(float)getNear;

/*!
 * @method
 * @abstract 设置矩阵
 * @discussion 设置矩阵
 * @param project 矩阵
 */
-(void)setProjection:(GLKMatrix4)project;

/*!
 * @method
 * @abstract 设置lookX
 * @discussion 设置lookX
 * @param lookX lookX
 */
-(void)setLookX:(float)lookX;

/*!
 * @method
 * @abstract 设置eyeX
 * @discussion 设置eyeX
 * @param eyeX eyeX
 */
-(void)setEyeX:(float)eyeX;

/*!
 * @method
 * @abstract 设置角度坐标
 * @discussion 设置角度坐标
 * @param angleX X坐标
 */
-(void)setAngleX:(float)angleX;

/*!
 * @method
 * @abstract 设置角度坐标
 * @discussion 设置角度坐标
 * @param angleY Y坐标
 */
-(void)setAngleY:(float)angleY;

/*!
 * @method
 * @abstract 开始
 * @discussion 开始
 */
-(void)setup;

@end

#pragma mark DW360DirectorFactory
@protocol DW360DirectorFactory <NSObject>
@required

/** 创建导向器回调
 @param index 序号
 @return DW360Director对象
 */
-(DW360Director*)createDirector:(int)index;

@end

#pragma mark DW360DirectorFactory
@interface DW360DefaultDirectorFactory : NSObject<DW360DirectorFactory>

@end



