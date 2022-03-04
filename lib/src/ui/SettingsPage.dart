
//import 'package:agfsportalflutter/src/profiling/agfs.dart';
import 'package:agfsportalflutter/src/models/LoginFlags.dart';
import 'package:agfsportalflutter/src/ui/LoginPage.dart';
import 'package:agfsportalflutter/src/ui/PinPage.dart';
import 'package:agfsportalflutter/src/utils/StorageUtil.dart';
import 'package:agfsportalflutter/src/utils/app_config.dart';
import 'package:agfsportalflutter/src/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/OptionModal.dart';
import 'package:local_auth/local_auth.dart';

class SettingsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    var config = AppConfig.of(context);

    return  Scaffold(
        appBar: AppBar(
          leading: BackButton(
              color: Colors.white
          ),
          backgroundColor: config.myColor,
          title: Text('Setting Options',
            style: TextStyle( fontWeight: FontWeight.normal, fontSize:  MediaQuery.of(context).size.height* 0.020,fontFamily: 'Poppins-Medium',color: Colors.white),
          ),

        ),
        body: Center(
          child: MyStatefulWidget(config),
        ),
      );
  }
}

class MyStatefulWidget extends StatefulWidget {


  final AppConfig config;

  MyStatefulWidget(this.config);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState(config);
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> with WidgetsBindingObserver  {

  final AppConfig config;


  _MyStatefulWidgetState(this.config);

  String passCode='';
  final LocalAuthentication _localAuthentication = LocalAuthentication();


  var options = [

    Option(
      icon: Icon(Icons.fiber_pin, size: 40.0),
      title: 'Pin Authentication',
      subtitle: 'Test Content',
      isChecked: false,
    ),
    Option(
      icon: Icon(Icons.fingerprint, size: 40.0),
      title: 'Finger Print Authentication',
      subtitle: 'Content-Text',
      isChecked: false,
    ),
    Option(
      icon: Icon(Icons.phonelink_ring, size: 40.0),
      title: 'Logout',
      subtitle: 'Content-text',
    ),
    Option(
      icon: Icon(Icons.smartphone, size: 40.0),
      title: 'Change Pin',
      subtitle: 'You can set pin using this option',
    ),

  ];

  @override
  void initState() {
    getSetPin();
    super.initState();
  }


  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getSetPin();
    }
  }

  @override
  Widget build(BuildContext context) {

    var config = AppConfig.of(context);

    final _height = MediaQuery.of(context).size.height;


    // setting icon color based on the context(from profiling)

    options[0].icon=Icon(Icons.fiber_pin, size: 40.0,color: config.themeColor,);
    options[1].icon=Icon(Icons.fingerprint, size: 40.0,color: config.themeColor,);
    options[2].icon=Icon(Icons.phonelink_ring, size: 40.0,color: config.themeColor,);
    options[3].icon=Icon(Icons.smartphone, size: 40.0,color: config.themeColor,);


    return  Container(
      height: _height,
      child: Column(
        children: <Widget>[
          _switchListItem(options[0]),
          options[0].isChecked ? _listViewItem(options[3]) : new Container(),
          _switchListItem(options[1]),
          _listViewItem(options[2]),
        ],
      ),
    );

  }

  Widget _switchListItem(Option op) {


    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(10.0),
      width: double.infinity,
      height: 80.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.black26),
      ),
      child: SwitchListTile(
        activeColor:config.myColor,
        title: Text(
          op.title,
          style: TextStyle( fontWeight: FontWeight.normal, fontSize:  MediaQuery.of(context).size.height* 0.020,fontFamily: 'Poppins-Medium',),
        ),
        value: op.isChecked,
        onChanged: (bool value) {
          setState(() {

            if(op.title==PIN_AUTHENTICATION){
//              if(value){
//                if(passCode==null || passCode=='' || passCode=='null'){
//                  showPinAuthAlertDialog(context);
//                }
//                else{
//                  op.isChecked = value;
//                  StorageUtil prefs =  StorageUtil();
//                  prefs.setValue(SET_PIN_VAL,'true');
//                }
//              }
//              else{
//                op.isChecked = value;
//                StorageUtil prefs =  StorageUtil();
//                prefs.setValue(SET_PIN_VAL,null);
//              }

              op.isChecked = true;

            }
            else {
              StorageUtil prefs =  StorageUtil();
              if(value){
                _getBiometricsSupport(op,prefs);
              }
              else{
                op.isChecked = value;
                prefs.setValue(SET_FINGER_VAL,null);
              }}
          });
        },
        secondary: new IconButton(
          icon: Icon(op.icon.icon,size: op.icon.size, color: config.myColor),
        ),
      ),
    );

  }

  Future<void> _getBiometricsSupport(Option op,StorageUtil prefs) async {
    // 6. this method checks whether your device has biometric support or not
    bool hasFingerPrintSupport = false;
    try {
      hasFingerPrintSupport = await _localAuthentication.canCheckBiometrics;
    } catch (e) {
      print(e);
    }
    if (!mounted) return;

    if(hasFingerPrintSupport){

      op.isChecked = true;
      prefs.setValue(SET_FINGER_VAL,'true');
    }
    else{
      showBiometricAlertDialog(context);
    }
  }


  showBiometricAlertDialog(BuildContext context) {

    Widget continueButton = FlatButton(
      child: Text("Okay"),
      onPressed:  () {

        Navigator.of(context).pop();

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Biometric Support"),
      content: Text("Your device don't support finger print authentication."),
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



  Widget _listViewItem(Option op) {
    return  Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(10.0),
      width: double.infinity,
      height: 80.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.black26),
      ),
      child: ListTile(
        leading: op.icon,
        title: Text(
          op.title,
          style: TextStyle( fontWeight: FontWeight.normal, fontSize:  MediaQuery.of(context).size.height* 0.020,fontFamily: 'Poppins-Medium',),
        ),
        onTap: () {
          setState(() {

            if(op.title==CHANGE_PIN){
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => PinPage(CHANGE_PIN))).then((value) =>
                  getSetPin()
              );
            }
            else{
              showLogoutAlertDialog(context);
            }
          });
        },
      ),
    );
  }

  showPinAuthAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed:  () {

        Navigator.of(context).pop();

      Navigator.push(
      context, MaterialPageRoute(builder: (context) => PinPage(SET_PIN))).then((value) => getSetPin());
      },
    );

    // set up the AlertDialog

    AlertDialog alert = AlertDialog(
      title: Text("Pin Authentication"),
      content: Text("Please set your 4- digit pin for authentication."),
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

  showLogoutAlertDialog(BuildContext context) {

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

        clearPinValue();

        Navigator.of(context).pop();
        Navigator.of(context).pop();

          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => LoginPage(new LoginFlag(pin:'',showPin:false,showLoginContainer:true,showFinger:false))));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text("Are you sure you want to logout from application ?"),
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

   getSetPin(){

    StorageUtil prefs =  StorageUtil();
    Future<String> authToken = prefs.getValue(SET_PIN_VAL);
    authToken.then((data) {

      if(data!=null){
        if(data.toString()=='true'){
          setState(() {
            options[0].isChecked=true;
          });
        }
        else{
          options[0].isChecked=false;
        }
      }
      else{
        options[0].isChecked=false;
      }

    },onError: (e) {
      print(e);
    }
    );

    Future<String> authToken2 = prefs.getValue(SET_FINGER_VAL);
    authToken2.then((data) {

      if(data!=null){
        if(data.toString()=='true'){
          setState(() {
            options[1].isChecked=true;
          });

        }
        else{
          options[1].isChecked=false;
        }
      }
      else{
        options[1].isChecked=false;
      }

    },onError: (e) {
      print(e);
    }
    );

    Future<String> authToken3 = prefs.getValue(PIN);
    authToken3.then((data) {
      passCode=data.toString();
    },onError: (e) {
      print(e);
    });

  }

  clearPinValue(){
    StorageUtil prefs =  StorageUtil();
    prefs.setValue(PIN,null);
    prefs.setValue(SET_PIN_VAL,null);
    prefs.setValue(SET_FINGER_VAL,null);
    prefs.setValue(USERNAME,null);
  }

}