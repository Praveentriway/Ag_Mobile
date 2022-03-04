package com.ag.facilities.mobile

import android.app.AlertDialog
import android.content.ActivityNotFoundException
import android.content.DialogInterface
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.util.*
import android.view.WindowManager.LayoutParams
import android.view.WindowManager;


class MainActivity : FixFlutterActivity() {
    
    var LOGIN_ENCRYPTION="loginEncryption"
    private val PLATFORM_CHANNEL = "com.ag.facilities.portal/platform_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PLATFORM_CHANNEL).setMethodCallHandler {
            call, result ->

            val aes=AESEncryption()

            if (call.method == LOGIN_ENCRYPTION) {
                val key = call.argument<String>("key")
                val text = call.argument<String>("text")
            
//                Log.d("encryption str",aes.getUrlSafeString(aes.encrypt(text,key)))

                result.success(aes.getUrlSafeString(aes.encrypt(text,key)))

             }
            else {
                result.notImplemented() // INFO: not implemented
            }
        }
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val versionChecker = VersionChecker()
        val latestVersion = versionChecker.execute().get()

        if(latestVersion) {
            showDialog()
        }

        getWindow().addFlags(LayoutParams.FLAG_SECURE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE);
    }


    private fun showDialog(){

        val dialogBuilder = AlertDialog.Builder(activity!!)
        dialogBuilder.setMessage("New version is available. Please update the application to get all the new features. ")
                // if the dialog is cancelable
                .setCancelable(false)
                .setPositiveButton("Update", DialogInterface.OnClickListener {
                    dialog, id ->

                    val appPackageName = BuildConfig.APPLICATION_ID // package name of the app

                    try {
                        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=$appPackageName")))
                    } catch (anfe: ActivityNotFoundException) {
                        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$appPackageName")))
                    }
                    dialog.dismiss()

                })
        val alert = dialogBuilder.create()
        alert.setTitle("  Update Info")
        alert.show()
        
    }
    

}