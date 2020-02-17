import 'dart:io';

const String _pFilePath = "ios/Runner/Info.plist";
const String _pbXProjPath = "ios/Runner.xcodeproj/project.pbxproj";
const String _bundleIDKey = "PRODUCT_BUNDLE_IDENTIFIER";

void updateAppName(String name) {
  final File pFile = File(_pFilePath);
  final List<String> lines = pFile.readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i];
    if (line.contains("CFBundleName")) {
      final String preTag = lines[i + 1].split(r"<string>")[0];
      lines[i + 1] = "$preTag<string>$name</string>";
      pFile.writeAsStringSync(lines.join("\n"));
      print("[IOS] App name was changed");
      return;
    }
  }
}

void updateBundleId(String bundleId) {
  final File pbXFile = File(_pbXProjPath);
  final List<String> lines = pbXFile.readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i];
    if (line.contains(_bundleIDKey)) {
      final String preTag = lines[i].split(_bundleIDKey)[0];
      lines[i] = '$preTag$_bundleIDKey = "$bundleId";';
      pbXFile.writeAsStringSync(lines.join("\n"));
    }
  }
  print("[IOS] Bundle ID was updated");
}
