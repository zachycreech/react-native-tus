import * as React from 'react';
import {
  StyleSheet,
  View,
  Button,
  Image,
  ScrollView,
  Text,
} from 'react-native';
import * as ImagePicker from 'react-native-image-picker';
import { DataTable } from 'react-native-paper';
import TusUpload, { Upload, startAll } from 'react-native-tus';

TusUpload.events.addUploadStartedListener((param) =>
  console.log('Upload Started: ', param)
);
TusUpload.events.addUploadFinishedListener((param) =>
  console.log('Upload Finished: ', param)
);
TusUpload.events.addUploadFailedListener((param) =>
  console.log('Upload Failed: ', param)
);
TusUpload.events.addFileErrorListener((param) =>
  console.log('File Error: ', param)
);
TusUpload.events.addTotalProgressListener((param) =>
  console.log('Total Progress: ', param)
);
TusUpload.events.addProgressForListener((param) =>
  console.log('Progress For: ', param)
);

export default function App() {
  const [uploadResult, setUploadResult] = React.useState<any>([]);
  const [imageResponse, setImageResponse] = React.useState<any>();
  const [pendingUploads, setPendingUploads] = React.useState<any>([]);

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
      onSuccess: (uploadId: string) =>
        setUploadResult((oldUploadResult: Array<string>) => [
          ...oldUploadResult,
          uploadId,
        ]),
    };
    for( let x = 0; x < 1; x += 1 ) {
      const tusUpload = new Upload(firstImage?.uri, uploadOptions);
      tusUpload.start();
    }
    const remainingUploads = startAll();
    setPendingUploads(async () => await remainingUploads);
  }, [imageResponse]);

  const pickerOptions: ImagePicker.ImageLibraryOptions = {
    selectionLimit: 1,
    mediaType: 'photo',
    includeBase64: false,
    includeExtra: true,
  };

  return (
    <View style={styles.container}>
      <Button
        title="open picker for single file selection"
        onPress={async () => {
          ImagePicker.launchImageLibrary(pickerOptions, setImageResponse);
        }}
      />
      {imageResponse?.assets &&
        imageResponse?.assets.map(({ uri }) => (
          <View key={uri} style={styles.image}>
            <Image
              resizeMode="cover"
              resizeMethod="scale"
              style={{ width: 200, height: 200 }}
              source={{ uri: uri }}
            />
          </View>
        ))}
      <ScrollView>
        <DataTable style={styles.table}>
          <DataTable.Header>
            <DataTable.Title style={styles.idColumn}>Upload ID</DataTable.Title>
            <DataTable.Title style={styles.statusColumn} numeric>Status</DataTable.Title>
          </DataTable.Header>
          {uploadResult.map((result: string, key: number) => (
            <DataTable.Row key={key}>
              <DataTable.Cell style={styles.idColumn}>{result}</DataTable.Cell>
              <DataTable.Cell style={styles.statusColumn} numeric>???</DataTable.Cell>
            </DataTable.Row>
          ))}
        </DataTable>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'stretch',
    justifyContent: 'center',
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
    flex: 6,
  },
  statusColumn: {
    flex: 1,
  },
});
