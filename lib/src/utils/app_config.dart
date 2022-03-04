import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  AppConfig({this.appName,this.appTheme,this.themeColor,this.myColor,this.loginUrl,this.loginFalseUrl,this.splashImageUrl,this.splashBgColor,this.splashBgImageUrl,
    this.loginImg,this.loginBottom,
    Widget child}):super(child: child);

  final String appName;
  final String appTheme;
  final Color themeColor;
  final MaterialColor myColor;
  final String loginUrl;
  final String loginFalseUrl;
  final String splashImageUrl;
  final Color splashBgColor;
  final String splashBgImageUrl;
  final String loginImg;
  final String loginBottom;

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

}