//
//  DWExt.h
//  IJKMediaPlayer
//
//  Created by ashqal on 16/7/14.
//  Copyright © 2016年 bilibili. All rights reserved.
//

#ifndef DWExt_h
#define DWExt_h

#import <UIKit/UIKit.h>

struct DWVideoFrame {
    int w; /**< Read-only */
    int h; /**< Read-only */
    uint32_t format; /**< Read-only */
    int planes; /**< Read-only */
    uint16_t *pitches; /**< in bytes, Read-only */
    unsigned char **pixels; /**< Read-write */
};

typedef struct DWVideoFrame DWVideoFrame;

@protocol DWVideoFrameCallback <NSObject>
@required
- (void) onFrameAvailable:(DWVideoFrame*) frame;
@end

#pragma mark just for ijk
@protocol DWIJKSDLGLView <NSObject>
@required
- (void) setFrameCallback:(id<DWVideoFrameCallback>) callback;
@end


#endif /* DWExt_h */
