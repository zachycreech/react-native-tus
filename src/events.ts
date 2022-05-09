import { EVENTS } from './constants';
import type {
  UploadInitializedListenerType,
  UploadStartedListenerType,
  UploadFinishedListenerType,
  UploadFailedListenerType,
  FileErrorListenerType,
  TotalProgressListenerType,
  ProgressForListenerType,
} from './types';

import { emitter } from './nativeBridge';

/**
 * Upload Initialized
 */
function addUploadInitializedListener(listener: UploadInitializedListenerType) {
  return emitter.addListener(EVENTS.UPLOAD_INITIALIZED_EVENT, listener);
}

/**
 * Upload Started
 */
function addUploadStartedListener(listener: UploadStartedListenerType) {
  return emitter.addListener(EVENTS.UPLOAD_STARTED_EVENT, listener);
}

/**
 * Upload finished
 */
function addUploadFinishedListener(listener: UploadFinishedListenerType) {
  return emitter.addListener(EVENTS.UPLOAD_FINISHED_EVENT, listener);
}

/**
 * Upload failed including any preset automatic retries
 */
function addUploadFailedListener(listener: UploadFailedListenerType) {
  return emitter.addListener(EVENTS.UPLOAD_FAILED_EVENT, listener);
}

/**
 * I really don't know what this does. Please fill in if you figure it out
 */
function addFileErrorListener(listener: FileErrorListenerType) {
  return emitter.addListener(EVENTS.FILE_ERROR_EVENT, listener);
}

/**
 * Total progress for the current client
 */
function addTotalProgressListener(listener: TotalProgressListenerType) {
  return emitter.addListener(EVENTS.TOTAL_PROGRESS_EVENT, listener);
}

/**
 * Progress events
 */
function addProgressForListener(listener: ProgressForListenerType) {
  return emitter.addListener(EVENTS.PROGRESS_FOR_EVENT, listener);
}

export default {
  addUploadInitializedListener,
  addUploadStartedListener,
  addUploadFinishedListener,
  addUploadFailedListener,
  addFileErrorListener,
  addTotalProgressListener,
  addProgressForListener,
};
