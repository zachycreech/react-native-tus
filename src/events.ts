import { EVENTS } from './constants';
import type {
  UploadStartedListenerType,
  UploadFinishedListenerType,
  UploadFailedListenerType,
  FileErrorListenerType,
  ProgressForListenerType,
  HeartbeatListenerType,
} from './types';

import { emitter } from './nativeBridge';

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

export default {
  addUploadInitializedListener,
  addUploadStartedListener,
  addUploadFinishedListener,
  addUploadFailedListener,
  addFileErrorListener,
  addProgressForListener,
  addHeartbeatListener,
};
