package com.redso.videocompress;


/**
 * Video Compressor
 * a library to convert video to smaller mp4 file
 * can set new width ,height, and bitrate ,progress listener
 */
public class VideoCompressor {


    public static VideoCompressTask convertVideo(String srcPath, String destPath, int outputWidth, int outputHeight, int bitrate, ProgressListener listener) {
        VideoCompressTask task = new VideoCompressTask(listener);
        task.execute(srcPath, destPath, outputWidth, outputHeight, bitrate);
        return task;
    }


    public static interface ProgressListener {

        void onStart();
        void onFinish(boolean result);
        void onProgress(float progress);

    }

}
