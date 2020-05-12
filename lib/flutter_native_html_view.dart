import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterNativeHtmlView extends StatefulWidget {
  final String htmlData;
  final bool shouldShowScroll;
  final Function onViewCreated;
  final Function onLinkTap;
  final Function onError;

  const FlutterNativeHtmlView(
      {Key key,
      @required this.htmlData,
      this.onViewCreated,
      this.onLinkTap,
      this.shouldShowScroll = true,
      this.onError})
      : super(key: key);

  @override
  _FlutterNativeHtmlViewState createState() => _FlutterNativeHtmlViewState();
}

class _FlutterNativeHtmlViewState extends State<FlutterNativeHtmlView> {
  MethodChannel _methodChannel;
  Widget _htmlViewWidget = Container();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(FlutterNativeHtmlView oldWidget) {
    if (oldWidget.htmlData != widget.htmlData) {
      _onDataChanged(widget.htmlData, widget.shouldShowScroll);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    /* iOS */
    if (Platform.isIOS) {
      _htmlViewWidget = UiKitView(
        viewType: 'tv.mta/NativeHTMLView',
        creationParams: {
          "data": _constructHTMLData(widget.htmlData),
          "shouldShowScroll": widget.shouldShowScroll,
        },
        creationParamsCodec: const JSONMessageCodec(),
        onPlatformViewCreated: (viewId) {
          _onPlatformViewCreated(viewId);
          if (widget.onViewCreated != null) {
            widget.onViewCreated(viewId);
          }
        },
      );
    }

    /* Android */
    else {
      _htmlViewWidget = AndroidView(
        viewType: 'tv.mta/NativeHTMLView',
        creationParams: {
          "data": _constructHTMLData(widget.htmlData),
          "shouldShowScroll": widget.shouldShowScroll,
        },
        creationParamsCodec: const JSONMessageCodec(),
        onPlatformViewCreated: (viewId) {
          _onPlatformViewCreated(viewId);
          if (widget.onViewCreated != null) {
            widget.onViewCreated(viewId);
          }
        },
      );
    }

    return _htmlViewWidget;
  }

  void _onPlatformViewCreated(int viewId) {
    _methodChannel =
        MethodChannel("tv.mta/NativeHTMLViewMethodChannel_$viewId");
    _listenForNativeEvents(viewId);
  }

  void _onDataChanged(String data, bool shouldShowScroll) {
    _methodChannel?.invokeMethod(
      "onDataChanged",
      {
        "data": _constructHTMLData(data),
        "shouldShowScroll": shouldShowScroll,
      },
    );
  }

  void _listenForNativeEvents(int viewId) {
    EventChannel eventChannel = EventChannel(
        "tv.mta/NativeHTMLViewEventChannel_$viewId", JSONMethodCodec());
    eventChannel.receiveBroadcastStream().listen(_processNativeEvent);
  }

  void _processNativeEvent(dynamic event) async {
    if (event is Map) {
      String eventName = event["event"];

      switch (eventName) {
        case "onLinkOpened":
          if (widget.onLinkTap != null) {
            widget.onLinkTap(event["url"]);
          }
          break;

        case "onError":
          if (widget.onError != null) {
            widget.onError(event["message"]);
          }
          break;

        default:
          break;
      }
    }
  }

  String _webViewTextScaleFactorMeta = "<header><meta name='viewport' content='"
      "width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale="
      "1.0, user-scalable=no'></header>";

  String _constructHTMLData(String data) {
    String cleanHTML = data
        .replaceAll("<html>", "")
        .replaceAll("<body>", "")
        .replaceAll("</body>", "")
        .replaceAll("</html>", "");
    return "<html>" +
        _webViewTextScaleFactorMeta +
        "<body>" +
        cleanHTML +
        "</body></html>";
  }
}
