import * as React from 'react';

import { StyleSheet, View, Text, Button, Image } from 'react-native';
import { Upload } from 'react-native-tus-native';

import * as ImagePicker from 'react-native-image-picker';

export default function App() {
  const [uploadResult, setUploadResult] = React.useState<any>();
  const [imageResponse, setImageResponse] = React.useState<any>();

  // const exampleUpload = new Upload(  );
  React.useEffect(() => {
    console.log(JSON.stringify(imageResponse, null, 2));
    const firstImage = imageResponse?.assets && imageResponse.assets[0];
    const uploadOptions = {
      metadata: {
        name: 'example-name',
      },
      headers: {
        "X-Example-Header": "some-value",
      },
      endpoint: 'http://0.0.0.0:1080/files/',
    };
    const tusUpload = new Upload(firstImage?.uri, uploadOptions);
    tusUpload.start();
  }, [imageResponse]);

  const pickerOptions: ImagePicker.ImageLibraryOptions = {
    maxHeight: 200,
    maxWidth: 200,
    selectionLimit: 1,
    mediaType: 'photo',
    includeBase64: false,
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
      <Text>Upload Result: {uploadResult}</Text>
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
