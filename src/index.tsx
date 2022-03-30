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
  sessionIdentifier: string;
  storageDirectory: string;
};

export class Upload {
  file: string;
  options: Options;
  uploadId: string;
  url: string;
  clientInitialization: Promise<void>;

  constructor(file: string, options: Options) {
    this.file = file;
    this.options = options;
    this.uploadId = '';
    this.url = '';

    const {
      endpoint,
      sessionId = 'TUS Session',
      storageDir = 'TUS',
    } = options;
    const clientSettings = {
      sessionId,
      storageDir,
    };
    // This is safe to call for each upload. The native bridge will respond without creating
    // a new client if one already exists
    this.clientInitialization = TusNative.initializeClient(
      endpoint,
      clientSettings
    );
  }

  async createUpload() {
    const { metadata, headers, endpoint, sessionId } = this.options;
    const settings = { metadata, headers, endpoint, sessionId };
    this.uploadId = await TusNative.createUpload(this.file, settings);
    // this.subscribe();
  }

  async start() {
    await this.clientInitialization;
    if (!this.file) {
      console.log(new Error('tus: no file or stream to upload provided'));
      return;
    }
    if (!this.options.endpoint) {
      console.log(new Error('tus: no endpoint provided'));
      return;
    }
    (this.uploadId ? Promise.resolve() : this.createUpload()).catch((err) =>
      console.log(err)
    );
  }
}

export default { Upload };
