package com.ag.facilities.mobile

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
open class FixFlutterActivity : FlutterActivity() {
    override fun onDestroy() {
      try{
       //   flutterEngine?.platformViewsController?.onFlutterViewDestroyed()
          super.onDestroy()
      }
      catch (e:Exception){

          this.finishAffinity()

      }
    }
    companion object {
        fun createIntent(context: Context, initialRoute: String = "/"): Intent {
            return Intent(context, FixFlutterActivity::class.java)
                    .putExtra("initial_route", initialRoute)
                    .putExtra("background_mode", "opaque")
                    .putExtra("destroy_engine_with_activity", true)
        }
    }
}