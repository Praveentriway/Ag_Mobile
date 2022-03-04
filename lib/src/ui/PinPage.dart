
import 'dart:async';

//import 'package:agfsportalflutter/src/profiling/agfs.dart';
import 'package:agfsportalflutter/src/component/pinbox/PinEntryField.dart';
import 'package:agfsportalflutter/src/utils/StorageUtil.dart';
import 'package:agfsportalflutter/src/utils/app_config.dart';
import 'package:agfsportalflutter/src/utils/constant.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'WebviewPage.dart';

class PinPage extends StatelessWidget {
  final String pinTitle;//if you have multiple values add here
  PinPage(this.pinTitle, {Key key}): super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    var config = AppConfig.of(context);

    return  Scaffold(
      appBar: AppBar(
        backgroundColor: config.myColor,
        automaticallyImplyLeading: pinTitle==CHANGE_PIN,
//        leading: BackButton(
//            color: (pinTitle==CHANGE_PIN) ? Colors.white : config.themeColor
//        ),
        title: Text(pinTitle,
          style: TextStyle( fontWeight: FontWeight.normal, fontSize:  MediaQuery.of(context).size.height* 0.020,fontFamily: 'Poppins-Medium',color: Colors.white),
        textAlign: TextAlign.center,
        ),
      ),
      body: Center(
        child: PinCodeVerificationScreen(
            pinTitle),
      ),
    );
  }
}
class PinCodeVerificationScreen extends StatefulWidget {

   final String pinTitle;

  PinCodeVerificationScreen(this.pinTitle);

  @override
  _PinCodeVerificationScreenState createState() =>
      _PinCodeVerificationScreenState(pinTitle);
}

class _PinCodeVerificationScreenState extends State<PinCodeVerificationScreen> {
  var onTapRecognizer;
  String pinTitle='';

  String pinName='';

  _PinCodeVerificationScreenState(this.pinTitle);

  TextEditingController textEditingController = TextEditingController()
    ..text = "";

  StreamController<ErrorAnimationType> errorController;

  String errorText;
  String currentText;
  bool hasError = false;
  String titleText = ENTER_CURRENT_PASSCODE;
  String passCode='';
  String firstPin='';
  String confirmPin='';
  String pinType;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {

    pinName=pinTitle;

    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pop(context);
      };
    errorController = StreamController<ErrorAnimationType>();

    pinType= pinTitle;
    getPin();
    errorText='';
    titleText= (pinTitle==SET_PIN)? ENTER_NEW_PASSCODE : ENTER_CURRENT_PASSCODE;

    Timer(Duration(seconds: 1), () =>
    {

    if(this.pinTitle==SET_PIN){
        showPinSetSnackBar()
  }

    }
    );


