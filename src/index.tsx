import TusNative from './nativeBridge';
import events from './events';
import type {
  UploadFinishedDataType,
  UploadFailedDataType,
  ProgressForDataType,
} from './types';

type Options = {
  metadata: {};
  headers: {};
  endpoint: string;
  sessionId: string;
  storageDir: string;
  onSuccess?: (uploadId: string) => void;
  onProgress?: (bytesUploaded: number, bytesTotal: number) => void;
  onError?: (error: Error | unknown) => void;
};

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
events.addProgressForListener((param) => console.log('Progress For: ', param));

export const scheduleBackgroundTasks = () => {
  TusNative.scheduleBackgroundTasks();
};

export class Upload {
  file: string;
  options: Options;
  uploadId: string;
  url: string;
  clientInitialization: Promise<void>;
  subscriptions: Array<{ remove: () => void }>;
  sessionId: string;
  storageDir: string;

  constructor(file: string, options: Options) {
    this.file = file;
    this.options = options;
    this.uploadId = '';
    this.url = '';
    this.subscriptions = [];

    const { endpoint, sessionId, storageDir } = options;
    this.sessionId = sessionId || 'TUS Session';
    this.storageDir = storageDir || 'TUS';
    const clientSettings = {
      sessionId: this.sessionId,
      storageDir: this.storageDir,
    };
    // This is safe to call for each upload. The native bridge will respond without creating
    // a new client if one already exists with the provided sessionId
    this.clientInitialization = TusNative.initializeClient(
      endpoint,
      clientSettings
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
    try {
      this.uploadId = await TusNative.createUpload(this.file, settings);

      this.subscribe();
    } catch (err) {
      this.emitError(err);
    }
  }

  emitError(error: Error | unknown) {
    if (this.options.onError) {
      this.options.onError(error);
    } else {
      throw error;
    }
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

  onSuccess(uploadId: string) {
    this.options.onSuccess && this.options.onSuccess(uploadId);
  }

  onProgress(bytesUploaded: number, bytesTotal: number) {
    this.options.onProgress &&
      this.options.onProgress(bytesUploaded, bytesTotal);
  }

  onError(error: Error) {
    this.options.onError && this.options.onError(error);
  }

  subscribe() {
    this.subscriptions.push(
      events.addUploadFinishedListener(
        ({ uploadId, url }: UploadFinishedDataType) => {
          if (uploadId === this.uploadId) {
            this.url = url;
            this.onSuccess(uploadId);
            this.unsubscribe();
          }
        }
      )
    );
    this.subscriptions.push(
      events.addUploadFailedListener(
        ({ uploadId, error }: UploadFailedDataType) => {
          if (uploadId === this.uploadId) {
            this.onError(error);
          }
        }
      )
    );
    this.subscriptions.push(
      events.addProgressForListener(
        ({ uploadId, bytesUploaded, totalBytes }: ProgressForDataType) => {
          if (uploadId === this.uploadId) {
            this.onProgress(bytesUploaded, totalBytes);
          }
        }
      )
    );
  }

  unsubscribe() {
    this.subscriptions.forEach((subscription) => subscription.remove());
  }
}

export default { Upload };
