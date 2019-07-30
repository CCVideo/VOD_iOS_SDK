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

///设备ID
@property(nonatomic,copy)NSString * uuid;

///设备loactionURL
@property(nonatomic,strong)NSURL * loaction;

///设备地址
@property(nonatomic,copy)NSString * URLHeader;

///友好的设备名称
@property(nonatomic,copy)NSString * friendlyName;

//设备名称
@property(nonatomic,copy)NSString * modelName;

@property(nonatomic,strong)DWServiceModel * AVTransport;

@property(nonatomic,strong)DWServiceModel * RenderingControl;

- (void)setArray:(NSArray *)array;

@end

@interface DWServiceModel : NSObject

///服务类型
@property (nonatomic,copy)NSString * serviceType;

///服务ID
@property (nonatomic,copy)NSString * serviceId;

///controlURL
@property (nonatomic,copy)NSString * controlURL;

///eventSubURL
@property (nonatomic,copy)NSString * eventSubURL;

///SCPDURL
@property (nonatomic,copy)NSString * SCPDURL;

- (void)setArray:(NSArray *)array;

@end
