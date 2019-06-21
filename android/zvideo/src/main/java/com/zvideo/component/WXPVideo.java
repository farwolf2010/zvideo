package com.zvideo.component;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.NonNull;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.farwolf.weex.annotation.WeexComponent;
import com.farwolf.weex.util.Const;
import com.farwolf.weex.util.Weex;
import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXComponentProp;
import com.taobao.weex.ui.component.WXVContainer;
import com.zvideo.view.VideoView;

import org.song.videoplayer.PlayListener;

import java.util.HashMap;
import java.util.Timer;
import java.util.TimerTask;

import wbs.hundsun.com.zvideo.R;

//import chuangyuan.ycj.videolibrary.video.VideoPlayerManager;
//import chuangyuan.ycj.videolibrary.widget.VideoPlayerView;

@WeexComponent(name="player")
public class WXPVideo extends  WXVContainer<VideoView>{
    Timer timer;
    boolean compelete;
    String title;
    boolean autoPlay;
    public WXPVideo(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
    }

    @Override
    protected VideoView initComponentHostView(@NonNull Context context) {
//        VideoPlayerView player=new VideoPlayerView(context);
        VideoView qsVideoView=new VideoView(context);
        qsVideoView.instace=this.mInstance;
//        JCVideoPlayer player=new JCVideoPlayer(context,null);
//        VideoPlayerManager.getInstance().getVideoPlayer()
        qsVideoView.setPlayListener(new PlayListener() {
            @Override
            public void onStatus(int status) {

            }

            @Override
            public void onMode(int mode) {
                    if(mode==101){
                        WXPVideo.this.fireEvent("onFullScreen");
                    }
                    else{
                        WXPVideo.this.fireEvent("onNormalScreen");
                    }
            }

            @Override
            public void onEvent(int status, Integer... extra) {
                if(status==11)
                {
                    WXPVideo.this.fireEvent("onPrepared");
                }
                else if(status==12)
                {
                    WXPVideo.this.fireEvent("onStart");
                    statTimer();
                }
                else if(status==13)
                {
                    WXPVideo.this.fireEvent("onPause");
                }
                else   if(status==18){
                    WXPVideo.this.fireEvent("onCompletion");
                    cancelTimer();
                    firePlaying(true);
                }
                else   if(status==20){
                    WXPVideo.this.fireEvent("onSeekComplete");
                }
                else   if(status==16){
                    WXPVideo.this.fireEvent("onError");
                }
            }
        });

        return qsVideoView;
    }

    @WXComponentProp(name = "img")
    public void setImg(String src){
       src= Weex.getRootUrl(src,getInstance());
       if(getHostView()!=null){
           Glide
           .with((Activity)getContext())
           .load(src)
           .into( getHostView().getCoverImageView());
       }

    }



    @WXComponentProp(name = "liveMode")
    public void setLiveMode(boolean live){
        getHostView().liveMode=live;
        if(live)
            getHostView().showChangeViews();

    }



    @WXComponentProp(name = "autoPlay")
    public void setAutoPlay(boolean auto){

        if(auto){
            if(getHostView().getUrl()!=null){
                this.play();
            }
            else{
                autoPlay=auto;
            }
        }
    }

    @WXComponentProp(name = "pos")
    public void setPosition(int position){
        if( getHostView()!=null){
            getHostView().seekTo(position);
        }
//        getHostView().getCurrentState()
    }



    @WXComponentProp(name = "src")
    public void setSrc(String src)
    {
        src= Weex.getRelativeUrl(src,mInstance);
        src=src.replace(Const.PREFIX_SDCARD,"file://");
        getHostView().setUp(src,this.title+"");
        if(autoPlay){
            this.play();
        }
    }

    @JSMethod
    public void seek(int sec){
        getHostView().seekTo(sec);
    }



    @JSMethod
    public void play(){
         getHostView().play();
    }

    @JSMethod
    public void pause(){
        getHostView().pause();
    }

    @WXComponentProp(name = "title")
    public void setTitle(String title)
    {
        this.title=title;
//       getHostView().setUp(getHostView().getUrl(),title);
        TextView t= ((TextView)getHostView().findViewById(R.id.title));
        if(t!=null)
        t.setText(title);
    }

    @JSMethod
    public void fullScreen(){

        getHostView().enterWindowFullscreen();

    }

    @JSMethod
    public void quitFullScreen(){
//        VE_SURFACEHOLDER_FINISH_FULLSCREEN
        getHostView().quitWindowFullscreen();

    }


    Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            if (msg.what == 1){
                //do something
                ((Activity)getContext()).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        firePlaying(false);
                    }
                });

            }
            super.handleMessage(msg);
        }
    };

    public void firePlaying(boolean compelete){
        HashMap m=new HashMap();
        m.put("current",getHostView().getPosition());
        m.put("total",getHostView().getDuration());

        this.compelete=compelete;
        if(this.compelete){
            m.put("percent",1);
            fireEvent("onPlaying",m);
            cancelTimer();
        }else{
            if(getHostView().getDuration()!=0)
                m.put("percent",getHostView().getPosition()/(float)getHostView().getDuration());
            else
                m.put("percent",0);
            fireEvent("onPlaying",m);
        }



    }

    public void cancelTimer(){
       if(timer!=null)
           timer.cancel();
    }

    public void statTimer(){
//        timerTask.scheduledExecutionTime();
        if(timer!=null) {
            timer.cancel();
        }
         timer = new Timer();
        TimerTask timerTask = new TimerTask() {
            @Override
            public void run() {
                Message message = new Message();
                message.what = 1;
                handler.sendMessage(message);
            }
        };
        timer.schedule(timerTask,0,500);
    }






}
