import * as React from 'react';
import {
  StyleSheet,
  View,
  Button,
  Image,
  ScrollView,
  SafeAreaView,
} from 'react-native';
import asyncBatch from 'async-batch';
import * as ImagePicker from 'react-native-image-picker';
import DocumentPicker from 'react-native-document-picker';
import {DataTable} from 'react-native-paper';
import RNFS from 'react-native-fs';
import TusUpload, {
  Upload,
  createMultipleUploads,
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
  const [uploadResult, setUploadResult] = React.useState<any>({});
  const [imageResponse, setImageResponse] = React.useState<any>();

  // const exampleUpload = new Upload(  );
  React.useEffect(() => {
    if (!imageResponse) {
      return;
    }
    // RNFS.readDir(RNFS.DocumentDirectoryPath).then(documentDir => {
    //   console.log(JSON.stringify(documentDir, null, 2));
    //   documentDir.forEach(document => {
    //     if (document.isDirectory()) {
    //       RNFS.readDir(document.path).then(childDir => {
    //         console.log(JSON.stringify(childDir, null, 2));
    //       });
    //     }
    //   });
    // });
    const uploadOptions = {
      metadata: {
        name: 'example-name',
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
          // const tusUpload = new Upload(image.uri, uploadOptions);

          const tusUpload = new Upload(
            getRelativePath(image.uri),
            uploadOptions,
          );
          tusUpload.start();
          const uploadObject = {
            fileUrl: getRelativePath(image.uri),
            options: uploadOptions,
          };
          let uploadObjects = [];
          for (let x = 0; x < 500; x += 1) {
            uploadObjects.push(uploadObject);
          }
          await createMultipleUploads(uploadObjects);
        }
      },
      1,
    );
  }, [imageResponse]);

  React.useEffect(() => {
    let listeners: EventSubscription[] = [];
    const uploadStartedListener = TusUpload.events.addUploadStartedListener(
      param => {
        // console.log(`Upload started: `, param);
        const {uploadId} = param;
        setUploadResult((oldResult: any) => {
          let newResult = {...oldResult};
          newResult[uploadId] = {
            uploadId,
            status: 'Started',
          };
          return newResult;
        });
      },
    );
    listeners.push(uploadStartedListener);

    const uploadFinishedListener = TusUpload.events.addUploadFinishedListener(
      param => {
        // console.log(`Upload started: `, param);
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
        // console.log(`Upload started: `, param);
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
    // const totalProgressListener = TusUpload.events.addTotalProgressListener(
    //   (param) => {
    //     console.log('Total Progress: ', param);
    //   }
    // );
    // listeners.push(totalProgressListener);

    // const progressForListener = TusUpload.events.addProgressForListener(
    //   (param) => {
    //     console.log('Progress For: ', param);
    //   }
    // );
    // listeners.push(progressForListener);

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
    mode: 'import',
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
          const response = await DocumentPicker.pickMultiple(
            documentPickerOptions,
          );
          const mappedResponse = response.map(image => ({
            uri: image.fileCopyUri,
          }));
          setImageResponse(mappedResponse);
        }}
      />
      {imageResponse &&
        false &&
        imageResponse.map(({uri}) => (
          <View key={uri} style={styles.image}>
            <Image
              resizeMode="cover"
              resizeMethod="scale"
              style={styles.imageSize}
              source={{uri: uri}}
            />
          </View>
        ))}
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
