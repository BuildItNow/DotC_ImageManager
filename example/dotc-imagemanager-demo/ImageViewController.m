//
//  ImageViewController.m
//  dotc-imagemanager-demo
//
//  Created by Yang G on 15/10/26.
//  Copyright © 2015年 .C . All rights reserved.
//

#import "ImageViewController.h"
#import "DotCImageView.h"

@interface ImageViewController ()
@property (retain, nonatomic) IBOutlet DotCImageView *img0;
@property (retain, nonatomic) IBOutlet DotCImageView *img1;
@property (retain, nonatomic) IBOutlet DotCImageView *img2;
@property (retain, nonatomic) IBOutlet DotCImageView *img3;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_img0 load:@"t0.jpg"];
    [_img1 load:@"t0.jpg"];
    [_img2 load:@"t0.jpg"];
    [_img3 load:@"t0.jpg"];
    
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
    [_img0 release];
    [_img1 release];
    [_img2 release];
    [_img3 release];
    [super dealloc];
}
@end
