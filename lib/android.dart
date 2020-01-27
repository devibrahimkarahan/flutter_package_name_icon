import 'dart:io';

const String _mainFolder = "android/app/src/main";
const String _manifestFilePath = "$_mainFolder/AndroidManifest.xml";
const String _debugManifestFilePath =
    "android/app/src/debug/AndroidManifest.xml";
const String _profileManifestFilePath =
    "android/app/src/profile/AndroidManifest.xml";
const String _appBuildGradle = "android/app/build.gradle";
const String _mainActivityName = "MainActivity";

void updateAppName(String name) {
  final File manifestFile = File(_manifestFilePath);
  final List<String> lines = manifestFile.readAsLinesSync();
  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];
    if (line.contains(RegExp('android:label=("|\')[^("|\')]*("|\')'))) {
      line = line.replaceAll(
        RegExp('android:label=("|\')[^("|\')]*("|\')'),
        'android:label="$name"',
      );
      lines[x] = line;
      manifestFile.writeAsString(lines.join("\n"));
      print("[ANDROID] App name was changed");
      return;
    }
  }
}

void updatePackageName(String package) {
  _updatePackageNameByFile(_manifestFilePath, package);
  _updatePackageNameByFile(_debugManifestFilePath, package);
  _updatePackageNameByFile(_profileManifestFilePath, package);
  _updatePackageNameByFile(_appBuildGradle, package);
  _updatePackageNameIntoMainActivity(package);
  _updateFolderStructure(package);
}

String _getMainActivityPath() {
  final Directory mainFolder = Directory(_mainFolder);
  String path;
  mainFolder
      .listSync(recursive: true)
      .where((f) => !f.path.contains(r"\res") && f is File)
      .forEach((f) {
    if (f.path.toLowerCase().contains(_mainActivityName.toLowerCase())) {
      path = f.path;
      return;
    }
  });
  return path;
}

void _updatePackageNameIntoMainActivity(String package) {
  final File maFile = File(_getMainActivityPath());
  if (maFile == null) {
    throw "$_mainActivityName was not found";
  }
  final List<String> lines = maFile.readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i];
    if (line.startsWith("package")) {
      lines[i] = "package $package";
      maFile.writeAsStringSync(lines.join("\n"));
      break;
    }
  }
  print("[ANDROID] Package name updated into $_mainActivityName");
}

void _updateFolderStructure(String package) {
  package = package.replaceAll(r".", r"\");
  final String maPath = _getMainActivityPath();
  final String kotlinOrJava = maPath.contains("kotlin") ? "kotlin" : "java";
  final Directory maDir =
      Directory(maPath.substring(0, maPath.lastIndexOf(r"\")));
  final String oldPackage =
      maDir.path.replaceFirst("$_mainFolder\\$kotlinOrJava\\", "");
  final String newPath = "$_mainFolder\\$kotlinOrJava\\$package";
  if (package.toLowerCase() == oldPackage.toLowerCase()) {
    print("[ANDROID] Package name is same");
    return;
  }
  if (oldPackage.contains(package)) {
    maDir.listSync().forEach((f) {
      f.renameSync(f.path.replaceFirst(maDir.path, newPath));
    });
    maDir.deleteSync();
    print("[ANDROID] Folder structure updated");
    return;
  }
  Directory(newPath).createSync(recursive: true);
  if (package.contains(oldPackage)) {
    maDir.listSync().forEach((f) {
      if (!f.path.contains(package)) {
        f.renameSync(f.path.replaceFirst(maDir.path, newPath));
      }
    });
    print("[ANDROID] Folder structure updated");
    return;
  }
  final packageLetters = package.split("\\");
  final oldPackageLetters = oldPackage.split("\\");
  maDir.renameSync(newPath);
  for (int i = 0; i < oldPackageLetters.length; i++) {
    if (packageLetters[i] != oldPackageLetters[i]) {
      final dir = Directory(
          "$_mainFolder\\$kotlinOrJava\\${oldPackageLetters.getRange(0, i + 1).join(r"\")}");
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
        break;
      }
    }
  }
  print("[ANDROID] Folder structure updated");
}

void _updatePackageNameByFile(String path, String package) {
  final File file = File(path);
  if (file.existsSync()) {
    final List<String> lines = file.readAsLinesSync();
    for (int x = 0; x < lines.length; x++) {
      String line = lines[x];
      if (line.contains(RegExp("package *="))) {
        line = line.replaceAll(
          RegExp('package=("|\')[^("|\')]*("|\')'),
          'package="$package"',
        );
        lines[x] = line;
        file.writeAsString(lines.join("\n"));
        print("[ANDROID-MANIFEST] Package was changed");
        return;
      } else if (line.contains("applicationId")) {
        final String preTag = line.split("applicationId")[0];
        line = line.replaceAll(
          RegExp('.*applicationId ?("|\').*("|\')'),
          '${preTag}applicationId "$package"',
        );
        lines[x] = line;
        file.writeAsString(lines.join("\n"));
        print("[ANDROID-BUILD-GRADLE] Package was changed");
        return;
      }
    }
  } else {
    print("$path was not found");
  }
}
