import TusNative from './nativeBridge';
import events from './events';
import type {
  UploadFinishedDataType,
  UploadFailedDataType,
  ProgressForDataType,
  BatchUploadRequestItem,
  BatchUploadRequestResponse,
  RetryByIdsResponse,
  GetInfoResponse,
  SyncResponse,
} from './types';

type Options = {
  metadata: any;
  headers: any;
  endpoint: string;
  onSuccess?: (uploadId: string) => void;
  onProgress?: (bytesUploaded: number, bytesTotal: number) => void;
  onError?: (error: Error | unknown) => void;
};

// events.addUploadFinishedListener((param) =>
//   console.log('Upload Finished: ', param)
// );
// events.addUploadFailedListener((param) =>
//   console.log('Upload Failed: ', param)
// );
// events.addFileErrorListener((param) => console.log('File Error: ', param));
// events.addProgressForListener((param) => console.log('Progress For: ', param));

export const getInfo = (): Promise<GetInfoResponse> => TusNative.getInfo();

/**
 * Read any cached files on disk and start upload tasks for them
 */
export const startAll = (): Promise<boolean> => TusNative.startAll();

export const sync = (): Promise<SyncResponse> => TusNative.sync();

export const startSelection = (uploadIds: string[]): Promise<any> =>
  TusNative.startSelection(uploadIds);

export const pauseAll = (): Promise<any> => TusNative.pauseAll();

export const cancelAll = (): Promise<any> => TusNative.cancelAll();

export const cancelByIds = (uploadIds: string[]): Promise<any> =>
  TusNative.cancelByIds(uploadIds);

/**
 * @returns true if no errors
 */
export const retryByIds = (uploadIds: string[]): Promise<RetryByIdsResponse> =>
  TusNative.retryByIds(uploadIds);

export const getFailedUploadIds = (): Promise<any> =>
  TusNative.getFailedUploadIds();

export const createBatchUpload = (
  uploads: BatchUploadRequestItem[]
): Promise<BatchUploadRequestResponse> =>
  TusNative.createMultipleUploads(uploads);

export class Upload {
  file: string;
  options: Options;
  uploadId: string;
  subscriptions: Array<{ remove: () => void }>;

  constructor(file: string, options: Options) {
    this.file = file;
    this.options = options;
    this.uploadId = '';
    this.subscriptions = [];
  }

  async createUpload() {
    const { metadata, headers, endpoint } = this.options;
    const settings = { metadata, headers, endpoint };
    try {
      this.uploadId = await TusNative.createUpload(this.file, settings);

      this.subscribe();
    } catch (err) {
      this.emitError(err);
    }
  }

  async abort() {
    try {
      TusNative.cancelByIds([this.uploadId]);
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
    if (!this.file) {
      console.log(new Error('tus: no file or stream to upload provided'));
      return;
    }
    if (!this.options.endpoint) {
      console.log(new Error('tus: no endpoint provided'));
      return;
    }
    if (this.uploadId) {
      return this.uploadId;
    }

    try {
      await this.createUpload();
    } catch (err) {
      this.emitError(err);
    }
    return this.uploadId;
  }

  async resumeFromPreviousUpload(previousUpload: any) {
    this.uploadId = previousUpload?.id;
    startSelection([this.uploadId]);
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
        ({ uploadId }: UploadFinishedDataType) => {
          if (uploadId === this.uploadId) {
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
            this.onError(new Error(error));
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

export * from './types';
export default { Upload, events };
