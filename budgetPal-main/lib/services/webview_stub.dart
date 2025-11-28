// Stub for WebView on web builds
import 'package:flutter/widgets.dart';
class WebView extends StatelessWidget {
  final String initialUrl;
  final dynamic javascriptMode;
  const WebView({super.key, required this.initialUrl, this.javascriptMode});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('WebView not supported on web'));
  }
}
class JavascriptMode {
  static const unrestricted = null;
}
