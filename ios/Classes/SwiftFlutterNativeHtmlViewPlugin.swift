import Flutter
import UIKit

public class SwiftFlutterNativeHtmlViewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    NativeHTMLFactory.register(with: registrar)
  }
}