    super.initState();
  }

  @override
  void dispose() {
    errorController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      key: scaffoldKey,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 20,

              ),
               Image.asset(
                 'assets/verify.png',
                 height: MediaQuery.of(context).size.height / 3.5,
                 fit: BoxFit.fitHeight,
               ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  titleText,
                  style: TextStyle( height: MediaQuery.of(context).size.height* 0.002,fontWeight: FontWeight.bold, fontSize:  MediaQuery.of(context).size.height* 0.025,fontFamily: 'Poppins-Medium',),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height *0.08,
              ),
              Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 50),
                  child: PinCodeTextField(
                    length: 4,
                    obsecureText: true,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: MediaQuery.of(context).size.height* 0.07,
                      fieldWidth: MediaQuery.of(context).size.width* 0.11,
                      activeFillColor: Colors.white,
                    ),
                    animationDuration: Duration(milliseconds: 300),
                    backgroundColor: Colors.blue.shade50,
                    enableActiveFill: false,
                    errorAnimationController: errorController,
                    controller: textEditingController,
                    onCompleted: (v) {
                      //print("Completed");

                      setState(() {
                        errorText = '';
                      });

                      if(currentText!=null || currentText.length>3){
                        performAfterPin(pinTitle,currentText);
                      }
                      else{
                        errorController.add(ErrorAnimationType
                            .shake);
                        textEditingController.clear();
                        setState(() {
                          errorText="Pin must contain 4-digit";
                        });
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
              SizedBox(
                height: MediaQuery.of(context).size.height* 0.002,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  errorText,
                  style: TextStyle( color: Colors.blueAccent,height: MediaQuery.of(context).size.height* 0.002,fontWeight: FontWeight.normal, fontSize:  MediaQuery.of(context).size.height* 0.017,fontFamily: 'Poppins-Medium',),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 20,
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height* 0.01,
              ),
              Container(
                margin:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
                child: ButtonTheme(
                  height:   MediaQuery.of(context).size.height *0.001,
                  child: FlatButton(
                    onPressed: () {

                      setState(() {
                        errorText = '';
                      });

                      if(currentText!=null || currentText.length>3){
                        performAfterPin(pinTitle,currentText);
                      }
                      else{
                        errorController.add(ErrorAnimationType
                            .shake);
                        textEditingController.clear();
                        setState(() {
                          errorText="Pin must contain 4-digit";
                        });
                      }

                    },
                    child: Center(
                        child: Text(
                          "Confirm".toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.height* 0.02,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
                decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.green.shade200,
                          offset: Offset(1, -2),
                          blurRadius: 5),
                      BoxShadow(
                          color: Colors.green.shade200,
                          offset: Offset(-1, 2),
                          blurRadius: 5)
                    ]),
              ),

            ],
          ),
        ),
      ),
    );
  }

  savePinValue(String pin){
    StorageUtil prefs =  StorageUtil();
    prefs.setValue(PIN,pin);
    prefs.setValue(SET_PIN_VAL,'true');
 }

 void getPin(){
   StorageUtil prefs =  StorageUtil();
   Future<String> authToken = prefs.getValue(PIN);
   authToken.then((data) {
     passCode = data.toString();
     print(passCode);
   },onError: (e) {
     print(e);
   });
 }

  void performAfterPin(String type,String _currentText){

    if(currentText!=null && currentText!="" && currentText.length>3){

      setState(() {
        errorText='';
      });

      if(type==SET_PIN){
        setPinAction();
      }
      else{
        changePinAction();
      }

    }
    else{

      setState(() {
        errorController.add(ErrorAnimationType
            .shake);
        textEditingController.clear();
        setState(() {
          errorText='Enter a valid PIN.';
        });
      });

    }

}

 void setPinAction(){

    if(firstPin==''){

      if(passCode!=null || passCode!='' || passCode!='null'){

        // check for entering old pin while changing new pin.

        if(passCode==currentText){

          errorController.add(ErrorAnimationType
              .shake);
          textEditingController.clear();
          setState(() {
            errorText='New Pin should not be same as old Pin.';
          });
        }
        else{
          firstPin=currentText;
          textEditingController.clear();
          setState(() {
            titleText=CONFIRM_PASSCODE;
            errorText='';
          });
        }

      }
      else{

        firstPin=currentText;
        textEditingController.clear();
        setState(() {
          titleText=CONFIRM_PASSCODE;
        });

      }

    }
    else{
      confirmPin=currentText;
      if(firstPin==confirmPin){
        savePinValue(confirmPin);
        firstPin='';
        confirmPin='';
       setState(() {
         errorText='';
       });
        showPinSetDialog(context);
      }
      else{

        errorController.add(ErrorAnimationType
            .shake);
        textEditingController.clear();
        setState(() {
          errorText="Not matching with previous pin. Please try again.";
        });

      }
    }
  }


  void changePinAction(){

    if(currentText==passCode){

      textEditingController.clear();
      setState(() {
        titleText=ENTER_NEW_PASSCODE;
        pinTitle=SET_PIN;
      });

    }
    else{

      errorController.add(ErrorAnimationType
          .shake);
      textEditingController.clear();
      setState(() {
        errorText="Not a valid pin. Please try again.";
      });

    }
  }

  showPinSetDialog(BuildContext context) {

    Widget continueButton = FlatButton(
      child: Text('Okay'),
      onPressed:  () {

       // navigation control after setting pin

        pinName==SET_PIN ? goLaunchPage() : goBack();

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text("Your Pin have successfully set. "),
      actions: [
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void goBack(){

    Navigator.of(context).pop();
    Navigator.of(context).pop();


  }
  void goLaunchPage(){

    Navigator.of(context).pop();

    StorageUtil prefs =  StorageUtil();

    Future<String> authToken = prefs.getValue(USERNAME);
    authToken.then((data) {

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => WebViewHolder(data.toString())));


    },onError: (e) {
      print(e);

    });

  }

  void showPinSetSnackBar() {


    final snackBar = SnackBar(
      content: Text('Please set your four digit pin before navigating to landing page.'),
      action: SnackBarAction(
        label: 'Okay',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);

  }


}