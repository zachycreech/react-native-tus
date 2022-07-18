import TusNative from './nativeBridge';
import events from './events';
import type {
  BatchUploadRequestItem,
  BatchUploadRequestResponse,
  RetryByIdsResponse,
  GetInfoResponse,
  SyncResponse,
} from './types';

export const getInfo = (): Promise<GetInfoResponse> => TusNative.getInfo();

/**
 * Read any cached files on disk and start upload tasks for them
 */
export const start = (): Promise<boolean> => TusNative.start();

export const sync = (): Promise<SyncResponse> => TusNative.sync();

export const pause = (): Promise<null> => TusNative.pause();

export const cancelByIds = (uploadIds: string[]): Promise<any> =>
  TusNative.cancelByIds(uploadIds);

export const retryByIds = (uploadIds: string[]): Promise<RetryByIdsResponse> =>
  TusNative.retryByIds(uploadIds);

export const createBatchUpload = (
  uploads: BatchUploadRequestItem[]
): Promise<BatchUploadRequestResponse> =>
  TusNative.createMultipleUploads(uploads);

export * from './types';
export default { events };
