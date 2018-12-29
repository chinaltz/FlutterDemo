## 前言
---
Flutter 支持作为 android Moudle 出现在项目中.这样就可以在 已有的项目中 使用.
虽然现在Flutter 比较受关注,但是和weex 一样 ,大部分都只是在观望 不是真正的进行使用.所以 如果用还是混合开发 原生+Flutter 方式比较合适(自我感觉).
写一个demo 进行Android及Flutter 交互.(IOS 方法基本一致). 

Flutter 调用 android 硬件的插件还比较匮乏 比如 各种传感器, 自定义相机 所以就会用到 Flutter 调用android 及android 原生调用 Flutter的方法. 

### 本例子中会实现.
##### (1) 原有的android 应用程序嵌入 FlutterView
##### (2) Flutter 代码调用Android 原生方法进行页面跳转及传值
##### (3) Android原生 调用 Flutter 方法 进行传值

步骤
新建一个  android 项目

然后在 同级目录创建一个Flutter Moudle

![图片.png](https://upload-images.jianshu.io/upload_images/2595860-98a641a7494e548e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

然后 导入 Flutter Moudle
 ![Flutter Moudle](https://upload-images.jianshu.io/upload_images/2595860-da32a85bd1aded10.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

Moudle 导入成功后 项目结构
![项目结构](https://upload-images.jianshu.io/upload_images/2595860-c473c184e180ad31.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

app 目录下的 
build.gradle 中 新增了
```
    implementation project(':flutter')
```

项目目录下的 
settings.gradle 增加
```
setBinding(new Binding([gradle: this]))
evaluate(new File(
  settingsDir.parentFile,
  'flutter_test_module\\.android\\include_flutter.groovy'
))

基础框架就搭建成功了
```
 Demo 实现
![实现效果](https://upload-images.jianshu.io/upload_images/2595860-6d52c7ec40e2f540.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/320)

最上层放置了一个 Android原生 TextView  下方使用的FlutterView

```
        flutterView = Flutter.createView(this, getLifecycle(), "route2");
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
        frameLayout.addView(flutterView, layoutParams);
```

其中  flutterView = Flutter.createView(this, getLifecycle(), "route2");  route2  与flutter_test_module  lib 文件夹下 main.dart 中 所对应 希望加载 哪个页面 就填写相应的 route 名称.
```
Widget _widgetForRoute(String route) {
  switch (route) {
    case 'route1':
      return  MyHomePage(title: 'Flutter Demo Home Page1');
    case 'route2':
      return  MyHomePage(title: 'Flutter Demo Home Page2');
    default:
        return  MyHomePage(title: 'Flutter Demo Home Page2');
  
  }
}
```
Flutter 调用Android

java
```
        new MethodChannel(flutterView, FlutterToAndroidCHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

                //接收来自flutter的指令withoutParams
                if (methodCall.method.equals("withoutParams")) {

                    //跳转到指定Activity
                    Intent intent = new Intent(NativeActivity.this, NativeActivity.class);
                    startActivity(intent);

                    //返回给flutter的参数
                    result.success("success");
                }
                //接收来自flutter的指令withParams
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
```

dart
```

  Future<Null> _jumpToNative() async {
    String result = await toAndroidPlugin.invokeMethod('withoutParams');

    print(result);
  }


  Future<Null> _jumpToNativeWithParams() async {

    Map<String, String> map = { "flutter": "这是一条来自flutter的参数" };

    String result = await toAndroidPlugin.invokeMethod('withParams', map);

    print(result);
  }
```

Android 向 Flutter 传参

java 
```
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

```
dart
```

  void _startfromAndroiPlugin(){
    if(_fromAndroiSub == null){
      _fromAndroiSub =  fromAndroiPlugin.receiveBroadcastStream()
      .listen(_onfromAndroiEvent,onError: _onfromAndroiError);
    }
  }


void _onfromAndroiEvent(Object event) {
    setState(() {
      _nativeParams = event;
    });
  }

  void _onfromAndroiError(Object error) {
    setState(() {
      _nativeParams = "error";
      print(error);
    });
  }

```
有几处 要注意一一对应
  new EventChannel(flutterView, AndroidToFlutterCHANNEL)
```
        new MethodChannel(flutterView, FlutterToAndroidCHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

                //接收来自flutter的指令withoutParams
                if (methodCall.method.equals("withoutParams")) {

                    //跳转到指定Activity
                    Intent intent = new Intent(NativeActivity.this, NativeActivity.class);
                    startActivity(intent);

                    //返回给flutter的参数
                    result.success("success");
                }
                //接收来自flutter的指令withParams
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

```

dart

```

  Future<Null> _jumpToNative() async {
    String result = await toAndroidPlugin.invokeMethod('withoutParams');

    print(result);
  }

  Future<Null> _jumpToNativeWithParams() async {

    Map<String, String> map = { "flutter": "这是一条来自flutter的参数" };

    String result = await toAndroidPlugin.invokeMethod('withParams', map);

    print(result);
  }

```

Android 向 Flutter 传参

java

```
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

```

dart

```

  void _startfromAndroiPlugin(){
    if(_fromAndroiSub == null){
      _fromAndroiSub =  fromAndroiPlugin.receiveBroadcastStream()
      .listen(_onfromAndroiEvent,onError: _onfromAndroiError);
    }
  }

void _onfromAndroiEvent(Object event) {
    setState(() {
      _nativeParams = event;
    });
  }

  void _onfromAndroiError(Object error) {
    setState(() {
      _nativeParams = "error";
      print(error);
    });
  }

```

有几处 要注意一一对应
    public static final String FlutterToAndroidCHANNEL  = "com.litngzhe.toandroid/plugin";
    public static final String  AndroidToFlutterCHANNEL= "com.litngzhe.toflutter/plugin";

new EventChannel(flutterView, AndroidToFlutterCHANNEL)
    new MethodChannel(flutterView, FlutterToAndroidCHANNEL)

dart中
//获取到插件与原生的交互通道
  static const toAndroidPlugin = const MethodChannel('com.litngzhe.toandroid/plugin');

  static const fromAndroiPlugin = const EventChannel('com.litngzhe.toflutter/plugin');
MethodChannel 中 涉及到的方法名要要统一



Flutter 布局及路由导航
可以看 胖哥视频
[http://jspang.com/post/flutter4.html](http://jspang.com/post/flutter4.html)

本文中 知识点 从下方文章学习
https://www.jianshu.com/p/c5263a3d7aac
 

 

