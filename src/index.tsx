import TusNative from './nativeBridge';
import events from './events';

type Options = {
  metadata: {};
  headers: {};
  endpoint: string;
  sessionId: string;
  storageDir: string;
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
    events.addUploadStartedListener((param) =>
      console.log('Upload Started: ', param)
    );
    events.addUploadFinishedListener((param) =>
      console.log('Upload Finished: ', param)
    );
    events.addUploadFailedListener((param) =>
      console.log('Upload Failed: ', param)
    );
    events.addFileErrorListener((param) => console.log('File Error: ', param));
    events.addTotalProgressListener((param) =>
      console.log('Total Progress: ', param)
    );
    events.addProgressForListener((param) =>
      console.log('Progress For: ', param)
    );
  }

  async createUpload() {
    const {
      metadata,
      headers,
      endpoint,
      sessionId = 'TUS Session',
    } = this.options;
    const settings = { metadata, headers, endpoint, sessionId };
    this.uploadId = await TusNative.createUpload(this.file, settings);
    console.log(`Upload ID: ${this.uploadId}`);
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
