package tv.mta.flutter_native_html_view;

import android.content.Context;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.JSONMessageCodec;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.flutter.view.FlutterNativeView;

public class WebViewFactory extends PlatformViewFactory {

    private WebViewNative webView;

    private BinaryMessenger messenger;

    private final Context context;

    /**
     * Flutter Android v1 API
     *
     * @param registrar
     * @return
     */
    protected static WebViewFactory registerWith(PluginRegistry.Registrar registrar) {

        final WebViewFactory plugin = new WebViewFactory(registrar.messenger(), registrar.activity());

        registrar.platformViewRegistry().registerViewFactory("tv.mta/NativeHTMLView", plugin);

        registrar.addViewDestroyListener(new PluginRegistry.ViewDestroyListener() {
            @Override
            public boolean onViewDestroy(FlutterNativeView view) {
                plugin.onDestroy();
                return false;
            }
        });

        return plugin;
    }

    /**
     * Flutter Android v2 API
     *
     * @param flutterPluginBinding
     * @return
     */
    protected static WebViewFactory registerWith(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {

        final WebViewFactory plugin = new WebViewFactory(flutterPluginBinding.getBinaryMessenger(),
                flutterPluginBinding.getApplicationContext());

        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory(
                "tv.mta/NativeHTMLView", plugin);

        return plugin;
    }

    private WebViewFactory(BinaryMessenger messenger, Context context) {

        super(JSONMessageCodec.INSTANCE);

        this.context = context;

        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int id, Object args) {

        this.webView = new WebViewNative(context, this.messenger, id, args);

        return webView;
    }

    public void onDestroy() {

        if (webView != null) {

            webView.dispose();
        }
    }
}
