# flutter_package_name_icon

A package which you can update app package (bundleId), app name and app icon.

** This package use **[flutter_launcher_icons]** 
(created by [Mark O'Sullivan](https://github.com/MarkOSullivan94) 
and [Franz Silva](https://github.com/franzsilva)) and 
use **[flutter_native_splash]** (created by [Henrique Arthur](https://github.com/henriquearthur)) packages.

## 🆕 What's New

---

## 🧾 Guide
#### 1. Setup the config file

Add your Flutter app name, app package, app icon configuration to your `pubspec.yaml` or create a new config file called `flutter_package_name_icon.yaml`. 
```yaml
dev_dependencies: 
  flutter_package_name_icon:
    git: git://github.com/devibrahimkarahan/flutter_package_name_icon.git

flutter_package_name_icon:
  name: "App name"
  package: "com.your.package"
  flutter_icons:
    image_path: "assets/my_launcher_icon.png"
    android: true
    ios: true
```
For more attributes of flutter_icons: [flutter_launcher_icons]

If you name your configuration file something other than `flutter_package_name_icon.yaml` or `pubspec.yaml` you will need to specify the name of the file when running the package.

```
flutter pub get
flutter pub run flutter_package_name_icon:main -f <your config file name here>
```

Note: If you are not using the existing `pubspec.yaml` ensure that your config file is located in the same directory as it.

#### 2. Run the package

```
flutter pub get
flutter pub run flutter_package_name_icon:main
```

The package will replace necessary fields on iOS and Android folders what you define.

## 🔎  Attributes
Shown below is the full list of attributes which you can specify within your Flutter Launcher name configuration.

- `name`: New name of application
- `package`: New **packageName/bundleId** of application
- `flutter_icons`: Application icons configuration, See [details](https://github.com/fluttercommunity/flutter_launcher_icons#mag-attributes)

 [flutter_launcher_icons]: <https://github.com/fluttercommunity/flutter_launcher_icons>
 [flutter_native_splash]: <https://github.com/henriquearthur/flutter_native_splash>