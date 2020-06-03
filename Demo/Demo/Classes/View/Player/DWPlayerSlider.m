//
//  DWPlayerSlider.m
//  Demo
//
//  Created by zwl on 2019/4/15.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWPlayerSlider.h"

@interface DWPlayerSlider ()

@property(nonatomic,strong)DWPlayerSliderBufferView * bufferView;

@end

@implementation DWPlayerSlider

-(instancetype)init
{
    if (self == [super init]) {
        
        self.minimumValue = 0.0f;
        self.maximumValue = 1.0f;
        self.value = 0.0f;

        [self setThumbImage:[UIImage imageNamed:@"icon_play_circle.png"] forState:UIControlStateNormal];

        [self setMinimumTrackImage:[[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1] createImageWithSize:CGSizeMake(10, 3)] forState:UIControlStateNormal];
        [self setMaximumTrackImage:[[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.4] createImageWithSize:CGSizeMake(10, 3)] forState:UIControlStateNormal];

    }
    return self;
}

-(void)setBufferValue:(CGFloat)bufferValue
{
    if (isnan(bufferValue)) {
        bufferValue = 0;
    }
    
    _bufferValue = bufferValue;
    
    if (self.bufferView) {
        [UIView animateWithDuration:0.23 animations:^{
            self.bufferView.frame = CGRectMake(self.bufferView.frame.origin.x, self.bufferView.frame.origin.y, self.frame.size.width * self.bufferValue, self.bufferView.frame.size.height);
        }];
    }
    
    if (self.bufferValue >= 0.995) {
        [self setMaximumTrackImage:[self.bufferView.backgroundColor createImageWithSize:CGSizeMake(10, 3)] forState:UIControlStateNormal];
    }else{
        [self setMaximumTrackImage:[[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.4] createImageWithSize:CGSizeMake(10, 3)] forState:UIControlStateNormal];
    }
}

-(void)resetSubViewFrame
{
    self.bufferView.frame = CGRectMake(self.bufferView.frame.origin.x, self.bufferView.frame.origin.y, self.frame.size.width * self.bufferValue, self.bufferView.frame.size.height);
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.bufferView) {
        self.bufferView = [[DWPlayerSliderBufferView alloc]init];
        self.bufferView.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.8];

        for (UIView * view in self.subviews) {
            if ([view isMemberOfClass:[UIView class]]) {
                self.bufferView.frame = CGRectMake(0, view.frame.origin.y, 0, view.frame.size.height);
                [self insertSubview:self.bufferView atIndex:1];
            }
        }
    
//        for (UIView * view in self.subviews) {
//            if ([view isMemberOfClass:[UIView class]]) {
//                self.bufferView.frame = CGRectMake(0, view.frame.origin.y, 0, view.frame.size.height);
//                [self insertSubview:self.bufferView aboveSubview:view];
//            }
//        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation DWPlayerSliderBufferView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return nil;
}

@end
