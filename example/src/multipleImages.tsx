import * as React from 'react';
import {
  ActivityIndicator,
  StyleSheet,
  Button,
  ScrollView,
  SafeAreaView,
} from 'react-native';
import asyncBatch from 'async-batch';
import * as ImagePicker from 'react-native-image-picker';
import DocumentPicker from 'react-native-document-picker';
import {DataTable} from 'react-native-paper';
import RNFS from 'react-native-fs';
import TusUpload, {
  createBatchUpload,
  generateIds,
} from '@zachywheeler/react-native-tus';

/**
 * Given an absolute path returns relative path (remaining path after application ID)
 */
const getRelativePath = (absolutePath: string) => {
  if (Platform.OS === 'ios') {
    //console.log('Absolute path: ' + absolutePath);
    const splitVals = absolutePath.split('/');
    const postAppIdIndex = splitVals.indexOf('Application') + 2;
    let relativePath = '';
    for (let i = postAppIdIndex; i < splitVals.length; i++) {
      relativePath += `/${splitVals[i]}`;
    }
    //console.log('Relative path: ' + relativePath);
    return relativePath;
  } else {
    throw new Error('fileUtils.getRelativePath not implemeneted');
  }
};

export default function App() {
  // @refresh reset
  const [uploadResult, setUploadResult] = React.useState<any>({});
  const [imageResponse, setImageResponse] = React.useState<any>();
  const [isLoading, setIsLoading] = React.useState<boolean>(false);

  // const exampleUpload = new Upload(  );
  React.useEffect(() => {
    if (!imageResponse) {
      return;
    }
    const uploadOptions = {
      metadata: {
        name: 'example-name',
        foo: 'bar',
      },
      headers: {
        'X-Example-Header': 'some-value',
      },
      // endpoint: 'http://0.0.0.0:1080/files/',
      endpoint: 'http://18.237.215.6:1080/files/',
    };
    console.log(JSON.stringify(imageResponse, null, 2));
    asyncBatch(
      imageResponse,
      async image => {
        if (await RNFS.exists(image.uri)) {
          const uploadObject = {
            fileUrl: getRelativePath(image.uri),
            options: {...uploadOptions},
          };
          return uploadObject;
        } else {
          console.log(
            `File: ${image.uri} exists? ${await RNFS.exists(image.uri)}`,
          );
        }
      },
      10,
    )
      .then(async (uploadObjects: any[]) => {
        const idsToUse = await generateIds(uploadObjects.length);
        return uploadObjects.map((uploadObject, index) => {
          let newObject = {...uploadObject};
          newObject.options.uploadId = idsToUse[index];
          return newObject;
        });
      })
      .then((uploadObjects: any[]) => {
        return uploadObjects.length > 0
          ? createBatchUpload(uploadObjects)
          : Promise.resolve();
      })
      .then((createdUploads: any[]) => {
        setIsLoading(false);
        setUploadResult((oldResult: any) => {
          let newResult = {...oldResult};
          createdUploads.forEach((createdUpload: any) => {
            const {uploadId} = createdUpload;
            newResult[uploadId] = {
              uploadId,
              status: 'Initialized',
            };
          });
          return newResult;
        });
      })
      .catch(e => {
        console.log('Error during creating uploads: ', e);
      });
  }, [imageResponse]);

  React.useEffect(() => {
    let listeners: EventSubscription[] = [];
    const uploadFinishedListener = TusUpload.events.addUploadFinishedListener(
      param => {
        const {uploadId} = param;
        setUploadResult((oldResult: any) => {
          let newResult = {...oldResult};
          newResult[uploadId] = {
            uploadId,
            status: 'Finished',
          };
          return newResult;
        });
      },
    );
    listeners.push(uploadFinishedListener);

    const uploadFailedListener = TusUpload.events.addUploadFailedListener(
      param => {
        const {uploadId} = param;
        setUploadResult((oldResult: any) => {
          let newResult = {...oldResult};
          newResult[uploadId] = {
            uploadId,
            status: 'Failed',
          };
          return newResult;
        });
      },
    );
    listeners.push(uploadFailedListener);

    // const fileErrorListener = TusUpload.events.addFileErrorListener((param) => {
    //   console.log('File Error: ', param);
    // });
    // listeners.push(fileErrorListener);

    // Progress events can get a bit spammy
    const progressForListener = TusUpload.events.addProgressForListener(
      (param: any) => {
        console.log('Progress For: ', param);
      },
    );
    listeners.push(progressForListener);

    const heartbeatListener = TusUpload.events.addHeartbeatListener(() => {
      console.log('Heartbeat...');
    });
    listeners.push(heartbeatListener);

    return () => listeners.forEach(listener => listener.remove());
  }, []);

  const pickerOptions: ImagePicker.ImageLibraryOptions = {
    selectionLimit: 1,
    mediaType: 'photo',
    includeBase64: false,
    includeExtra: true,
  };

  const documentPickerOptions: any = {
    type: DocumentPicker.types.images,
    mode: 'open',
    copyTo: 'documentDirectory',
  };
  return (
    <SafeAreaView style={styles.container}>
      <Button
        style={styles.button}
        title="open Image picker for single file selection"
        onPress={async () => {
          ImagePicker.launchImageLibrary(pickerOptions, response => {
            setImageResponse(response.assets);
          });
        }}
      />
      <Button
        style={styles.button}
        title="open Document picker for multiple file selection"
        onPress={async () => {
          setIsLoading(true);
          const response = await DocumentPicker.pickMultiple(
            documentPickerOptions,
          );
          const mappedResponse = response.map(image => ({
            uri: image.fileCopyUri,
          }));
          setImageResponse(mappedResponse);
        }}
      />
      {isLoading ? <ActivityIndicator /> : <></>}
      <ScrollView>
        <DataTable style={styles.table}>
          <DataTable.Header>
            <DataTable.Title style={styles.idColumn}>Upload ID</DataTable.Title>
            <DataTable.Title style={styles.statusColumn} numeric>
              Status
            </DataTable.Title>
          </DataTable.Header>
          {Object.keys(uploadResult).map((resultKey: string) => (
            <DataTable.Row key={resultKey}>
              <DataTable.Cell style={styles.idColumn}>
                {uploadResult[resultKey].uploadId}
              </DataTable.Cell>
              <DataTable.Cell style={styles.statusColumn} numeric>
                {uploadResult[resultKey].status}
              </DataTable.Cell>
            </DataTable.Row>
          ))}
        </DataTable>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'stretch',
    justifyContent: 'center',
  },
  button: {
    padding: 20,
  },
  imageSize: {
    width: 200,
    height: 200,
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
  image: {
    marginVertical: 24,
    alignItems: 'center',
  },
  table: {
    flex: 1,
    backgroundColor: 'snow',
  },
  idColumn: {
    flex: 5,
  },
  statusColumn: {
    flex: 2,
  },
});
