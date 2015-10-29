//
//  DemoViewController.m
//  dotc-imagemanager-demo
//
//  Created by Yang G on 15/10/26.
//  Copyright © 2015年 .C . All rights reserved.
//

#import "DemoViewController.h"

#import "DotCImageManager.h"


@interface DemoViewController ()
{
    UILabel*        _lbCacheSize;
    UILabel*        _lbMemorySize;
    bool            _oldNaviBarHidden;
    bool            _refreshing;
}

@end

@implementation DemoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _lbCacheSize  = [(UILabel*)[self.view viewWithTag:1000] retain];
    _lbMemorySize = [(UILabel*)[self.view viewWithTag:1001] retain];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    _oldNaviBarHidden = self.navigationController.navigationBarHidden;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:_oldNaviBarHidden];
    
    _refreshing = false;
    
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    _refreshing = true;
    
    [self refreshStatus];
    
    [super viewWillAppear:animated];
}

- (void) setNavigationBarHidden : (bool) hidden
{
    [self.navigationController setNavigationBarHidden:hidden];
}

- (void) dealloc
{
    [_lbCacheSize release];
    [_lbMemorySize release];
    
    [super dealloc];
}

- (void) refreshStatus
{
    _lbCacheSize.text  = [NSString stringWithFormat:@"%.3f KB", [DOTC_IMAGE_MANAGER getCacheSize]/1024.0f];
    _lbMemorySize.text = [NSString stringWithFormat:@"%.3f KB", [DOTC_IMAGE_MANAGER getLocalCacheSize]/1024.0f];
    
    if(_refreshing)
    {
        [self performSelector:@selector(refreshStatus) withObject:nil afterDelay:0.5];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
