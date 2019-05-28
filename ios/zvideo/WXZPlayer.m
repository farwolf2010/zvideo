//
//  WXPlayer.m
//  AFNetworking
//
//  Created by 郑江荣 on 2019/1/12.
//

#import "WXZPlayer.h"
#import <WeexPluginLoader/WeexPluginLoader.h>
#import <Masonry/Masonry.h>
#import "SPVideoPlayerView.h"
#import "SPVideoPlayerControlView.h"
#import "farwolf.h"
#import "Weex.h"

@implementation WXZPlayer
@synthesize weexInstance;
WX_PlUGIN_EXPORT_COMPONENT(player, WXZPlayer)
WX_EXPORT_METHOD(@selector(play))
WX_EXPORT_METHOD(@selector(pause))
WX_EXPORT_METHOD(@selector(seek:))
WX_EXPORT_METHOD(@selector(toggleFullScreen))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
  
   if( self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance])
   {
       self.weexInstance=weexInstance;
       _src = attributes[@"src"];
       _title = attributes[@"title"];
        _img = attributes[@"img"];
       _autoPlay = [attributes[@"autoPlay"] boolValue];
       if(attributes[@"pos"])
        _position = [attributes[@"pos"] longLongValue]/1000;
       else{
           _position=0;
       }
   }
    return self;
}
-(UIView*)loadView{
    UIView *v=[UIView new];
    v.backgroundColor=[UIColor blackColor];
  
//    [v addSubview:video];
//    [video mas_makeConstraints:^(MASConstraintMaker *make) {
//         make.left.mas_equalTo(v);
//         make.right.mas_equalTo(v);
//         make.bottom.mas_equalTo(v);
//         make.top.mas_equalTo(v);
//    }];
    return v;
}
- (SPVideoItem *)videoItem {
    SPVideoItem *_videoItem=[SPVideoItem new];
   
        _videoItem                  = [[SPVideoItem alloc] init];
          _videoItem.title            = self.title;
        _videoItem.videoURL         = [self getUrl:self.src];
        _videoItem.placeholderImage = [UIImage imageNamed:@"qyplayer_aura2_background_normal_iphone_375x211_"];
        // playerView的父视图
        _videoItem.seekTime=_position;    
        _videoItem.fatherView       = self.view;
    
    return _videoItem;
}


- (void)updateAttributes:(NSDictionary *)attributes{
    _src = attributes[@"src"];
    _title = attributes[@"title"];
      _img = attributes[@"img"];
    _autoPlay = [attributes[@"autoPlay"] boolValue];
    if(attributes[@"pos"])
        _position = [attributes[@"pos"] longLongValue]/1000;
    else{
        _position=0;
    }
    if(_src!=nil||_title!=nil){
        [_video removeFromSuperview];
        SPVideoPlayerView *video=[[SPVideoPlayerView alloc]init];
        _video=video;
        
        _video.requirePreviewView = NO;
        SPVideoPlayerControlView *c=_video.controlView;
    
//        setImageSource
        video.backgroundColor=[UIColor blackColor];
        self.videoItem.seekTime=_position;
        self.videoItem.videoURL= [self getUrl:self.src];
        [video configureControlView:nil videoItem:self.videoItem];
        if(_autoPlay){
            [video startPlay];
        }
    }
    
}

-(NSURL*)getUrl:(NSString*)src{
    if([src startWith:@"http"]){
        return [NSURL URLWithString:src];
    }
    if([src startWith:PREFIX_SDCARD]){
        src=[src replace:PREFIX_SDCARD withString:@""];
          return [NSURL fileURLWithPath:src];
    }
    NSURL *ul= [Weex getFinalUrl:src weexInstance:self.weexInstance];
    return ul;
    
}

-(void)dealloc{

}

