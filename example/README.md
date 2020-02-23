# flutter_native_html_view_example

See below for usage example.

```dart
class MyApp extends StatelessWidget {
  String _htmlString =
      '<html><body>hello<details>\n<summary>\nSome explanation</summary>\n<p>'
      'This text will be hidden</p>\n</details><br/><a href="https://www.mta.tv"'
      '>www.mta.tv</a></body></html>';

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