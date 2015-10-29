//
//  AutoCollectViewController.m
//  dotc-imagemanager-demo
//
//  Created by Yang G on 15/10/26.
//  Copyright © 2015年 .C . All rights reserved.
//

#import "AutoCollectViewController.h"
#import "DotCImageView.h"
#import "DotCImageManagerAdapter.h"
#import "DotCImageManager.h"

@interface AutoCollectViewController ()
{
    NSArray*               _imageNames;
    NSMutableArray*        _imageViews;
    int                    _curImage;
    bool                   _appearing;
}
@property (retain, nonatomic) IBOutlet UITextField *tfMaxSize;

@end

@implementation AutoCollectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _imageNames = [@[@"t0.jpg", @"t1.jpg", @"t2.jpg", @"t3.jpg", @"d0.jpg", @"d1.jpg"] retain];
    int i = 1;
    int n = 12;
    _imageViews = [[NSMutableArray arrayWithCapacity:n] retain];
    for(; i<=n; ++i)
    {
        _imageViews[i-1] = [self.view viewWithTag:i];
    }
    
    _tfMaxSize.text = [NSString stringWithFormat:@"%.3f", [[DotCImageManagerAdapter instance] getMaxMemoryCacheSize]/1024.0f];
    
    _curImage = 0;
}

- (void) viewDidAppear:(BOOL)animated
{
    _appearing = true;
    
    [self loadImage];
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    _appearing = false;
    [super viewDidDisappear:animated];
}

- (IBAction)onSetMaxSize:(id)sender
{
    const char* pszSize = [_tfMaxSize.text cString];
    if(pszSize)
    {
        [[DotCImageManagerAdapter instance] setMaxMemoryCacheSize:(int)(atof(pszSize)*1024)];
        [DOTC_IMAGE_MANAGER clearLocalCache];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadImage
{
    NSString* imageName = _imageNames[(rand()%(_imageNames.count))];
    [_imageViews[_curImage] load:imageName];
    
    ++_curImage;
    _curImage %= (_imageViews.count);
    
    if(_appearing)
    {
        [self performSelector:@selector(loadImage) withObject:nil afterDelay:3];
    }
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
    [_tfMaxSize release];
    [_imageNames release];
    [_imageViews release];
    
    [super dealloc];
}
@end