-(void)viewDidLoad{
    [super viewDidLoad];
    SPVideoPlayerView *video=[[SPVideoPlayerView alloc]init];
    _video=video;
     _video.requirePreviewView = NO;
    video.backgroundColor=[UIColor blackColor];
    [video configureControlView:nil videoItem:self.videoItem];
   
    if(_autoPlay){
          [video startPlay];
    }
    SPVideoPlayerControlView *control=video.controlView;
    [self regist:@"onPlayTimer" method:@selector(onPlayTimer:)];
    [self fireEvent:@"didload" params:nil];
//    control.playDelegate=self;
    SPVideoPlayerControlView *c=_video.controlView;
    [c setImg:_img weexIntance:self.weexInstance];
    UIImageView *placeholder=[UIImageView new];
    _placeholder=placeholder;
//    [self.view addSubview:placeholder];
    [video addSubviewFull:placeholder];
    [placeholder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    for(UIView *v in video.subviews){
        if(v!=_placeholder){
            [video bringSubviewToFront:v];
        }
    }
   
    NSURL  *ul=[Weex getFinalUrl:_img weexInstance:self.weexInstance];
    [Weex setImageSource:ul.absoluteString compelete:^(UIImage *img) {
        placeholder.image=img;
    }];
     _placeholder.hidden=false;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayerStateChanged:) name:SPVideoPlayerStateChangedNSNotification object:nil];

}


-(void)onPlayTimer:(NSNotification*)notify{
     self.weexInstance;
      [self fireEvent:@"onPlaying" params:notify.userInfo];
}

/** 播放状态发生了改变 */
- (void)videoPlayerStateChanged:(NSNotification *)notification {
    
    SPVideoPlayerPlayState state = [notification.userInfo[@"playState"] integerValue];
    // 上次停止播放的时间点(单位:s)
    CGFloat seekTime = [notification.userInfo[@"seekTime"] floatValue];
    // 转化为分钟
    double minutesElapsed = floorf(fmod(seekTime, 60.0*60.0)/60.0) ;
    switch (state) {
        case SPVideoPlayerPlayStateReadyToPlay:    // 准备播放
            [self onPrepare];
            break;
        case SPVideoPlayerPlayStatePlaying:        // 正在播放
        {
            [self onStart];
            _placeholder.hidden=true;
        }
            break;
        case SPVideoPlayerPlayStatePause:          // 暂停播放
             [self onPause];
            break;
        case SPVideoPlayerPlayStateBuffering:      // 缓冲中
            
            break;
        case SPVideoPlayerPlayStateBufferSuccessed: // 缓冲成功
           
            break;
        case SPVideoPlayerPlayStateEndedPlay:      // 播放结束
        {
              _placeholder.hidden=false;
             [self onCompelete];
            
        }
            break;
        default:
            break;
    }
}


-(void)play{
    if(_video.playState==SPVideoPlayerPlayStatePlaying){
        return;
    }
    if(_video.playState==SPVideoPlayerPlayStateEndedPlay){
        [_video sp_controlViewRefreshButtonClicked:nil];
        SPVideoPlayerControlView *control= _video.controlView;
        [control repeatButtonnAction:nil];
    
//        [self sp_playerResetControlView];
//        [self sp_playerShowControlView];
    }
    else if(_video.playState==SPVideoPlayerPlayStatePause){
        [_video play];
    }else{
        [_video startPlay];
    }
    
    
   
}
-(void)pause{
   [_video pause];
}
-(void)toggleFullScreen{
    [_video toggleFullScreen];
}


-(void)seek:(double)time{
   
    [_video seekToTime:time/1000 completionHandler:^(BOOL finished) {
        
    }];
}

/**  */
- (void)onPrepare{
    [self fireEvent:@"onPrepared" params:nil];
}
/**  */
- (void)onStart{
      [self fireEvent:@"onStart" params:nil];
}
/** 播放中 */
- (void)onPlaying{
      [self fireEvent:@"onPlaying" params:nil];
}
/** 暂停 */
- (void)onPause{
      [self fireEvent:@"onPause" params:nil];
}

/** 完成 */
- (void)onCompelete{
      [self fireEvent:@"onCompletion" params:nil];
}

@end
