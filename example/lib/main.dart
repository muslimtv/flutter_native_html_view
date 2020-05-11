import 'package:flutter/material.dart';
import 'package:flutter_native_html_view/flutter_native_html_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String _htmlString = 'some html data here';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native HTML View'),
        ),
        body: FlutterNativeHtmlView(
          htmlData: _htmlString,
          shouldShowScroll: false,
          onLinkTap: (String url) {
            print(url);
          },
          onError: (String message) {
            print(message);
          },
        ),
      ),
    );
  }
}
