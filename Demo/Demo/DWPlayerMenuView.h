#import <UIKit/UIKit.h>

@interface DWPlayerMenuView : UIView


/**
 *  绘画用作播放下拉菜单背景的视图
 *
 *  三角形的高默认为 10
 *  图形方向默认朝上
 *
 *  @param frame      坐标
 *  @param color      图形的填充颜色
 *
 *  @return DWPlayerMenuView
 */
- (id)initWithFrame:(CGRect)frame FillColor:(UIColor *)color;


/**
 *  绘画用作播放下拉菜单背景的视图
 *
 *  图形方向默认朝上
 *
 *  @param frame      坐标
 *  @param height     三角形的高度
 *  @param color      图形的填充颜色
 *
 *  @return DWPlayerMenuView
 */
- (id)initWithFrame:(CGRect)frame andTriangelHeight:(NSInteger)height FillColor:(UIColor *)color;

/**
 *  绘画用作播放下拉菜单背景的视图
 *
 *  @param frame      坐标
 *  @param height     三角形的高度
 *  @param upsideDown 方向是否倒置
 *  @param color      图形的填充颜色
 *
 *  @return DWPlayerMenuView
 */
- (id)initWithFrame:(CGRect)frame andTriangelHeight:(NSInteger)height upsideDown:(BOOL)upsideDown FillColor:(UIColor *)color;

@end
