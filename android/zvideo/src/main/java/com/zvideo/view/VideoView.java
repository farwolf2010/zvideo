package com.zvideo.view;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.View;
import android.view.ViewGroup;

import com.farwolf.weex.activity.WeexActivity;
import com.taobao.weex.WXSDKInstance;

import org.song.videoplayer.DemoQSVideoView;
import org.song.videoplayer.Util;

import wbs.hundsun.com.zvideo.R;

public class VideoView extends DemoQSVideoView {

    public WXSDKInstance instace;

    public VideoView(Context context) {
        super(context);
    }

    public boolean liveMode=false;

    //移动网络提示框
    @Override
    protected boolean showWifiDialog() {
        if (!isShowWifiDialog)
            return false;
        AlertDialog.Builder builder = new AlertDialog.Builder(instace.getContext());
        builder.setMessage(getResources().getString(R.string.tips_not_wifi));
        builder.setPositiveButton(getResources().getString(R.string.tips_not_wifi_confirm), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                prepareMediaPlayer();
            }
        });
        builder.setNegativeButton(getResources().getString(R.string.tips_not_wifi_cancel), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });
        builder.create().show();
        return true;
    }

    @Override
    public void showChangeViews(View... views) {
//        super.showChangeViews(views);
        if(liveMode){
            for (View v : changeViews)
                if (v != null)
                    v.setVisibility(INVISIBLE);
        }else{
            super.showChangeViews(views);
        }

    }

    //全屏
    @Override
    public void enterWindowFullscreen() {
//        WeexActivity ac=  (WeexActivity)instace.getContext();
//        boolean ispotrait=ac.getIntent().getBooleanExtra("isPortrait",true);
        if (currentMode == MODE_WINDOW_NORMAL) {
            super.enterWindowFullscreen();
            Util.SET_LANDSCAPE(instace.getContext());
            ViewGroup vp = (ViewGroup) videoView.getParent();
            if (vp != null)
                vp.removeView(videoView);
            ViewGroup decorView = (ViewGroup) (Util.scanForActivity(instace.getContext())).getWindow().getDecorView();
            decorView.addView(videoView, new LayoutParams(-1, -1));

        }
    }


    @Override
    public void quitWindowFullscreen() {
        super.quitWindowFullscreen();
        WeexActivity ac=  (WeexActivity)instace.getContext();
        boolean ispotrait=ac.getIntent().getBooleanExtra("isPortrait",true);
        if(ispotrait){
            Util.SET_PORTRAIT(ac);
        }else{
            Util.SET_LANDSCAPE(ac);
        }

    }
}
