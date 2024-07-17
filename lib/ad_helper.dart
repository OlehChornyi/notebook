import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-8753149445695098/9261001949";
    } else if (Platform.isIOS) {
      return "ca-app-pub-8753149445695098/7310761491";
    } else {
      throw  UnsupportedError("Unsupported platform");
    }
  }
}