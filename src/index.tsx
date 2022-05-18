import TusNative from './nativeBridge';
import events from './events';
import type {
  UploadFinishedDataType,
  UploadFailedDataType,
  ProgressForDataType,
  BatchUploadRequestItem,
  BatchUploadRequestResponse,
} from './types';

type Options = {
  metadata: any;
  headers: any;
  endpoint: string;
  onSuccess?: (uploadId: string) => void;
  onProgress?: (bytesUploaded: number, bytesTotal: number) => void;
  onError?: (error: Error | unknown) => void;
};

// events.addUploadInitializedListener((param) =>
//   console.log('Upload Initialized: ', param)
// );
// events.addUploadStartedListener((param) =>
//   console.log('Upload Started: ', param)
// );
// events.addUploadFinishedListener((param) =>
//   console.log('Upload Finished: ', param)
// );
// events.addUploadFailedListener((param) =>
//   console.log('Upload Failed: ', param)
// );
// events.addFileErrorListener((param) => console.log('File Error: ', param));
// events.addTotalProgressListener((param) =>
//   console.log('Total Progress: ', param)
// );
// events.addProgressForListener((param) => console.log('Progress For: ', param));

export const getRemainingUploads = (): Promise<any> =>
  TusNative.getRemainingUploads();

export const startAll = (): Promise<any> => TusNative.startAll();

export const startSelection = (uploadIds: string[]): Promise<any> =>
  TusNative.startSelection(uploadIds);

export const pauseAll = (): Promise<any> => TusNative.pauseAll();

export const pauseById = (uploadId: string): Promise<any> =>
  TusNative.pauseById(uploadId);

export const pauseByIds = (uploadIds: string[]): Promise<any> =>
  TusNative.pauseByIds(uploadIds);

export const cancelAll = (): Promise<any> => TusNative.cancelAll();

export const cancelById = (uploadId: string): Promise<any> =>
  TusNative.cancelById(uploadId);

export const cancelByIds = (uploadIds: string[]): Promise<any> =>
  TusNative.cancelByIds(uploadIds);

export const retryById = (uploadId: string): Promise<any> =>
  TusNative.retryById(uploadId);

export const retryByIds = (uploadIds: string[]): Promise<any> =>
  TusNative.retryByIds(uploadIds);

export const getFailedUploadIds = (): Promise<any> =>
  TusNative.getFailedUploadIds();

export const createBatchUpload = (
  uploads: BatchUploadRequestItem[]
): Promise<BatchUploadRequestResponse> => TusNative.createMultipleUploads(uploads);

export class Upload {
  file: string;
  options: Options;
  uploadId: string;
  url: string;
  subscriptions: Array<{ remove: () => void }>;

  constructor(file: string, options: Options) {
    this.file = file;
    this.options = options;
    this.uploadId = '';
    this.url = '';
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
      TusNative.cancelById(this.uploadId);
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

  async findPreviousUploads() {
    const previousUploads = await getRemainingUploads();
    return previousUploads
      ? previousUploads.filter(
          (upload: { context?: { metadata?: { name?: string } } }) =>
            upload?.context?.metadata?.name === this.options?.metadata?.name
        )
      : [];
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

export * from './types';
export default { Upload, events };
