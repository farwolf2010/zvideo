//
//  WXPlayerControl.m
//  AFNetworking
//
//  Created by 郑江荣 on 2019/6/22.
//

#import "WXPlayerControl.h"

@interface WXPlayerControl ()

@end

@implementation WXPlayerControl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)viewDidDisappear:(BOOL)animated{
    [self.player pause];
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
