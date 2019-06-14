#import <UIKit/UIKit.h>


@protocol DWGestureViewDelegate <NSObject>

/**
 * 开始触摸
 */
- (void)touchesBeganWithPoint:(CGPoint)point;

/**
 * 结束触摸
 */
- (void)touchesEndWithPoint:(CGPoint)point;

/**
 * 移动手指
 */
- (void)touchesMoveWithPoint:(CGPoint)point;

@end

@interface DWGestureView : UIView

/**
 * 传递点击事件的代理
 */
@property (weak, nonatomic) id <DWGestureViewDelegate> touchDelegate;

@end
