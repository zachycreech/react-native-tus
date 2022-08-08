export type UploadFinishedDataType = {
  uploadId: string;
};
export type UploadFinishedListenerType = (arg0: UploadFinishedDataType) => void;

export type CancelFinishedDataType = {
  errorMessage?: string;
};
export type CancelFinishedListenerType = (arg0: CancelFinishedDataType) => void;

export type UploadFailedDataType = {
  uploadId: string;
  error: string;
};
export type UploadFailedListenerType = (arg0: UploadFailedDataType) => void;

export type FileErrorDataType = {
  uploadId: string;
  errorMessage: string;
};
export type FileErrorListenerType = (arg0: FileErrorDataType) => void;

export type ProgressForDataType = {
  uploadId: string;
  bytesUploaded: number;
  totalBytes: number;
};
export type ProgressForListenerType = (arg0: ProgressForDataType) => void;

export type HeartbeatListenerType = () => void;

export type BatchUploadRequestItem = {
  fileUrl: string;
  options: {
    endpoint: string;
    metadata: any;
    headers: any;
  };
  startNow?: boolean;
};

export type BatchUploadRequestResponse = {
  fileUrl: string;
  status: 'failure' | 'success';
  uploadId: string;
}[];

export type RetryByIdsResponse = {
  didRetry: boolean;
  reason: string;
  uploadId: string;
}[];

export type SyncResponse = {
  id: string;
  bytesUploaded: number;
  size: number;
  isError: boolean;
  name: string;
}[];

export type GetInfoResponse = {
  maxConcurrentUploadsNoWifi: number;
  maxConcurrentUploadsWifi: number;
  currentConcurrentUploads: number;
  filesToUploadCount: number;
};
