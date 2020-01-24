import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_launcher_icons/main.dart' as flutter_launcher_icons;
import 'package:flutter_package_name_icon/android.dart' as android;
import 'package:flutter_package_name_icon/ios.dart' as ios;
import 'package:yaml/yaml.dart';

const String fileOption = "file";
const String defaultConfigFile = "flutter_package_name_icon.yaml";
const String yamlKey = "flutter_package_name_icon";
const String nameKey = "name";
const String packageKey = "package";
const String iconsKey = "flutter_icons";

void update(List<String> arguments) {
  final ArgResults argResults = getArgResults(arguments);

  final Map<String, dynamic> config = loadConfigFileFromArgResults(argResults);

  /// App Package name
  final String packageName = config["package"];
  if (packageName != null && packageName.isNotEmpty) {
    android.updatePackageName(packageName);
    ios.updateBundleId(packageName);
    return;
  }

  /// App Name
  final String appName = config["name"];
  if (appName != null && appName.isNotEmpty) {
    android.updateAppName(appName);
    ios.updateAppName(appName);
  }

  /// App Icon
  if (config[iconsKey] != null) {
    final Map<String, dynamic> iconsConfig = Map.from(config[iconsKey]);
    flutter_launcher_icons.createIconsFromConfig(iconsConfig);
  }
}

ArgResults getArgResults(List<String> arguments) {
  final ArgParser parser = ArgParser(allowTrailingOptions: true);
  parser.addOption(
    fileOption,
    abbr: 'f',
    help: 'Config file (default: $defaultConfigFile)',
  );
  final ArgResults argResults = parser.parse(arguments);
  return argResults;
}

Map<String, dynamic> loadConfigFileFromArgResults(ArgResults argResults) {
  final String configPath = argResults[fileOption];
  if (configPath != null && configPath != defaultConfigFile) {
    try {
      return loadConfigFile(configPath);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  try {
    return loadConfigFile(defaultConfigFile);
  } catch (e) {
    try {
      return loadConfigFile("pubspec.yaml");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

Map<String, dynamic> loadConfigFile(String path) {
  final File configFile = File(path);

  final String yamlString = configFile.readAsStringSync();
  final Map yamlMap = loadYaml(yamlString);

  if (yamlMap == null || !(yamlMap[yamlKey] is Map)) {
    throw Exception("$yamlKey was not found");
  }

  final Map<String, dynamic> config = <String, dynamic>{};
  for (MapEntry<dynamic, dynamic> entry in yamlMap[yamlKey].entries) {
    config[entry.key] = entry.value;
  }

  return config;
}
