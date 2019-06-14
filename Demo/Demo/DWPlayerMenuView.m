#import "DWPlayerMenuView.h"

@interface DWPlayerMenuView ()

@property (strong, nonatomic)UIColor *fillColor;
/**
 *  默认三角形的高为10
 */
@property (assign, nonatomic)NSInteger triangleHeight;
@property (assign, nonatomic)BOOL upsideDown;

@end

@implementation DWPlayerMenuView


- (id)initWithFrame:(CGRect)frame FillColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        _fillColor = color;
        _triangleHeight = 10;
        _upsideDown = NO;
    } return self;
}

- (id)initWithFrame:(CGRect)frame andTriangelHeight:(NSInteger)height FillColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        _fillColor = color;
        _triangleHeight = height;
        _upsideDown = NO;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andTriangelHeight:(NSInteger)height upsideDown:(BOOL)upsideDown FillColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        _fillColor = color;
        _triangleHeight = height;
        _upsideDown = upsideDown;
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (self.upsideDown) {
        [self drawRectOrientationUpsideDown:rect];
    } else {
        [self drawRectOrientationPortrait:rect];
    }
}

- (void)drawRectOrientationUpsideDown:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /**
     *  三角形位于视图的上方中间位置
     *
     *  +-----------+
     *  |           |
     *  |           |
     *  |           |
     *  |           |
     *  +--\-----/--+
     *      \   /
     *        .
     */
    
    // 绘制矩形
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);//图形填充颜色
    CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - self.triangleHeight));
    
    
    // 绘制三角形
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor); // 图形填充色
    /**
     * points 的三个元素与三角形的对应关系：
     * points[0] 左角的点
     * points[1] 顶点
     * points[2] 右角
     */
    CGPoint points[3];
    
    points[0] = CGPointMake(self.frame.size.width/2 - self.triangleHeight, self.frame.size.height - self.triangleHeight);
    points[1] = CGPointMake(self.frame.size.width/2, self.frame.size.height);
    points[2] = CGPointMake(self.frame.size.width/2 + self.triangleHeight, self.frame.size.height - self.triangleHeight);
    
    CGContextSetLineWidth(context, 0); // 边框线宽度为0
    CGContextAddLines(context, points, 3); // 绘制边框
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawRectOrientationPortrait:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /**
     *  三角形位于视图的上方中间位置
     *        .
     *      /   \
     *  +--/-----\--+
     *  |           |
     *  |           |
     *  |           |
     *  |           |
     *  +-----------+
     */
    
    // 绘制三角形
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor); // 图形填充色
    /**
     * points 的三个元素与三角形的对应关系：
     * points[0] 左角的点
     * points[1] 顶点
     * points[2] 右角
     */
    CGPoint points[3];
    
    points[0] = CGPointMake(self.frame.size.width/2 - self.triangleHeight, self.triangleHeight);
    points[1] = CGPointMake(self.frame.size.width/2, 0);
    points[2] = CGPointMake(self.frame.size.width/2 + self.triangleHeight, self.triangleHeight);
    CGContextSetLineWidth(context, 0); // 边框线宽度为0
    CGContextAddLines(context, points, 3); // 绘制边框
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    // 绘制矩形
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);//图形填充颜色
    CGContextFillRect(context, CGRectMake(0, self.triangleHeight, self.frame.size.width, self.frame.size.height - self.triangleHeight));
}

@end
