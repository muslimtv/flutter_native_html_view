# flutter_native_html_view

A flutter plugin for rendering local HTML string data using web views. Uses WebView on Android and WKWebView on iOS.

## Getting Started

Use the `FlutterNativeHtmlView` widget as below:

```dart
class MyApp extends StatelessWidget {
  String _htmlString = 'some html data here';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native HTML View'),
        ),
        body: FlutterNativeHtmlView(
          htmlData: _htmlString,
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
```