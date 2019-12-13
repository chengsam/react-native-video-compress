
# react-native-video-compress

## Getting started

`$ npm install react-native-video-compress --save`

### Mostly automatic installation

`$ react-native link react-native-video-compress`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-video-compress` and add `RNVideoCompress.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNVideoCompress.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNVideoCompressPackage;` to the imports at the top of the file
  - Add `new RNVideoCompressPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-video-compress'
  	project(':react-native-video-compress').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-video-compress/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-video-compress')
  	```


## Usage
```javascript
import RNVideoCompress from 'react-native-video-compress';

// TODO: What to do with the module?
RNVideoCompress;
```
  