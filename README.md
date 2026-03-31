# MetalLink CM
Metal scrap marketplace for Cameroon — Flutter app for Chrome and Android.

## IMPORTANT: First-time Windows setup

Your Windows username has spaces which breaks the Dart compiler.
Run these commands ONCE in PowerShell (Admin), then never worry again:

  cmd /c mklink /J C:\flutter "C:\Users\NDI CHE ATIA\Downloads\Flutter\flutter"
  cmd /c mklink /J C:\dartpub "C:\Users\NDI CHE ATIA\AppData\Local\Pub\Cache"
  cmd /c mklink /J C:\myprojects "C:\flutter_projects"

Then in System Environment Variables:
  FLUTTER_ROOT = C:\flutter
  PUB_CACHE    = C:\dartpub
  PATH         = add C:\flutter\bin  (remove old Flutter path entry)

Restart PowerShell, then continue below.

## Run on Chrome

  cd C:\myprojects\metallink_cm
  flutter clean
  flutter pub get
  flutter run -d chrome

## Run on Android

Connect phone via USB, enable USB Debugging, then:

  flutter run

## Build Android APK

  flutter build apk --release
  # Output: build/app/outputs/flutter-apk/app-release.apk

## Sensors

  GPS location   — geolocator (browser API on web, native GPS on Android)
  Microphone     — record package (browser MediaRecorder on web, native on Android)
  Camera/Photos  — image_picker (file picker on web, native camera on Android)
  Phone/WhatsApp — url_launcher (opens dialer and WhatsApp)
