//
//  DWExercisesView.m
//  Demo
//
//  Created by zwl on 2019/6/11.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWExercisesView.h"
#import "DWExercisesQuestionView.h"
#import "DWExercisesFinishView.h"

@interface DWExercisesView () <UIScrollViewDelegate,DWExercisesQuestionViewDelegate,DWExercisesFinishViewDelegate>

@property(nonatomic,strong)DWVideoExercisesModel * exercisesModel;
//当前回答问题，坐标
@property(nonatomic,assign)NSInteger position;
//进度条宽度
@property(nonatomic,assign)CGFloat scheduleWidth;

@property(nonatomic,strong)UIView * bgView;

@property(nonatomic,strong)UIView * topScheduleView;
@property(nonatomic,strong)UIScrollView * scrollView;

//引导页面
@property(nonatomic,strong)UIView * guideView;
@property(nonatomic,strong)UIImageView * guideImageView;

@end

@implementation DWExercisesView

-(instancetype)initWithExercisesModel:(DWVideoExercisesModel *)exercisesModel;
{
    if (self == [super init]) {
        
        self.position = 0;
        
        self.exercisesModel = exercisesModel;
        
        CGSize bgSize = CGSizeMake(MAX(ScreenWidth, ScreenHeight) - 70, MIN(ScreenWidth, ScreenHeight) - 40);
        
        self.scheduleWidth = bgSize.width / self.exercisesModel.questions.count;
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        
        [self addSubview:self.bgView];
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@20);
            make.left.equalTo(@35);
            make.width.equalTo(@(bgSize.width));
            make.height.equalTo(@(bgSize.height));
        }];

        [self.bgView addSubview:self.topScheduleView];
        [_topScheduleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@0);
            make.height.equalTo(@6);
            make.width.equalTo(@(self.scheduleWidth));
        }];
        
        self.scrollView.contentSize = CGSizeMake(bgSize.width * (self.exercisesModel.questions.count + 1), 0);
        [self.bgView addSubview:self.scrollView];
        [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@6);
            make.left.equalTo(@0);
            make.width.equalTo(@(bgSize.width));
            make.height.equalTo(@(bgSize.height - 6));
        }];
        
        for (int i = 0; i < self.exercisesModel.questions.count; i++) {
            DWVideoExercisesQuestionModel * questionModel = [self.exercisesModel.questions objectAtIndex:i];
            DWExercisesQuestionView * questionView = [[DWExercisesQuestionView alloc]initWithQuestionModel:questionModel];
            questionView.delegate = self;
            questionView.tag = 1000 + i;
            [self.scrollView addSubview:questionView];
            [questionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@0);
                make.width.and.height.equalTo(self.scrollView);
                make.left.equalTo(@(bgSize.width * i));
            }];
        }
        
        //引导页面
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"showGuideView"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"showGuideView"];
            [self addSubview:self.guideView];
            [_guideView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            
            [self.guideView addSubview:self.guideImageView];
            [_guideImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.guideView);
                make.width.equalTo(@(646/2));
                make.height.equalTo(@(239/2));
            }];
        }
    }
    return self;
}

//init accuracy UI
-(void)exerciseSsumbitSuccess
{
    DWExercisesFinishView * finishView = [[DWExercisesFinishView alloc]initWithExercisesModel:self.exercisesModel];
    finishView.delegate = self;
    [self.scrollView addSubview:finishView];
    [finishView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.width.and.height.equalTo(self.scrollView);
        make.left.equalTo(@(self.scrollView.frame.size.width * self.exercisesModel.questions.count));
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.scrollView.contentOffset.x == self.scrollView.frame.size.width * (self.exercisesModel.questions.count - 1)) {
            self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * self.exercisesModel.questions.count, 0);
        }
    });
}

#pragma mark - aciton
-(void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.top.and.bottom.equalTo(@0);
    }];
    
    //新增监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChangeNotification) name:UIDeviceOrientationDidChangeNotification object:nil];

}

-(void)dismiss
{
    [self removeFromSuperview];
    
    //移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

}

-(void)guideTapAction
{
    [self.guideView removeFromSuperview];
    self.guideView = nil;
}

-(void)deviceOrientationChangeNotification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        [@"横屏答题体验更加" showAlert];
    }
}

#pragma mark - delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.position == self.exercisesModel.questions.count) {
        return;
    }
    
    CGPoint point = self.scrollView.contentOffset;
    
    DWVideoExercisesQuestionModel * questionModel = [self.exercisesModel.questions objectAtIndex:self.position];
    BOOL isAlreadyAnswer = NO;
    if (questionModel.type == 0) {
        isAlreadyAnswer = questionModel.isReply;
    }else{
        DWExercisesQuestionView * questionView = (DWExercisesQuestionView *)[self.scrollView viewWithTag:1000 + self.position];
        isAlreadyAnswer = questionView.submitButton.hidden;
    }
    
    if (!isAlreadyAnswer && point.x > self.position * self.scrollView.frame.size.width) {
        self.scrollView.contentOffset = CGPointMake(self.position * self.scrollView.frame.size.width, 0);
    }
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ((NSInteger)self.scrollView.contentOffset.x % (NSInteger)self.scrollView.frame.size.width != 0) {
        self.scrollView.contentOffset = CGPointMake(self.position * self.scrollView.frame.size.width, 0);
    }
    self.position = (NSInteger)(self.scrollView.contentOffset.x / CGRectGetWidth(self.bgView.frame));

    if (self.position <= self.exercisesModel.questions.count - 1) {
        [_topScheduleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(self.scheduleWidth * (self.position + 1)));
        }];
    }
    
    [UIView animateWithDuration:0.33 animations:^{
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }];
}

//DWExercisesQuestionViewDelegate
-(void)exercisesQuestionViewDidSubmit:(DWExercisesQuestionView *)questionView
{
    //1000 + i
    if (questionView.tag - 1000 == self.exercisesModel.questions.count - 1) {
        //课堂练习完成，回调，提交课堂练习
        if ([_delegate respondsToSelector:@selector(exercisesViewFinish:)]) {
            [_delegate exercisesViewFinish:self.exercisesModel];
        }
    }
}

//DWExercisesFinishViewDelegate
-(void)exercisesFinishViewResumePlay
{
    if ([_delegate respondsToSelector:@selector(exercisesViewFinishResumePlay:)]) {
        [_delegate exercisesViewFinishResumePlay:self.exercisesModel];
    }
}

#pragma mark - lazyLoad
-(UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.masksToBounds = YES;
        _bgView.layer.cornerRadius = 5;
    }
    return _bgView;
}

-(UIView *)topScheduleView
{
    if (!_topScheduleView) {
        _topScheduleView = [[UIView alloc]init];
        _topScheduleView.backgroundColor = [UIColor colorWithRed:81/255.0 green:168/255.0 blue:242/255.0 alpha:1.0];
    }
    return _topScheduleView;
}

-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

-(UIView *)guideView
{
    if (!_guideView) {
        _guideView = [[UIView alloc]init];
        _guideView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        UITapGestureRecognizer * guideTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(guideTapAction)];
        [_guideView addGestureRecognizer:guideTap];
    }
    return _guideView;
}

-(UIImageView *)guideImageView
{
    if (!_guideImageView) {
        _guideImageView = [[UIImageView alloc]init];
        _guideImageView.image = [UIImage imageNamed:@"icon_exercises_guide.png"];
        _guideImageView.userInteractionEnabled = YES;
    }
    return _guideImageView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
