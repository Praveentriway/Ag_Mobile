import 'dart:async';
import 'dart:io';
import 'package:agfsportalflutter/src/models/LoginFlags.dart';
import 'package:agfsportalflutter/src/ui/LoginPage.dart';
import 'package:agfsportalflutter/src/ui/WebviewPage.dart';
import 'package:agfsportalflutter/src/utils/StorageUtil.dart';
import 'package:agfsportalflutter/src/utils/app_config.dart';
import 'package:agfsportalflutter/src/utils/constant.dart';
import 'package:agfsportalflutter/src/widget/color_loader_wavey.dart';
import 'package:agfsportalflutter/src/widget/dot_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  String token;

  @override
  void initState() {
    super.initState();

    checkInternet();
    disableCapture();
  }

  Future<void> disableCapture() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  navigate(){
     StorageUtil prefs =  StorageUtil();
     isLoggedIn(prefs);
  }

  checkInternet() async {

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

        Timer(
            Duration(seconds: 3),
                () => navigate()
        );
      }
    } on SocketException catch (_) {
      showInternetAlert(context);
    }
  }

   checkSetPIN(StorageUtil prefs,String pin){

    Future<String> authToken = prefs.getValue(SET_PIN_VAL);
    authToken.then((data) {

      if(data.toString()==null || data.toString()=='' || data.toString()=='null'){
        checkSetFinger(prefs, false, '');
      }
      else{
        checkSetFinger(prefs, true, pin);
      }

    },onError: (e) {
      print(e);
    });

  }

   checkSetFinger(StorageUtil prefs,bool setPin,String passCode){

    Future<String> authToken = prefs.getValue(SET_FINGER_VAL);
    authToken.then((data) {
      if(data.toString()==null || data.toString()=='' || data.toString()=='null'){

      setPin? showPinOnly(passCode):directLogin();

      }
      else{
        setPin ? showPinBiometric(passCode) :showBiometricOnly();
      }

    },onError: (e) {
      print(e);

    });
  }

   isLoggedIn(StorageUtil prefs){

    Future<String> authToken = prefs.getValue(USERNAME);
    authToken.then((data) {
      if(data.toString()==null || data.toString()=='' || data.toString()=='null'){
        showLoginOnly();
      }
      else{
        token=data.toString();
        checkPinValue(prefs);

      }
    },onError: (e) {
      print(e);

    });
  }

   checkPinValue(StorageUtil prefs){

    Future<String> authToken = prefs.getValue(PIN);
    authToken.then((data) {
      if(data.toString()==null || data.toString()=='' || data.toString()=='null'){
        checkSetFinger(prefs, false, '');
      }
      else{
        checkSetPIN(prefs,data.toString());
      }
    },onError: (e) {
      print(e);

    });
  }

  showBiometricOnly(){

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => LoginPage(new LoginFlag(pin:'',showPin:false,showLoginContainer:false,showFinger:true,token:this.token))));

  }

  directLogin(){

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => WebViewHolder(this.token)));

  }

  showPinBiometric(String passCode){

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => LoginPage(new LoginFlag(pin:passCode,showPin:true,showLoginContainer:true,showFinger:true,token:this.token))));
  }

  showLoginOnly(){
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => LoginPage(new LoginFlag(pin:'',showPin:false,showLoginContainer:true,showFinger:false,token:this.token))));
  }

  showPinOnly(String passCode){
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => LoginPage(new LoginFlag(pin:passCode,showPin:true,showLoginContainer:true,showFinger:false,token:this.token))));
  }

  @override
  Widget build(BuildContext context) {

    var config = AppConfig.of(context);

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFCFD8DC ),
      body: new Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: config.splashBgColor,
          image: DecorationImage(
            colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.1), BlendMode.dstATop),
            image: AssetImage(config.splashBgImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: new Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 250.0),
              child: Center(
                child: Image.asset(config.splashImageUrl,
                  height: size.height * 0.2,
                  width: size.width * 0.45,),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 1.0),
              child: new ColorLoaderWavey(dotOneColor: Colors.amber,dotTwoColor: Colors.blueAccent ,dotThreeColor:Colors.green ,dotType: DotType.square,dotIcon:Icon(Icons.adjust) ,),
            ),
          ],
        ),
      ),
    );
  }

  showInternetAlert(BuildContext context) {

    Widget continueButton = FlatButton(
      child: Text("Okay"),
      onPressed:  () {

        Navigator.of(context).pop();
        SystemNavigator.pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("No Internet Connection"),
      content: Text("Please turn on mobile data or WIFI connection and try again."),
      actions: [
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
}