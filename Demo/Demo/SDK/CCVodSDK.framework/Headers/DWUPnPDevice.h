//
//  DWServiceModel.h
//  Demo
//
//  Created by zwl on 2019/7/4.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DWServiceModel;

@interface DWUPnPDevice : NSObject

/**
 *  @brief 设备ID
 */
@property(nonatomic,copy)NSString * uuid;

/**
 *  @brief 设备loactionURL
 */
@property(nonatomic,strong)NSURL * loaction;

/**
 *  @brief 设备地址
 */
@property(nonatomic,copy)NSString * URLHeader;

/**
 *  @brief 友好的设备名称
 */
@property(nonatomic,copy)NSString * friendlyName;

/**
 *  @brief 设备名称
 */
@property(nonatomic,copy)NSString * modelName;

/**
 *  @brief DWServiceModel对象
 */
@property(nonatomic,strong)DWServiceModel * AVTransport;

/**
 *  @brief DWServiceModel对象
 */
@property(nonatomic,strong)DWServiceModel * RenderingControl;

/*!
 * @method
 * @abstract 设置数组
 * @discussion 设置数组
 * @param array 数组
 */
-(void)setArray:(NSArray *)array;

@end

@interface DWServiceModel : NSObject

/**
 *  @brief 服务类型
 */
@property(nonatomic,copy)NSString * serviceType;

/**
 *  @brief 服务ID
 */
@property(nonatomic,copy)NSString * serviceId;

/**
 *  @brief controlURL
 */
@property(nonatomic,copy)NSString * controlURL;

/**
 *  @brief eventSubURL
 */
@property(nonatomic,copy)NSString * eventSubURL;

/**
 *  @brief SCPDURL
 */
@property(nonatomic,copy)NSString * SCPDURL;

/*!
 * @method
 * @abstract 设置数组
 * @discussion 设置数组
 * @param array 数组
 */
-(void)setArray:(NSArray *)array;

@end
