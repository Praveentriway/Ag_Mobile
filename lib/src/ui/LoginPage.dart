import 'dart:async';

import 'dart:io';

import 'package:agfsportalflutter/src/component/pinbox/PinEntryField.dart';
import 'package:agfsportalflutter/src/models/LoginFlags.dart';
import 'package:agfsportalflutter/src/ui/WebviewPage.dart';
import 'package:agfsportalflutter/src/utils/StorageUtil.dart';
import 'package:agfsportalflutter/src/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:root_check/root_check.dart';
import '../Widget/bezier_container.dart';
import 'package:local_auth/local_auth.dart';
import 'package:agfsportalflutter/src/utils/app_config.dart';
import 'package:trust_fall/trust_fall.dart';
import 'package:get_ip/get_ip.dart';
import 'package:check_vpn_connection/check_vpn_connection.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

//removed from mainactxml android:name="io.flutter.app.FlutterApplication"
class LoginPage extends StatefulWidget {

  final LoginFlag loginFlag;

  LoginPage(this.loginFlag);

  @override
  _LoginPageState createState() => _LoginPageState(loginFlag);
}

class _LoginPageState extends State<LoginPage> {

   LoginFlag loginFlag;
  _LoginPageState(this.loginFlag);

  String currentText = "";
  bool hasError = false;
  bool showPin = true;
  bool showLoginContainer = true;
  bool showFingerLabel = true;
  String token = "";
  bool isJailBroken = false;
  bool isRooted = false;
  String alertText = "";

   TextEditingController emailController = TextEditingController();

  final LocalAuthentication _localAuthentication = LocalAuthentication();

  TextEditingController passwordController = TextEditingController();

  TextEditingController textEditingController = TextEditingController()

    ..text = "";

  StreamController<ErrorAnimationType> errorController;

  bool _showObscurePassword = true;

  static const platformMethodChannel = const MethodChannel('com.ag.facilities.portal/platform_channel');

  double cardElevation=7;


