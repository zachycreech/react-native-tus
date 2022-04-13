import * as React from 'react';
import {
  StyleSheet,
  View,
  Button,
  Image,
  ScrollView,
} from 'react-native';
import * as ImagePicker from 'react-native-image-picker';
import { DataTable } from 'react-native-paper';
import TusUpload, { Upload, startAll } from 'react-native-tus';



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
    for( let x = 0; x < 1; x += 1 ) {
      const tusUpload = new Upload(firstImage?.uri, uploadOptions);
      tusUpload.start();
    }
    startAll();
  }, [imageResponse]);

  TusUpload.events.addUploadStartedListener((param) =>
    setUploadResult((oldResult: any) => {
      const { uploadId } = param;
      let newResult = oldResult;
      newResult[uploadId] = {
        uploadId,
        status: 'Started',
      };
      return newResult;
    })
  );
  TusUpload.events.addUploadFinishedListener((param) =>
    setUploadResult((oldResult: any) => {
      const { uploadId } = param;
      let newResult = oldResult;
      newResult[uploadId] = {
        uploadId,
        status: 'Finished',
      };
      return newResult;
    })
  );
  TusUpload.events.addUploadFailedListener((param) =>
    setUploadResult((oldResult: any) => {
      const { uploadId } = param;
      let newResult = oldResult;
      newResult[uploadId] = {
        uploadId,
        status: 'Failed',
      };
      return newResult;
    })
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
    flex: 5,
  },
  statusColumn: {
    flex: 2,
  },
});
