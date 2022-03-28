import {
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

type Options = {
  metadata: {};
  headers: {};
  endpoint: string;
};

export class Upload {
  file: string;
  options: Options;
  uploadId: string;
  url: string;

  constructor(file: string, options: Options) {
    this.file = file;
    this.options = options;
    this.uploadId = '';
    this.url = '';
  }

  async createUpload() {
    const {metadata, headers, endpoint} = this.options;
    const settings = {metadata, headers, endpoint};
    const nativeResponse = await TusNative.createUpload(this.file, settings);
    console.log( nativeResponse );
  }

  start() {
    if(!this.file){
      console.log(new Error('tus: no file or stream to upload provided'));
      return;
    }
    if(!this.options.endpoint) {
      console.log(new Error('tus: no endpoint provided'));
      return;
    }
    (this.uploadId
      ? Promise.resolve()
      : this.createUpload())
    .then(() => this.resume())
    .catch((err) => console.log(err));
  }

  async resume() {
    const nativeResponse = await TusNative.resume(this.uploadId);
    console.log( nativeResponse );
  }
}

export default { Upload };
