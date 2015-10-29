//
//  AutoMatchViewController.m
//  dotc-imagemanager-demo
//
//  Created by Yang G on 15/10/29.
//  Copyright © 2015年 .C . All rights reserved.
//

#import "AutoMatchViewController.h"
#import "DotCImageView.h"

@interface AutoMatchViewController ()

@property (retain, nonatomic) IBOutlet DotCImageView *imgImage0;
@property (retain, nonatomic) IBOutlet DotCImageView *imgImage1;
@property (retain, nonatomic) IBOutlet DotCImageView *imgImage2;

@end

@implementation AutoMatchViewController

- (IBAction)onLoad128_128:(id)sender
{
    [_imgImage0 load:@"test" width:128 height:128];
}

- (IBAction)onLoad64_64:(id)sender
{
    [_imgImage1 load:@"test" width:64 height:64];
}

- (IBAction)onLoad256_256:(id)sender
{
    [_imgImage2 load:@"test" width:256 height:256];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (void)dealloc {
    [_imgImage0 release];
    [_imgImage1 release];
    [_imgImage2 release];
    [super dealloc];
}
@end
