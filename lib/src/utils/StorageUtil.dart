import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
class StorageUtil {

  final Key key=Key.fromUtf8('agfs-uae-spark-portal-encrypt-v2');


//  final AESMode mode;

   //Set data into shared serences

  Future<void> setValue(String key,String value) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(value==null){
      prefs.remove(key);
    }
    else{
      prefs.setString(key, encrypt(value));
    }
  }

  //Get a value from shared preferences

  Future<String> getValue(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String auth_token;
    auth_token = pref.getString(key) ?? null;
    return (auth_token!=null ? decrypt(auth_token) : null);
  }

  // AES ENCRYPTION - (MODE)- AESMode.SIC  (PADDING) - PKCS7
  // KEY && IV are set to be default value

  String encrypt(String val) {

    final key = this.key;
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key,mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(val, iv: iv);
    return (encrypted.base64);
  }

  String decrypt(String val) {

    final key = this.key;
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key,mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(val, iv: iv);
    return decrypted;

  }

  String loginEncryption(String val) {

    final key = this.key;
    final iv = IV.fromLength(16);

    List<int> bytes = utf8.encode("Some data");

    final encrypter = Encrypter(AES(key,mode: AESMode.cbc));
    final encrypted = encrypter.encrypt("test test", iv: iv);
    return (getUrlUnSafeString(encrypted.base64));

  }

   String getUrlUnSafeString(String token) {
    return token.replaceAll("%0A", "\n").replaceAll("%25", "%").replaceAll('_', '/').replaceAll('-', '+');
  }

}