package com.botlish2048

import android.content.Intent
import android.os.Bundle
import android.system.Os
import android.util.Log
import com.facebook.react.ReactActivity
import com.facebook.react.ReactActivityDelegate
import com.facebook.react.ReactApplication
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint.fabricEnabled
import com.facebook.react.defaults.DefaultReactActivityDelegate

/**
 * The template's activity, with what the Android acceptance run drives from
 * adb (BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md, "Android execution"):
 *
 *   --es mode selftest        the JavaScript self-test instead of the game
 *   --es start SNAPSHOT       the game begins from SNAPSHOT
 *   --ez gcStress true        BOTLISH_NATIVE_GC_STRESS=1 for the Botlish
 *                             libraries (set before any instance exists;
 *                             where the app runs on a native bridge, its
 *                             arm64 libc does not see it: the acceptance
 *                             reports GC stress as not demonstrated there)
 *   --ez reload true          (to the running activity) React Native reloads:
 *                             its JavaScript runtime and TurboModules are
 *                             destroyed and made again
 *
 * None of it is the Botlish package's: the generated module knows nothing of
 * these extras.
 */
class MainActivity : ReactActivity() {

  override fun getMainComponentName(): String = "Botlish2048"

  override fun onCreate(savedInstanceState: Bundle?) {
    if (intent?.getBooleanExtra("gcStress", false) == true) {
      Os.setenv("BOTLISH_NATIVE_GC_STRESS", "1", true)
      Log.i("Botlish2048", "BOTLISH_NATIVE_GC_STRESS=1")
    }
    super.onCreate(savedInstanceState)
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    setIntent(intent)
    if (intent.getBooleanExtra("reload", false)) {
      Log.i("Botlish2048", "reloading React Native")
      (application as ReactApplication).reactHost?.reload("botlish acceptance run")
    }
  }

  override fun createReactActivityDelegate(): ReactActivityDelegate =
      object : DefaultReactActivityDelegate(this, mainComponentName, fabricEnabled) {
        override fun getLaunchOptions(): Bundle? {
          val intent = plainActivity.intent ?: return null
          val options = Bundle()
          for (key in listOf("mode", "start")) {
            intent.getStringExtra(key)?.let { options.putString(key, it) }
          }
          return if (options.isEmpty) null else options
        }
      }
}
