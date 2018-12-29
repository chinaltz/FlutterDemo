import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(new MyApp());

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

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
 
        primarySwatch: Colors.blue,
      ),
      home:  _widgetForRoute(window.defaultRouteName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
 

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  //获取到插件与原生的交互通道
  static const toAndroidPlugin = const MethodChannel('com.litngzhe.toandroid/plugin');

  static const fromAndroiPlugin = const EventChannel('com.litngzhe.toflutter/plugin');


  StreamSubscription _fromAndroiSub;

 

  var _nativeParams;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startfromAndroiPlugin();
  }

  void _incrementCounter() {
    setState(() {
 
      _counter++;


    });

  }



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

  // void _endCounterPlugin(){
  //   if(_fromAndroiSub != null){
  //     _fromAndroiSub.cancel();
  //   }
  // }


  Future<Null> _jumpToNative() async {
    String result = await toAndroidPlugin.invokeMethod('withoutParams');

    print(result);
  }


  Future<Null> _jumpToNativeWithParams() async {

    Map<String, String> map = { "flutter": "这是一条来自flutter的参数" };

    String result = await toAndroidPlugin.invokeMethod('withParams', map);

    print(result);
  }

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body:  Center(
          child: new ListView(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                child: new RaisedButton(
                    textColor: Colors.black,
                    child: new Text('跳转到原生界面'),
                    onPressed: () {
                      _jumpToNative();
                    }),
              ),
              new Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, top: 10.0, right: 10.0),
                child: new RaisedButton(
                    textColor: Colors.black,
                    child: new Text('跳转到原生界面(带参数)'),
                    onPressed: () {
                      _jumpToNativeWithParams();
                    }),
              ),
              
              new Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, top: 10.0, right: 10.0),
                child: new Text('这是一个从原生获取的参数：$_nativeParams'),
              ) 
              , new Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, top: 10.0, right: 10.0),
                child: new Text('Flutter floatingActionButton 点击次数$_counter'),
              ) 

            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
