import * as React from 'react';

import { StyleSheet, View, Text, Button, Image, ScrollView } from 'react-native';
import { Upload, startAll } from 'react-native-tus';

import * as ImagePicker from 'react-native-image-picker';

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
    inclueExtra: true,
  };

  console.log( pendingUploads );
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
        {uploadResult.length > 0 &&
          uploadResult.map((result: string) => (
            <Text key={result}>Upload Result: {result} - Success!</Text>
          ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
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
});
