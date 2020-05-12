//
//  NativeHTMLFactory.swift
//  flutter_native_html_view
//
//  Created by Khuram Khalid on 22/02/2020.
//

import Foundation
import WebKit

class NativeHTMLFactory: NSObject, FlutterPlatformViewFactory {
    
    var nativeHTMLView:NativeHTMLView?
    
    var registrar:FlutterPluginRegistrar?
    
    private var messenger:FlutterBinaryMessenger
    
    /* register video player */
    static func register(with registrar: FlutterPluginRegistrar) {
        
        let plugin = NativeHTMLFactory(messenger: registrar.messenger())
        
        plugin.registrar = registrar
        
        registrar.register(plugin, withId: "tv.mta/NativeHTMLView")
    }
    
    init(messenger:FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        
        self.nativeHTMLView = NativeHTMLView(frame: frame, viewId: viewId, messenger: messenger, args: args)
        
        self.registrar?.addApplicationDelegate(self.nativeHTMLView!)
        
        return self.nativeHTMLView!
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterJSONMessageCodec()
    }
    
    public func applicationDidEnterBackground() {}
    
    public func applicationWillEnterForeground() {}
}

class NativeHTMLView: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterPlatformView, WKNavigationDelegate {
    
    static func register(with registrar: FlutterPluginRegistrar) { }
    
    /* view specific properties */
    var frame:CGRect
    var viewId:Int64
    
    /* Flutter event streamer properties */
    private var eventChannel:FlutterEventChannel?
    private var flutterEventSink:FlutterEventSink?
    
    private var nativeWebView:WKWebView?
    private var htmlData:String
    private var shouldShowScroll : Bool
    
    deinit {
        print("[dealloc] tv.mta/NativeVideoPlayer")
    }
    
    init(frame:CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
        
        /* set view properties */
        self.frame = frame
        self.viewId = viewId
        
        /* data as JSON */
        let parsedData = args as! [String: Any]
        
        /* set incoming html data */
        self.htmlData = parsedData["data"] as! String
        self.shouldShowScroll = parsedData["shouldShowScroll"] as! Bool
        
        super.init()
        
        setupEventChannel(viewId: viewId, messenger: messenger, instance: self)
        
        setupMethodChannel(viewId: viewId, messenger: messenger)
    }
    
    /* set Flutter event channel */
    private func setupEventChannel(viewId: Int64, messenger:FlutterBinaryMessenger, instance:NativeHTMLView) {
        
        /* register for Flutter event channel */
        instance.eventChannel = FlutterEventChannel(name: "tv.mta/NativeHTMLViewEventChannel_" + String(viewId), binaryMessenger: messenger, codec: FlutterJSONMethodCodec.sharedInstance())
        
        instance.eventChannel!.setStreamHandler(instance)
    }
    
    /* set Flutter method channel */
    private func setupMethodChannel(viewId: Int64, messenger:FlutterBinaryMessenger) {
        
        let nativeMethodsChannel = FlutterMethodChannel(name: "tv.mta/NativeHTMLViewMethodChannel_" + String(viewId), binaryMessenger: messenger);
        
        nativeMethodsChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            if ("onDataChanged" == call.method) {
                
                /* data as JSON */
                let parsedData = call.arguments as! [String: Any]
                
                /* set incoming html data properties */
                let data = parsedData["data"] as! String
                
                self.onDataChanged(data: data)
            }
                
                /* not implemented yet */
            else { result(FlutterMethodNotImplemented) }
        })
    }
    
    /* create html native view */
    func view() -> UIView {
        
        self.nativeWebView = WKWebView()
        
        if(!self.shouldShowScroll) {
            nativeWebView!.scrollView.showsHorizontalScrollIndicator = false
            nativeWebView!.scrollView.showsVerticalScrollIndicator = false
        }
        
        nativeWebView!.backgroundColor = UIColor.clear
        
        nativeWebView!.loadHTMLString(self.htmlData, baseURL: nil)
        
        self.nativeWebView?.navigationDelegate = self
        
        return nativeWebView!
    }
    
    func onDataChanged(data:String) {
        
        self.nativeWebView?.loadHTMLString(data, baseURL: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url {
            
            if (url.absoluteString.starts(with: "http")) {
                
                onLinkOpened(url: url.absoluteString)
                
                decisionHandler(.cancel)
                
            } else {
                
                decisionHandler(.allow)
            }
            
        } else {
            
            decisionHandler(.allow)
        }
    }
    
    func onLinkOpened(url:String) -> Void {
        self.flutterEventSink?(["event":"onLinkOpened", "url": url])
    }
    
    func onError(message:String) -> Void {
        self.flutterEventSink?(["event":"onError", "message": message])
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        flutterEventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        flutterEventSink = nil
        return nil
    }
    
    /**
     detach player UI to keep audio playing in background
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    /**
     reattach player UI as app is in foreground now
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
}
