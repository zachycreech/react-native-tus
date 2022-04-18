import * as React from 'react';
import {
  StyleSheet,
  View,
  Button,
  Image,
  ScrollView,
  SafeAreaView,
} from 'react-native';
import * as ImagePicker from 'react-native-image-picker';
import {DataTable} from 'react-native-paper';
import TusUpload, {Upload} from '@zachywheeler/react-native-tus';

export default function App() {
  const [uploadResult, setUploadResult] = React.useState<any>({});
  const [imageResponse, setImageResponse] = React.useState<any>();

  // const exampleUpload = new Upload(  );
  React.useEffect(() => {
    if (!imageResponse) {
      return;
    }
    console.log(JSON.stringify(imageResponse, null, 2));
    const firstImage = imageResponse?.assets && imageResponse.assets[0];
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
    for (let x = 0; x < 10; x += 1) {
      const tusUpload = new Upload(firstImage?.uri, uploadOptions);
      tusUpload.start();
    }
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

  return (
    <SafeAreaView style={styles.container}>
      <Button
        title="open picker for single file selection"
        onPress={async () => {
          ImagePicker.launchImageLibrary(pickerOptions, setImageResponse);
        }}
      />
      {imageResponse?.assets &&
        imageResponse?.assets.map(({uri}) => (
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
