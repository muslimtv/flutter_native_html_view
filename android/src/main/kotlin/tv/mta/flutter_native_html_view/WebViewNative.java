package tv.mta.flutter_native_html_view;

import android.content.Context;
import android.view.View;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import org.jetbrains.annotations.NotNull;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class WebViewNative implements PlatformView, EventChannel.StreamHandler,
        MethodChannel.MethodCallHandler {

    private WebView webView;

    private EventChannel.EventSink eventSink;

    private MethodChannel methodChannel;

    public WebViewNative(Context context, BinaryMessenger messenger, int viewId, Object arguments) {

        try {

            JSONObject args = (JSONObject) arguments;

            String htmlData = args.getString("data");

            webView = new WebView(context);

            webView.getSettings().setJavaScriptEnabled(true);

            webView.setWebViewClient(new WebViewClient() {

                @Override
                public boolean shouldOverrideUrlLoading(WebView  view, String  url) {

                    /* always handle link tap events in dart */
                    if (url.startsWith("http")) {

                        /* send link url to dart for processing */
                        onLinkOpened(url);

                        return true;
                    }

                    return false;
                }

                @Override
                public void onLoadResource(WebView  view, String  url) {
                    super.onLoadResource(view, url);
                }
            });

            if (htmlData != null && !htmlData.isEmpty()) {

                webView.loadData(htmlData, "text/html", "UTF-8");

            }

            this.methodChannel = new MethodChannel(messenger,
                    "tv.mta/NativeHTMLViewMethodChannel_" + viewId);
            this.methodChannel.setMethodCallHandler(this);

            /* open an event channel */
            new EventChannel(
                    messenger,
                    "tv.mta/NativeHTMLViewEventChannel_" + viewId,
                    JSONMethodCodec.INSTANCE).setStreamHandler(this);

        } catch (Exception e) { /* ignore */ }
    }

    @Override
    public void onMethodCall(MethodCall call, @NotNull MethodChannel.Result result) {

        if (call.method.equals("onDataChanged")) {

            onDataChanged(call.arguments);

            result.success(true);

        } else {

            result.notImplemented();
        }
    }

    private void onDataChanged(Object arguments) {

        try {

            if (arguments instanceof HashMap) {

                HashMap<String, Object> args = (HashMap<String, Object>) arguments;

                String htmlData = args.get("data").toString();

                if (!htmlData.isEmpty() && this.webView != null) {

                    this.webView.loadData(htmlData, "text/html", "UTF-8");
                }
            }

        } catch (Exception e) {

            onError(e.getMessage());
        }
    }

    private void onLinkOpened(String url) {

        try {

            if (eventSink != null) {

                JSONObject message = new JSONObject();

                message.put("event", "onLinkOpened");

                message.put("url", url);

                eventSink.success(message);
            }

        } catch (JSONException e) {

            onError(e.getMessage());
        }
    }

    private void onError(String errorMessage) {

        try {

            if (eventSink != null) {

                JSONObject message = new JSONObject();

                message.put("event", "onError");

                message.put("message", errorMessage);

                eventSink.success(message);
            }

        } catch (JSONException e) {/* ignore */}
    }

    @Override
    public View getView() {
        return webView;
    }

    @Override
    public void dispose() {

        if (webView != null) {

            webView.destroy();
        }

        if (this.methodChannel != null) {

            this.methodChannel.setMethodCallHandler(null);
        }
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.eventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        this.eventSink = null;
    }
}
