#import "FlutterNativeHtmlViewPlugin.h"
#if __has_include(<flutter_native_html_view/flutter_native_html_view-Swift.h>)
#import <flutter_native_html_view/flutter_native_html_view-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_native_html_view-Swift.h"
#endif

@implementation FlutterNativeHtmlViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterNativeHtmlViewPlugin registerWithRegistrar:registrar];
}
@end
