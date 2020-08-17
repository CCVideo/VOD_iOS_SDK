//
//  DW360Program.h
//  DW360Player4IOS
//
//  Created by ashqal on 16/4/6.
//  Copyright © 2016年 ashqal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWVRHeader.h"

@interface DW360Program : NSObject<IMDDestroyable>{
    GLuint vertexShaderHandle,fragmentShaderHandle;
    
}

/**
 *  @brief MVP矩阵
 */
@property(nonatomic)int mMVPMatrixHandle;

/**
 *  @brief MV矩阵
 */
@property(nonatomic)int mMVMatrixHandle;

/**
 *  @brief 坐标
 */
@property(nonatomic)int mPositionHandle;

/**
 *  @brief 纹理坐标
 */
@property(nonatomic)int mTextureCoordinateHandle;

/**
 *  @brief program
 */
@property(nonatomic)int mProgramHandle;

/**
 *  @brief 内容类型
 */
@property(nonatomic)int mContentType;

/**
 *  @brief textureUniform指针
 */
@property(nonatomic)int* mTextureUniformHandle;

/**
 *  @brief 色彩转换
 */
@property(nonatomic)int mColorConversionHandle;

/*!
 * @method
 * @abstract 初始化准备
 * @discussion 初始化准备
 */
-(void)build;

/*!
 * @method
 * @abstract 使用
 * @discussion 使用
 */
-(void)use;

/*!
 * @method
 * @abstract 获取默认值
 * @discussion 获取默认值
 * @result textureUniformSize
 */
-(int)getTextureUniformSize;

@end

@interface DWRGBAProgram : DW360Program

@end

@interface DWYUV420PProgram : DW360Program

@end
