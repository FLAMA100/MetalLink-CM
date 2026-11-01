# MetalLink CM

MetalLink CM is a Flutter marketplace app designed for buying and selling scrap metal across Cameroon. The app helps sellers publish scrap listings, lets buyers discover metals by type and city, and supports location-aware browsing, photo uploads, and voice notes.

This project is currently a polished prototype/demo app with mock data and local state management, built to showcase the product experience across desktop browser and Android.

## Overview

MetalLink CM targets the scrap-metal value chain in Cameroon by connecting:

- Sellers of ferrous and non-ferrous metal waste
- Buyers, recyclers, and manufacturers
- Local discovery based on city and GPS coordinates
- Fast listing creation with photos and media
- Simple communication flows for negotiation

## Features

- Onboarding flow for first-time users
- User authentication flow (demo/local persistence)
- Role-based registration: seller, buyer, or both
- Scrap listings with categories such as iron, steel, copper, aluminum, brass, zinc, lead, and mixed metals
- Search and filtering by metal type, city, price, and weight
- Location services using device GPS or browser geolocation
- Reverse geocoding to display a human-friendly place name
- Voice note recording and playback
- Image picking for photo uploads
- Listing cards with metadata, prices, urgency tags, and seller info
- Profile screen with stats and active listings
- Message mock inbox and chat navigation
- Android and Chrome web support

## Tech Stack

- Flutter
- Dart
- Provider for dependency injection and state management
- GoRouter for navigation
- SharedPreferences for demo persistence
- Google Fonts for branding
- geolocator for GPS/location
- image_picker for photos
- record + audioplayers for voice notes
- http for reverse geocoding via OpenStreetMap Nominatim
- timeago for relative timestamps

## Project Structure

```text
metallink_cm/
├── android/                # Android project files
├── ios/                    # iOS project files
├── lib/
│   ├── main.dart           # app bootstrap
│   ├── router.dart         # route configuration
│   ├── theme.dart          # app theme and branding
│   ├── models/            # AppUser and ScrapListing models
│   ├── services/           # Auth, listing, location, camera, voice services
│   ├── screens/           # app screens/pages
│   └── widgets/           # reusable UI widgets
├── test/                   # widget tests
├── analysis_options.yaml
├── firebase.json
├── pubspec.yaml            # Flutter app dependencies
├── pubspec_mobile.yaml     # mobile-oriented dependency variant
├── README.md
└── .gitignore
```

## App Architecture

The app uses a lightweight service-based architecture centered on Provider:

- AuthService manages login state and persisted demo user access
- ListingService stores the mock scrap listings and filtering logic
- LocationService obtains the current location and reverse-geocodes it
- VoiceNoteService handles microphone recording and playback
- CameraService manages image selection from the gallery or camera

This is a good prototype architecture for product validation, but the backend is intentionally mocked rather than connected to a real database or API.

## Prerequisites

Before running the app, make sure you have:

- Flutter SDK installed
- Android SDK configured if testing on Android
- Chrome installed for web development
- A device or emulator for Android testing

## First-Time Windows Setup

If your Windows username contains spaces, it may break Dart/Flutter tools. A common fix is to create short path aliases and set environment variables.

Run these commands once in PowerShell as Administrator:

```powershell
cmd /c mklink /J C:\flutter "C:\Users\NDI CHE ATIA\Downloads\Flutter\flutter"
cmd /c mklink /J C:\dartpub "C:\Users\NDI CHE ATIA\AppData\Local\Pub\Cache"
cmd /c mklink /J C:\myprojects "C:\flutter_projects"
```

Then configure environment variables:

- FLUTTER_ROOT = C:\flutter
- PUB_CACHE = C:\dartpub
- PATH should include C:\flutter\bin

After restarting PowerShell, continue with the project.

## Installation

From the project root:

```bash
flutter clean
flutter pub get
```

## Run the App

### Chrome / Web

```bash
cd C:\myprojects\metallink_cm
flutter run -d chrome
```

### Android

Connect a device with USB debugging enabled or start an emulator, then:

```bash
flutter run
```

## Build APK

```bash
flutter build apk --release
```

Output will typically be in:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Notes on Sensors and Device Features

The app uses multiple device features with platform-aware behavior:

- GPS / location: `geolocator`
- Microphone / voice notes: `record`
- Camera / gallery: `image_picker`
- Browser-based behavior on web uses the corresponding web APIs where supported

## Current Status / Demo Scope

This repository is best understood as a functional MVP prototype. It includes:

- UI screens and flows that resemble a real marketplace app
- Mock listings and mock user/auth behavior
- Local persistence for demo login status
- No production backend or database integration yet

## Future Improvements

The next realistic steps for this project would include:

- Real authentication with Firebase or a custom backend
- Persistent database storage for listings and users
- REST/GraphQL API integration
- Real image upload to cloud storage
- Real chat backend and notifications
- Payment/invoice workflows for transactions
- Admin moderation and quality checks
- Production deployment for web and Android

## License

This project is currently unlicensed and intended for internal/demo use unless otherwise specified.

## Contributing

This app is a prototype for product exploration and experimentation. If you want to extend it:

1. Create a feature branch
2. Make focused changes
3. Validate with `flutter test`
4. Keep the app mobile-first and cross-platform aware

## Quick Start Summary

```bash
flutter pub get
flutter run -d chrome
```

or

```bash
flutter run
```

For Android development, ensure the Android SDK is installed and the device/emulator is connected.
