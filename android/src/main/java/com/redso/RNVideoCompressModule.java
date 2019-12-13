
package com.redso;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import android.net.Uri;
import android.util.Log;

import java.io.File;
import java.util.UUID;

import com.redso.videocompress.VideoCompressor;

public class RNVideoCompressModule extends ReactContextBaseJavaModule {

  private void sendProgress(ReactContext reactContext, float progress) {
    reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit("progress", progress);
  }

  private final ReactApplicationContext reactContext;

  public RNVideoCompressModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNVideoCompress";
  }

  @ReactMethod
  public void compress(String source, ReadableMap options, final Promise pm) {
    String inputUri = Uri.parse(source).getPath();
    File outputDir = reactContext.getCacheDir();

    final String outputUri = String.format("%s/%s.mp4", outputDir.getPath(), UUID.randomUUID().toString());

    int width = options.hasKey("width") ? options.getInt("width") : 0;
    int height = options.hasKey("height") ? options.getInt("height") : 0;
    int bitrate = options.hasKey("bitrate") ? options.getInt("bitrate") : 0;

    try {
      VideoCompressor.convertVideo(inputUri, outputUri, width, height, bitrate, new VideoCompressor.ProgressListener() {
        @Override
        public void onStart() {
          //Start Compress
          Log.d("INFO", "Compression started");
        }

        @Override
        public void onFinish(boolean result) {
          //Finish successfully
          pm.resolve(outputUri);
        }

        @Override
        public void onProgress(float percent) {
          sendProgress(reactContext, percent/100);
        }
      });
    } catch ( Throwable e ) {
      e.printStackTrace();
    }
  }
}