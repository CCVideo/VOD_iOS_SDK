//
//  DWBaseViewController.m
//  Demo
//
//  Created by zwl on 2019/4/11.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWBaseViewController.h"

@interface DWBaseViewController ()

@end

@implementation DWBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initReturnButton];
}

-(void)returnButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - init
-(void)initReturnButton
{
    UIButton * returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    returnButton.frame = CGRectMake(0, 0, 40, 40);
    [returnButton setImage:[UIImage imageNamed:@"icon_return_black.png"] forState:UIControlStateNormal];
    [returnButton addTarget:self action:@selector(returnButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * returnItem = [[UIBarButtonItem alloc]initWithCustomView:returnButton];
    self.navigationItem.leftBarButtonItem = returnItem;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
