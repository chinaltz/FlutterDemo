package com.litingzhe.nativiteapp;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

import io.flutter.facade.Flutter;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterView;

/**
 * @author: Administrator
 * @date: 2018/12/29   14:11
 * @description:
 */
public class NativeActivity extends AppCompatActivity {

    private TextView textView;

    private FrameLayout frameLayout;
    private FlutterView flutterView;

    public static final String FlutterToAndroidCHANNEL  = "com.litngzhe.toandroid/plugin";
    public static final String  AndroidToFlutterCHANNEL= "com.litngzhe.toflutter/plugin";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_native);

        textView = findViewById(R.id.params);

        frameLayout = findViewById(R.id.rl_flutter);


        flutterView = Flutter.createView(this, getLifecycle(), "route2");
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
        frameLayout.addView(flutterView, layoutParams);
        String params = getIntent().getStringExtra("test");
        if (!TextUtils.isEmpty(params)) {
            Toast.makeText(this, "" + params, Toast.LENGTH_SHORT).show();

            textView.setText("flutter 传参:" + params);

        }

        new EventChannel(flutterView, AndroidToFlutterCHANNEL)
                .setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object o, EventChannel.EventSink eventSink) {
                        String androidParmas = "来自android原生的参数";
                        eventSink.success(androidParmas);
                    }

                    @Override
                    public void onCancel(Object o) {

                    }
                });


        new MethodChannel(flutterView, FlutterToAndroidCHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

                //接收来自flutter的指令oneAct
                if (methodCall.method.equals("withoutParams")) {

                    //跳转到指定Activity
                    Intent intent = new Intent(NativeActivity.this, NativeActivity.class);
                    startActivity(intent);

                    //返回给flutter的参数
                    result.success("success");
                }
                //接收来自flutter的指令twoAct
                else if (methodCall.method.equals("withParams")) {

                    //解析参数
                    String text = methodCall.argument("flutter");

                    //带参数跳转到指定Activity
                    Intent intent = new Intent(NativeActivity.this, NativeActivity.class);
                    intent.putExtra("test", text);
                    startActivity(intent);

                    //返回给flutter的参数
                    result.success("success");
                } else {
                    result.notImplemented();
                }
            }
        });

    }
}
