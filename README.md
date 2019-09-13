## Running instructions

Follow the next steps to run <b>Contractor Search</b> app:

<b>STEP 1:</b> Install Flutter SDK following the instructions described [here]( https://flutter.dev/docs/get-started/install).

<b>STEP 2:</b> If you want to open the project using Android Studio/IntelliJ or VS Code, set up one of these editors using the steps described [here](https://flutter.dev/docs/get-started/editor?tab=androidstudio).

<b>STEP 3:</b>  Add Firebase config files for Android and IOS. Go to the [Firebase project](https://console.firebase.google.com/u/1/project/contractorsearch-eeaf7/overview) and download the config files. On the left side, near `Project Overview`, click on the settings icon, then select `Project settings`.

- <b>ANDROID config file</b> In the `Your apps` card, select the Android app and download the latest config file by clicking on `google-services.json`. Copy this config file. Go to the project directory -> android -> app -> and paste here the `google-services.json` file.
   
   Authorize the app to use Firebase Authentication by adding your SHA-1 in the Firebase Console:
   
   - Get your SHA-1 by running the following command in your terminal: `keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android`
   - Copy the SHA-1 and go back to [Firebase Console](https://console.firebase.google.com/u/1/project/contractorsearch-eeaf7/settings/general/android:com.example.contractor_search). Click on `Add fingerprint` and paste your certificate fingerprint here. Click `Save`.


- <b>IOS config file</b> In the `Your apps` card, select IOS app and download the latest config file by clicking on `GoogleService-Info.plist`. Copy this config file. Go to the project directory -> ios -> and double click on Runner.xcworkspace. This will open the project in Xcode (XCode must be installed on your mac). Paste `GoogleServices-Info.plist` file into ios/Runner/Runner directory from XCode.

<b>STEP 4:</b> Run the app:
  
  - <i>On Android device:</i>
     - Using the terminal:
         - cd contractor_search
         - flutter devices (Check that an Android device is running - your Android device must be connected to your laptop)
         - flutter run - After the app build completes, you’ll see the app on your device
     - Using Android Studio IDE: 
          - Open the project (File -> Open -> and choose the project). Open pubspec.yaml and click `Get Dependencies`. 
          - Locate the main Android Studio toolbar.
          - In the target selector, select the Android device for running the app.
          - Click the run icon in the toolbar, or invoke the menu item Run > Run.

  - <i>On IOS device:</i>
       To run the app on your IOS device, open the app in Xcode. (go to the project directory -> ios -> and double click on Runner.xcworkspace). After you opened your project, you can configure the device on the top left corner. Make sure your iPhone is connected to your computer with an USB cable. 
       - In the Signing configuration you need to select a team. More details [here](https://medium.com/front-end-weekly/how-to-test-your-flutter-ios-app-on-your-ios-device-75924bfd75a8)
        - Set a unique Bundle iIdentifier if you have an invalid one.
     - After that you can click run and build the project. You might be prompted to enter your keychain, click always allow to save yourself some efforts.
     - After that, the app should be successfully built onto your device. Before you test it, you also have to trust yourself as the developer on that device. You need to go to your Settings > General > Device Management -> Select the developer name and tap Trust “contractor_search”.
