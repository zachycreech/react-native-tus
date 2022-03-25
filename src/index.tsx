import {
  NativeEventEmitter,
  NativeModules,
  Platform,
} from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-tus-native' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const TusNative = NativeModules.TusNative
  ? NativeModules.TusNative
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

const tusEventEmitter = new NativeEventEmitter(TusNative);

class Upload {
  file;
  options;
  uploadId;
  subscriptions;
  url;

  constructor(file, options) {
    this.file = file;
    this.options = options;
    this.subscriptions = [];
  }

  emitError(error) {
    if(this.options.onError) {
      this.options.onError(error);
    } else {
      throw error;
    }
  }

  unsubscribe() {
    this.subscriptions.forEach(subscription => subscription.remove());
  }

  onSuccess() {
    this.options.onSuccess && this.options.onSuccess();
  }

  onProgress(bytesUploaded, bytesTotal) {
    this.options.onProgress &&
      this.options.onProgress(bytesUploaded, bytesTotal);
  }

  onError(error) {
    this.options.onError && this.options.onError(error);
  }

  subscribe() {
    this.subscriptions.push(
      tusEventEmitter.addListener('onSuccess', (payload) => {
        if (payload.uploadId === this.uploadId) {
          this.url = payload.uploadUrl;
          this.onSuccess();
          this.unsubscribe();
        }
      })
    );
    this.subscriptions.push(
      tusEventEmitter.addListener('onError', (payload) => {
        if (payload.uploadId === this.uploadId) {
          this.onError(payload.error);
        }
      })
    );
    this.subscriptions.push(
      tusEventEmitter.addListener('onProgress', (payload) => {
        if (payload.uploadId === this.uploadId) {
          this.onProgress(payload.bytesWritten, payload.bytesTotal);
        }
      })
    );
  }

  createUpload() {
    return new Promise((resolve, reject) => {
      const settings = { metadata, headers, endpoint };
      TusNative.createUpload(this.file, settings, (uploadId, errorMessage) => {
        this.uploadId = uploadId;
        if (uploadId == null) {
          const error = errorMessage
            ? new Error(errorMessage)
            : null;
          reject(error);
        } else {
          this.subscribe();
          resolve();
        }
      });
    });
  }

  start() {
    if(!this.file){
      this.emitError(new Error('tus: no file or stream to upload provided'));
      return;
    }
    if(!this.options.endpoint) {
      this.emitError(new Error('tus: no endpoint provided'));
      return;
    }
    (this.uploadId
      ? Promise.resolve()
      : this.createUpload())
    .then(() => this.resume())
    .catch((err) => this.emitError(err));
  }

  resume() {
    TusNative.resume(this.uploadId, (hasBeenResumed) => {
      if (!hasBeenResumed) {
        this.emitError(new Error('Error while resuming the upload'));
      }
    });
  }
}

export function multiply(a: number, b: number): Promise<number> {
  return TusNative.multiply(a, b);
}

export default { Upload };
