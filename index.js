import { NativeEventEmitter, NativeModules, } from 'react-native';
const { RNVideoCompress } = NativeModules;

const videoCompressEmitter = new NativeEventEmitter(RNVideoCompress);

const LISTENERS = '__listeners';

class ProgressPromise extends Promise {
  constructor(executor) {
    super((resolve, reject) => executor(resolve, reject,
      // Pass method for passing progress to listener
      value => {
        try {
          return this[LISTENERS].forEach(listener => listener(value));
        } catch(error) {
          reject(error);
        }
      }));
    this[LISTENERS] = [];
  }
  progress(handler) {
    if(typeof handler !== 'function')
      throw new Error('PROGRESS_REQUIRES_FUNCTION');
    this[LISTENERS].push(handler);
    return this;
  }
}

export default {
  compress: (source, options) => {
    return new ProgressPromise((resolve, reject, progress) => {
      const subscription = videoCompressEmitter.addListener('progress', p => progress(p));
  
      RNVideoCompress.compress(source, options).then(output => {
        subscription.remove();
        resolve(output);
      }).catch(err => reject(err));
    });
  },
}