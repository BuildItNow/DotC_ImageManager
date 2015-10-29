//
//  ViewController.m
//  dotc-imagemanager-demo
//
//  Created by Yang G on 15/10/10.
//  Copyright © 2015年 .C . All rights reserved.
//

#import "ViewController.h"

#import "DotCImageView.h"
#import "DotCImageManager.h"
#import "ImageViewController.h"
#import "AutoCollectViewController.h"
#import "AutoMatchViewController.h"

@interface ViewController ()


@end


@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [self setNavigationBarHidden:true];
    
    [super viewWillAppear:animated];
}

- (IBAction)onOneImageDemo:(id)sender
{
    UIViewController* viewController = [[[ImageViewController alloc] init] autorelease];
    [self.navigationController pushViewController:viewController animated:true];
}

- (IBAction)onAutoCollect:(id)sender
{
    UIViewController* viewController = [[[AutoCollectViewController alloc] init] autorelease];
    [self.navigationController pushViewController:viewController animated:true];
}

- (IBAction)onAutoMatch:(id)sender
{
    UIViewController* viewController = [[[AutoMatchViewController alloc] init] autorelease];
    [self.navigationController pushViewController:viewController animated:true];
}

- (IBAction)onClearCache:(UIButton *)sender
{
    [DOTC_IMAGE_MANAGER clearCache:0.0f];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [super dealloc];
}
@end
