import 'dart:async';
import 'dart:io';
import 'package:agfsportalflutter/src/models/LoginFlags.dart';
import 'package:agfsportalflutter/src/ui/SettingsPage.dart';
import 'package:agfsportalflutter/src/utils/StorageUtil.dart';
import 'package:agfsportalflutter/src/utils/app_config.dart';
import 'package:agfsportalflutter/src/widget/color_loader_wavey.dart';
import 'package:agfsportalflutter/src/utils/constant.dart';
import 'package:agfsportalflutter/src/widget/dot_type.dart';
import 'package:check_vpn_connection/check_vpn_connection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:root_check/root_check.dart';
import 'package:trust_fall/trust_fall.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'LoginPage.dart';
import 'PinPage.dart';
import 'package:platform/platform.dart';
import 'package:flutter_forbidshot/flutter_forbidshot.dart';



class WebViewHolder extends StatefulWidget {

  final String token;//if you have multiple values add here
  WebViewHolder(this.token, {Key key}): super(key: key);

  @override
  _WebViewHolderState createState() => _WebViewHolderState();
}

class _WebViewHolderState extends State<WebViewHolder> {

  WebViewController controller;
  bool isJailBroken = false;
  bool isRooted = false;
  String alertText = "";
  bool isCaptured = false;
  StreamSubscription<void> subscription;
  final Completer<WebViewController> _controllerCompleter =
  Completer<WebViewController>();

  Future<void> _onWillPop(BuildContext context) async {

//    if (await controller.canGoBack()) {
//      controller.goBack();
//    } else {
//      showExitAlert(context);
//      return Future.value(false);
//    }

    showExitAlert(context);
    return Future.value(false);

  }

