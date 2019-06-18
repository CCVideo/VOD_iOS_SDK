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
@property (nonatomic) int mMVPMatrixHandle;
@property (nonatomic) int mMVMatrixHandle;
@property (nonatomic) int mPositionHandle;
@property (nonatomic) int mTextureCoordinateHandle;
@property (nonatomic) int mProgramHandle;
@property (nonatomic) int mContentType;
@property (nonatomic) int* mTextureUniformHandle;
@property (nonatomic) int mColorConversionHandle;
- (void) build;
- (void) use;
- (int) getTextureUniformSize;
@end

@interface DWRGBAProgram : DW360Program

@end

@interface DWYUV420PProgram : DW360Program

@end