  @override
  void initState() {

     showPin = loginFlag.showPin;
     showLoginContainer = loginFlag.showLoginContainer;
     showFingerLabel = loginFlag.showFinger;
     token=loginFlag.token;
     errorController = StreamController<ErrorAnimationType>();
     emailController.text="";
     passwordController.text="";


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

      if(isJailBroken){
        print("isJailBroken : Yes");
        alertText = "This application not works on Rooted Device.";
        _showDialog(alertText);
      }else{
        print("isjailBroken : No");
      }

      if(isRooted){
        print("isRooted : Yes");
        alertText = "This application not works on JailBroken Device.";
        _showDialog(alertText);
      }else{
        print("isRooted : No");
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



  @override
  void dispose() {
    errorController.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    Size size = MediaQuery.of(context).size;

    var config = AppConfig.of(context);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
      height: _height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: - _height * .15,
              right: - _width * .4,
              child: BezierContainer()),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              config.loginBottom,
              width: size.width * 0.25,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: _height * .15),
                  Image.asset(config.loginImg,
                    height: _height * 0.2,
                    width: _width * 0.45,),

                  showLoginContainer? new Container(child:showPin ? pinCode():loginCard()) : new Container(),

                  showFingerLabel?_loginViaCredentials() : new Container(),

                ],
              ),
            ),
          ),
        ],
      ),
    ));

  }

  Widget _loginViaCredentialsButton() {

    var config = AppConfig.of(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height *0.06,
      padding: EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [config.themeColor, config.themeColor])),
      child: Text(
        'Login via credentials',
        style: TextStyle(fontSize: MediaQuery.of(context).size.height* 0.02, color: Colors.white,fontFamily: 'Poppins-Medium',),
      ),
    );
  }

  Widget horizontalLine() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    child: Container(
      width: 20,
      height: 1.0,
      color: Colors.black26.withOpacity(.2),
    ),
  );

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('Or',  style: TextStyle(
            fontSize:  MediaQuery.of(context).size.height* 0.015,
            fontFamily: 'Poppins-Medium',
          )),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _changePassword(){

    return Container(
        alignment: Alignment.center,
        child: new GestureDetector(
          onTap: () {
            //  Navigator.pushNamed(context, "myRoute");
            setState(() {
              showPin=true;
            });
          },
          child: new Text(
            '',
            style: TextStyle(
                color: Color(0xFF616161),
                fontFamily: 'Poppins-Bold',
                fontSize: MediaQuery.of(context).size.height* 0.015,
                fontWeight: FontWeight.w600),
          ),
        )
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _emailEntryField("Username",emailController),
        _passwordEntryField("Password", passwordController),
      ],
    );
  }

  Widget _emailEntryField(String title,TextEditingController _controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle( height: MediaQuery.of(context).size.height* 0.002,fontWeight: FontWeight.normal, fontSize:  MediaQuery.of(context).size.height* 0.017,fontFamily: 'Poppins-Medium',),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordEntryField(String title,TextEditingController _controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle( height: MediaQuery.of(context).size.height* 0.002,fontWeight: FontWeight.normal, fontSize:  MediaQuery.of(context).size.height* 0.017,fontFamily: 'Poppins-Medium',),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            obscureText: _showObscurePassword,
            controller: _controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
              suffixIcon: GestureDetector(
                onTap: () {
                  _toggleVisibility();

                },
                child: Icon(
                  _showObscurePassword ?  Icons.visibility_off : Icons.visibility, color: Colors.red,),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleVisibility() {
    setState(() {
      _showObscurePassword = !_showObscurePassword;
    });
  }

  Widget _submitButton() {

    var config = AppConfig.of(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height *0.06,
      padding: EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [config.themeColor, config.themeColor])),
      child: Text(
        'Login',
        style: TextStyle(fontSize: MediaQuery.of(context).size.height* 0.02, color: Colors.white,fontFamily: 'Poppins-Medium',),
      ),
    );
  }

  Widget _loginViaCredentials(){

    return  Container(
        margin: EdgeInsets.all(2.0),
        child: Column(
            children: <Widget>[
              _fingerLabel(),
              showPin? new Container() : _divider(),
              showPin? new Container() :  SizedBox( height: MediaQuery.of(context).size.height * 0.03),
              showPin? new Container() :  InkWell(
                child: _loginViaCredentialsButton(),
                onTap: () {
                  setState(() {
                    showFingerLabel=false;
                    showLoginContainer = true;
                    showPin=false;
                  });
                },
              ),
            ]));

  }

  Widget _fingerLabel() {

    return Container(
      width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 1, bottom: 2),
        child: new GestureDetector(
            onTap: (){
              _authenticateMe();
            },
            child: new Container(
              child: new Column(
                children: <Widget>[
                  Text(
                    'Tap to launch Touch ID',
                    style: TextStyle(color: Colors.black, fontSize: MediaQuery.of(context).size.height* 0.019),
                  ),
                  SizedBox(
                    height:  MediaQuery.of(context).size.height * 0.03,
                  ),
                  Icon(Icons.fingerprint, size: MediaQuery.of(context).size.height*0.08, color: Colors.blueGrey),
                ],
              ),
            )
        ));

  }

  Widget pinCode(){

      return Card(
        elevation: this.cardElevation,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        margin: EdgeInsets.all(20.0),
        child: Container(
          child: Column(
            children: <Widget>[

              SizedBox(
                height: MediaQuery.of(context).size.height* 0.05,
              ),

              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: new GestureDetector(
                    onTap: () {

                    },
                    child: new  Text(
                      ENTER_PASSCODE,
                      style: TextStyle( color: Colors.black54 ,height: MediaQuery.of(context).size.height* 0.002,fontWeight: FontWeight.bold, fontSize:  MediaQuery.of(context).size.height* 0.020,fontFamily: 'Poppins-Bold',),
                      textAlign: TextAlign.center,
                    ),
                  )
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height* 0.05,
              ),
              Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 35),
                  child: PinCodeTextField(
                    length: 4,
                    obsecureText: true,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(3),
                      fieldHeight: MediaQuery.of(context).size.height* 0.07,
                      fieldWidth: MediaQuery.of(context).size.width* 0.11,
                      activeFillColor: Colors.white,
                    ),
                    animationDuration: Duration(milliseconds: 300),
                    backgroundColor: Colors.white,
                    enableActiveFill: false,
                    errorAnimationController: errorController,
                    controller: textEditingController,
                    onCompleted: (v) {
                      print("Completed");

                      if(currentText != loginFlag.pin){
                        errorController.add(ErrorAnimationType
                            .shake);
                        textEditingController.clear();// Triggering error shake animation
                        setState(() {
                          hasError=true;
                        });

                      }else {
                        Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (context) => WebViewHolder(token)));
                      }
                    },
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      print("Allowing to paste $text");
                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return true;
                    },
                  )),

              SizedBox( height: MediaQuery.of(context).size.height * 0.02),
              InkWell(
                child: _pinSubmitButton(),
                onTap: () {

                  if(currentText != loginFlag.pin){
                    errorController.add(ErrorAnimationType
                        .shake);
                    textEditingController.clear();// Triggering error shake animation
                    setState(() {
                      hasError=true;
                    });

                  }else {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => WebViewHolder(token)));
                  }

                },
              ),

            hasError?  Padding(
             padding: const EdgeInsets.symmetric(vertical: 15.0),
             child: new GestureDetector(
               onTap: () {

               },
               child: new  Text(
                 'Not a valid pin. Please try again.',
                 style: TextStyle( color: Colors.red.shade600 ,height: MediaQuery.of(context).size.height* 0.002,fontWeight: FontWeight.normal, fontSize:  MediaQuery.of(context).size.height* 0.017,fontFamily: 'Poppins-Bold',),
                 textAlign: TextAlign.center,
               ),
             )
         ) : new Container(),

              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: new GestureDetector(
                    onTap: () {
                      setState(() {
                        showPin=false;
                        showFingerLabel=false;
                      });
                    },
                    child: new  Text(
                      'Forget Pin ?',
                      style: TextStyle( color:  Colors.blueAccent ,height: MediaQuery.of(context).size.height* 0.002,fontWeight: FontWeight.normal, fontSize:  MediaQuery.of(context).size.height* 0.017,fontFamily: 'Poppins-Bold',),
                      textAlign: TextAlign.center,
                    ),
                  )
              ),

            ],
          ),
        ),
      );

  }

  Widget _pinSubmitButton() {

    var config = AppConfig.of(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height *0.06,
      margin: new EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 20.0,
          top: MediaQuery.of(context).size.height *0.01
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [config.themeColor, config.themeColor])),
      child: Text('Verify',
        style: TextStyle(fontSize: MediaQuery.of(context).size.height* 0.02, color: Colors.white,fontFamily: 'Poppins-Medium',),
      ),
    );
  }

  Widget loginCard(){

    return Card(
        elevation:this.cardElevation,
        shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white70, width: 1),
    borderRadius: BorderRadius.circular(5),
    ),
    margin: EdgeInsets.all(MediaQuery.of(context).size.height * 0.010),
    child: Container(
    margin: EdgeInsets.all(20.0),
    child: Column(
    children: <Widget>[
      _emailPasswordWidget(),
      SizedBox( height: MediaQuery.of(context).size.height * 0.05),
      InkWell(
        child: _submitButton(),
        onTap: () {

          String username=emailController.text;
          String password=passwordController.text;

          if(username=="" || password==""){
            showLogoutAlertDialog(context);
          }
          else{

            int date=DateTime.now().millisecondsSinceEpoch;

            clearPinValue();
            doNativeStuff(ENCRYPTION_KEY,username+" "+password+" $date");

          //  print(username+" "+password+" $date");

          }
        },
      ),
      _changePassword(),

    ])));
  }

  Future<Null> doNativeStuff(String key,String text) async {

    String _token;

    try {
      final String result =
      await platformMethodChannel.invokeMethod(LOGINENCRYPTION, <String, dynamic> { // data to be passed to the function
        'key': key,
        'text': text,
      });
      _token = result;

      saveCredentials(_token);

    } on PlatformException catch (e) {
      _token = "Sadly I can not change your life: ${e.message}.";
    }
  //  print(_token);
  }

    getPin() {
      if(loginFlag.showPin){
        setState(() {
          showPin=false;
        });
      }
      else{
        setState(() {
          showPin=true;
        });
      }
  }

  showLogoutAlertDialog(BuildContext context) {

    Widget continueButton = FlatButton(
      child: Text("Okay"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Authentication Error"),
      content: Text("Username or Password should not be empty."),
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

  saveCredentials(String username){
    StorageUtil prefs =  StorageUtil();
    prefs.setValue(USERNAME,username);
  //  prefs.setValue(PASSWORD,password);

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WebViewHolder(username)));

  }

  Future<void> _authenticateMe() async {
    // 8. this method opens a dialog for fingerprint authentication.
    //    we do not need to create a dialog nut it popsup from device natively.
    bool authenticated = false;
    try {
      authenticated = await _localAuthentication.authenticateWithBiometrics(
        localizedReason: "Authenticate your fingerprint to login", // message for dialog
        useErrorDialogs: true, // show error in dialog
        stickyAuth: true, // native process
      );
    } catch (e) {
      print(e);
    }
    if (!mounted) return;

    if(authenticated){
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => WebViewHolder(token)));
    }
  }

  clearPinValue(){
     StorageUtil prefs =  StorageUtil();
     prefs.setValue(PIN,null);
     prefs.setValue(SET_PIN_VAL,null);
     prefs.setValue(SET_FINGER_VAL,null);
     prefs.setValue(USERNAME,null);
   }

}
