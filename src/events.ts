import { EVENTS } from './constants';
import type {
  UploadFinishedListenerType,
  UploadFailedListenerType,
  FileErrorListenerType,
  ProgressForListenerType,
  HeartbeatListenerType,
  CancelFinishedListenerType,
} from './types';

import { emitter } from './nativeBridge';

/**
 * Upload finished
 */
function addUploadFinishedListener(listener: UploadFinishedListenerType) {
  return emitter.addListener(EVENTS.UPLOAD_FINISHED_EVENT, listener);
}

/**
 * Cancel finished
 */
function addCancelFinishedListener(listener: CancelFinishedListenerType) {
  return emitter.addListener(EVENTS.CANCEL_FINISHED_EVENT, listener);
}

/**
 * Upload failed including any preset automatic retries
 */
function addUploadFailedListener(listener: UploadFailedListenerType) {
  return emitter.addListener(EVENTS.UPLOAD_FAILED_EVENT, listener);
}

/**
 * Handle errors related to read/write of metadata file
 */
function addFileErrorListener(listener: FileErrorListenerType) {
  return emitter.addListener(EVENTS.FILE_ERROR_EVENT, listener);
}

/**
 * Progress events
 */
function addProgressForListener(listener: ProgressForListenerType) {
  return emitter.addListener(EVENTS.PROGRESS_FOR_EVENT, listener);
}

/**
 * Hearbeat events
 */
function addHeartbeatListener(listener: HeartbeatListenerType) {
  return emitter.addListener(EVENTS.HEARTBEAT_EVENT, listener);
}

/**
 * Freed memory events
 */
 function addFreedMemoryListener(listener: HeartbeatListenerType) {
  return emitter.addListener(EVENTS.FREED_MEMORY, listener);
}

export default {
  addCancelFinishedListener,
  addUploadFinishedListener,
  addUploadFailedListener,
  addFileErrorListener,
  addProgressForListener,
  addHeartbeatListener,
};
