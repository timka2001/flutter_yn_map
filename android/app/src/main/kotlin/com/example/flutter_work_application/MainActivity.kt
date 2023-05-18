package com.example.flutter_work_application


import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import com.yandex.mapkit.MapKitFactory

class MainActivity: FlutterActivity() {
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
   
    MapKitFactory.setApiKey("d13f38f3-82d3-45e0-aa10-6bdbdc4a9c37") 
    super.configureFlutterEngine(flutterEngine)
  }
}