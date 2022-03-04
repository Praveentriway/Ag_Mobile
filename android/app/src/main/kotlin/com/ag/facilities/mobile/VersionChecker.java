package com.ag.facilities.mobile;

import android.os.AsyncTask;
import android.util.Log;

import org.jsoup.Jsoup;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class VersionChecker extends AsyncTask<String, String, Boolean> {

    String playStoreVersion;


    @Override
    protected Boolean doInBackground(String... params) {



        try {
            playStoreVersion = Jsoup.connect("https://play.google.com/store/apps/details?id=" + "BuildConfig.APPLICATION_ID" + "&hl=en")
                    .timeout(30000)
                    .userAgent("Mozilla/5.0 (Windows; U; WindowsNT 5.1; en-US; rv1.8.1.6) Gecko/20070725 Firefox/2.0.0.6")
                    .referrer("http://www.google.com")
                    .get()
                    .select("div.hAyfc:nth-child(4) > span:nth-child(2) > div:nth-child(1) > span:nth-child(1)")
                    .first()
                    .ownText();
        } catch (IOException e) {
            e.printStackTrace();
        }

        Log.d("version + app id",BuildConfig.VERSION_NAME+" "+BuildConfig.APPLICATION_ID);


        if(playStoreVersion!=null){
            if(Double.parseDouble(playStoreVersion)>Double.parseDouble(BuildConfig.VERSION_NAME)){
                return true;
            }
            else{
                return false;
            }
        }
        else{
            return false;
        }




    }
}
