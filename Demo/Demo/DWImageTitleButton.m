#import "DWImageTitleButton.h"

@implementation DWImageTitleButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)imageUp:(float)spacing
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    self.imageEdgeInsets = UIEdgeInsetsMake(
                                            - (totalHeight - imageSize.height),
                                            0.0,
                                            0.0,
                                            - titleSize.width);
    
    self.titleEdgeInsets = UIEdgeInsetsMake(
                                            0.0,
                                            - imageSize.width,
                                            - (totalHeight - titleSize.height),
                                            0.0);
}

@end
