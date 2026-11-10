package com.botlish2048

import android.app.Application
import android.system.Os
import android.util.Log
import com.facebook.react.PackageList
import com.facebook.react.ReactApplication
import com.facebook.react.ReactHost
import com.facebook.react.ReactNativeApplicationEntryPoint.loadReactNative
import com.facebook.react.defaults.DefaultReactHost.getDefaultReactHost

class MainApplication : Application(), ReactApplication {

  override val reactHost: ReactHost by lazy {
    getDefaultReactHost(
      context = applicationContext,
      packageList =
        PackageList(this).packages.apply {
          // Packages that cannot be autolinked yet can be added manually here, for example:
          // add(MyReactNativePackage())
        },
    )
  }

  override fun onCreate() {
    super.onCreate()
    // A GC-stress device build (-PbotlishDevice=gc-stress, app/build.gradle):
    // set before React Native starts, so before any Botlish instance exists
    // (the runtime reads it when an instance's heap is made). On a device
    // that runs arm64 code natively the libraries' libc is this process's
    // and sees it; through a native bridge it does not (MainActivity).
    if (BuildConfig.BOTLISH_GC_STRESS) {
      Os.setenv("BOTLISH_NATIVE_GC_STRESS", "1", true)
      Log.i("Botlish2048", "BOTLISH_NATIVE_GC_STRESS=1 (a GC-stress build)")
    }
    loadReactNative(this)
  }
}
