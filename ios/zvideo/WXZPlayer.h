//
//  WXPlayer.h
//  AFNetworking
//
//  Created by 郑江荣 on 2019/1/12.
//

#import "WXComponent.h"
#import "SPVideoPlayerView.h"
#import <WeexSDK/WXEventModuleProtocol.h>
#import <WeexSDK/WXModuleProtocol.h>
#import "PlayDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXZPlayer : WXComponent<WXModuleProtocol,SPVideoPlayerDelegate,PlayDelegate>
//@property(strong,nonatomic) MCPlayerKit *playerKit;
@property(strong,nonatomic) NSString *src;
@property(strong,nonatomic) NSString *title;
@property(strong,nonatomic) NSString *img;
@property(nonatomic) NSInteger *position;
@property(strong,nonatomic)  SPVideoPlayerView *video;
@property(strong,nonatomic)  UIImageView *placeholder;
@property(nonatomic) BOOL autoPlay;
@property(nonatomic) BOOL liveMode;
-(void)pause;

@end

NS_ASSUME_NONNULL_END
