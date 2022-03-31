export type UploadStartedDataType = {
  uploadId: string;
  sessionId: string;
};
export type UploadStartedListenerType = (arg0: UploadStartedDataType) => void;

export type UploadFinishedDataType = {
  uploadId: string;
  sessionId: string;
  url: string;
};
export type UploadFinishedListenerType = (arg0: UploadFinishedDataType) => void;

export type UploadFailedDataType = {
  uploadId: string;
  sessionId: string;
  error: Error;
};
export type UploadFailedListenerType = (arg0: UploadFailedDataType) => void;

export type FileErrorDataType = {
  sessionId: string;
  error: Error;
};
export type FileErrorListenerType = (arg0: FileErrorDataType) => void;

export type TotalProgressDataType = {
  bytesUploaded: number;
  totalBytes: number;
  sessionId: string;
};
export type TotalProgressListenerType = (arg0: TotalProgressDataType) => void;

export type ProgressForDataType = {
  uploadId: string;
  bytesUploaded: number;
  totalBytes: number;
  sessionId: string;
};
export type ProgressForListenerType = (arg0: ProgressForDataType) => void;
