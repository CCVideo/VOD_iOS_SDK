//
//  DWDownloadSessionManager+File.h
//  Demo
//
//  Created by zwl on 2019/5/5.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWDownloadSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface DWDownloadSessionManager (File)

+(DWDownloadModel *)createDownloadModelWithUrl:(NSString *)downloadURL FileName:(NSString *)fileName MimeType:(NSString *)mimeType AndOthersInfo:(NSDictionary *)othersInfo;

-(void)decompressionFinish:(DWDownloadModel *)downloadModel;

-(BOOL)checkLocalResourceWithUrl:(NSString *)downloadURL;

@end

NS_ASSUME_NONNULL_END
