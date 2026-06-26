import 'package:flutter_inappwebview/flutter_inappwebview.dart';
void test() {
  HeadlessInAppWebView(
    initialData: InAppWebViewInitialData(data: "<html></html>"),
    initialSettings: InAppWebViewSettings(mediaPlaybackRequiresUserGesture: false),
  );
}
