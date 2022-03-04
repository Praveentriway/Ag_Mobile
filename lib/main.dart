
import 'package:agfsportalflutter/src/utils/app_config.dart';
import 'package:agfsportalflutter/src/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:agfsportalflutter/src/utils/HexColor.dart';
import 'MyApp.dart';


int _getColorFromHex(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return int.parse(hexColor, radix: 16);
}

void main() {

  var configuredApp = AppConfig(
    appName: "AGFS Mobile",
    appTheme: "#AC1E38",
    themeColor:  HexColor("#AC1E38"),
    myColor:  MaterialColor(_getColorFromHex("#AC1E38"), color),
    loginUrl: "http://mobile.agfacilities.com/api/logincall.xhtml?token=",
    loginFalseUrl: "http://mobile.agfacilities.com/m/login.xhtml?faces-redirect=true",
    splashImageUrl: 'assets/images/ag_logo_white.png',
    splashBgColor:Colors.redAccent,
    splashBgImageUrl:'assets/images/dubai-bg.jpg',
    loginImg: 'assets/images/ag_logo.png',
    loginBottom:'assets/images/login_bottom_ag.png',
    child: MyApp(),
  );

  runApp(configuredApp);

}

