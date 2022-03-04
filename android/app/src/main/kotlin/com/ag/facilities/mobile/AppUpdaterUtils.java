package com.ag.facilities.mobile;

import android.content.Context;


class AppUpdaterUtils {

    public void showDialog(final Context _context,final AppUpdateListener updateListener) {

    }

    public interface AppUpdateListener {
        void onUpdateClicked(boolean update);
    }

}