  showExitAlert(BuildContext context) {

    var config = AppConfig.of(context);
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("No"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Yes"),
      onPressed:  () {

        Navigator.of(context).pop();
        SystemNavigator.pop();

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(config.appName),
      content: Text("Are you sure you want to close the application ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  bool isShowingAlert=false;

  showAlertDialog(BuildContext context) {

    isShowingAlert=true;
    Widget continueButton = FlatButton(
      child: Text("Try again"),
      onPressed:  () {

        clearPinValue();
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => LoginPage(new LoginFlag(pin:'',showPin:false,showLoginContainer:true,showFinger:false))));

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Authentication Error"),
      content: Text("Invalid Username or Password."),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  clearPinValue() {
    StorageUtil prefs =  StorageUtil();
    prefs.setValue(PIN,null);
    prefs.setValue(SET_PIN_VAL,null);
    prefs.setValue(SET_FINGER_VAL,null);
    prefs.setValue(USERNAME,null);
  }

  @override
  void initState() {
    initDetection();
    disableCapture();
    super.initState();
  }


  Future<void>  initDetection() async {

    try{

      isJailBroken = await TrustFall.isJailBroken;
      isRooted = await RootCheck.isRooted;
      setState(() {
        isJailBroken = isJailBroken;
        isRooted = isRooted;
      });

        if(Platform.android != null ){
          if(isRooted){
            print("isRooted : Yes");
            alertText = "This application not works on JailBroken Device.";
            _showDialog(alertText);
          }else{
            print("isRooted : No");
          }
          subscription = await FlutterForbidshot.setAndroidForbidOff();
        }else if (Platform.iOS != null){
          if(isJailBroken){
            print("isJailBroken : Yes");
            alertText = "This application not works on Rooted Device.";
            _showDialog(alertText);
          }else{
            print("isjailBroken : No");
          }
          bool isCapture = await FlutterForbidshot.iosIsCaptured;
          setState(() {
            isCaptured = isCapture;
          });
          subscription = FlutterForbidshot.iosShotChange.listen((event) {
            setState(() {
              isCaptured = !isCaptured;
            });
          });
        }
      if (await CheckVpnConnection.isVpnActive()) {
        print("VPN : ON");
        alertText = "The network your are connected to has been temporarily blocked because of suspicious activity. If you are connected to VPN, retry after disconnecting from it.";
        _showDialog(alertText);
      }else{
        print("VPN : OFF");
      }

    }catch(error){
      print(error);
    }

  }


  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
    print(subscription);
  }


  Future<void> disableCapture() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  void _showDialog(String alertText) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Oops!"),
          content: new Text(alertText),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Okay"),
              onPressed: () {
                Navigator.of(context).pop();
                exit(0);
              },
            ),
          ],
        );
      },
    );
  }

  num position = 1 ;
  bool showRefresh=false;

  void showWebPage(){

    // flag to hide progress and show web page
    setState(() {
      position = 0;
      showRefresh=true;
    });

  }


  @override
  Widget build(BuildContext context) {

    var config = AppConfig.of(context);

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        body: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: config.myColor,
            title: Text(config.appName,
              style: TextStyle( fontWeight: FontWeight.normal, fontSize:  MediaQuery.of(context).size.height* 0.020,fontFamily: 'Poppins-Medium',color: Colors.white),),

            actions: <Widget>[

              showRefresh? IconButton(
                icon: Icon(
                  Icons.replay,
                  color: Colors.white,
                ),
                onPressed: () {
                  controller.reload();
                },
              ) : new Container(),

              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => SettingsPage()));
                },
              )
            ],
          ),

          body: IndexedStack(
              index: position,
              children: <Widget>[
                WebView(
                  initialUrl:config.loginUrl+widget.token,
                  javascriptMode: JavascriptMode.unrestricted,
                  onPageFinished: (finish) {
                    Timer(Duration(seconds: 2), () =>
                        {
                            controller.currentUrl().then((url) {
                              // check for invalid credential url
                              if(url==config.loginFalseUrl){
                                if(!isShowingAlert){
                                   showWebPage();
                                  showAlertDialog(context);
                                }
                              }
                              else {
                               // checking for PIN set
                                StorageUtil prefs =  StorageUtil();
                                Future<String> authToken = prefs.getValue(PIN);
                                authToken.then((data) {

                                  if(data.toString()==null || data.toString()=='' || data.toString()=='null'){
                                    Navigator.pushReplacement(
                                        context, MaterialPageRoute(builder: (context) => PinPage(SET_PIN)));
                                  }
                                  else{
                                    showWebPage();
                                  }
                                },onError: (e) {
                                  print(e);
                                });
                              }
                            })
                        }
                    );
                  },
                  onWebViewCreated: (WebViewController webViewController) {
                    _controllerCompleter.future.then((value) => controller = value);
                    _controllerCompleter.complete(webViewController);
                  },
                ),
                Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.12,
                        ),
                        Image.asset(
                          "assets/images/icon_loading.jpg",
                          width: MediaQuery.of(context).size.width * 0.5,
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            'Loading...',
                            style: TextStyle(fontSize: MediaQuery.of(context).size.height* 0.025, fontWeight: FontWeight.w600,fontFamily: 'Poppins-Medium',),
                          ),
                        ),
                        ColorLoaderWavey(dotOneColor: Colors.amber,dotTwoColor: Colors.blueAccent ,dotThreeColor:Colors.green ,dotType: DotType.square,dotIcon:Icon(Icons.adjust) ,)
                      ],
                    ) ),
              ]
          ),
        ),
      ),
    );
  }

}


class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController _controller = snapshot.data;

        return Row(
          children: <Widget>[

//            IconButton(
//              icon: const Icon(Icons.arrow_back_ios),
//              onPressed: !webViewReady
//                  ? null
//                  : () async {
//                if (await _controller.canGoBack()) {
//                  _controller.goBack();
//                } else {
//                  Scaffold.of(context).showSnackBar(
//                    const SnackBar(content: Text("No back history item")),
//                  );
//                  return;
//                }
//              },
//            ),
//            IconButton(
//              icon: const Icon(Icons.arrow_forward_ios),
//              onPressed: !webViewReady
//                  ? null
//                  : () async {
//                if (await _controller.canGoForward()) {
//                  _controller.goForward();
//                } else {
//                  Scaffold.of(context).showSnackBar(
//                    const SnackBar(
//                        content: Text("No forward history item")),
//                  );
//                  return;
//                }
//              },
//            ),

            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                _controller.reload();
              },
            ),
          ],
        );
      },
    );
  }

}