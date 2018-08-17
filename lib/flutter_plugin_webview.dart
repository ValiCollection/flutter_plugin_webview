import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'webview_state.dart';

export 'webview_state.dart';

class WebViewPlugin {
  static const _channel = const MethodChannel('flutter_plugin_webview');

  static WebViewPlugin _instance;

  static WebViewPlugin getInstance() => _instance ??= WebViewPlugin._();

  final _onStateChanged = StreamController<WebViewState>.broadcast();

  WebViewPlugin._() {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  Future _onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'onStateChange':
        WebViewState state =
            WebViewState.fromMap(Map<String, dynamic>.from(call.arguments));
        _onStateChanged.add(state);
        break;
    }

    return null;
  }

  /// Listening the onState Event for WebView
  /// content is Map for type: {LoadStarted, LoadFinished, Idle, Error, Closed}
  Stream<WebViewState> get onStateChanged => _onStateChanged.stream;

  /// Listen to closed events
  Stream<WebViewStateEventClosed> get onCloseEvent => _onStateChanged.stream
      .where((state) => state.event is WebViewStateEventClosed)
      .map((state) => state.event as WebViewStateEventClosed);

  /// Listening to error events
  Stream<WebViewStateEventError> get onErrorEvent => _onStateChanged.stream
      .where((state) => state.event is WebViewStateEventError)
      .map((state) => state.event as WebViewStateEventError);

  /// Listening to url change events
  Stream<WebViewStateEventUrlChange> get onUrlChange => _onStateChanged.stream
      .where((state) => state.event is WebViewStateEventUrlChange)
      .map((state) => state.event as WebViewStateEventUrlChange)
      .distinct((prev, next) => prev.url == next.url);

  /// Start the WebView with [url]
  /// - [headers] specify additional HTTP headers
  /// - [enableJavaScript] enable/disable javaScript inside WebView
  ///     iOS WebView: Not implemented yet
  /// - [clearCache] clear WebView cache
  /// - [clearCookies] clear WebView cookies
  /// - [rect]: show in rect, fullscreen if null
  /// - [userAgent]: set the User-Agent of WebView
  /// - [enableLocalStorage] enable/disable localStorage API on WebView
  ///     for iOS supports iOS <= 9.0, for iOS < 9.0 enabled by default
  /// - [enableScroll]: enable/disable enableScroll
  /// - [enableSwipeToRefresh]: enable/disable Swipe to Refresh
  ///     iOS WIP
  /// - [enableNavigationOutsideOfHost]: enable/disable navigation outside of url host
  Future launch(
    String url, {
    Map<String, String> headers,
    bool enableJavaScript = true,
    bool clearCache = false,
    bool clearCookies = false,
    Rect rect,
    String userAgent,
    bool enableLocalStorage = true,
    bool enableScroll = true,
    bool enableSwipeToRefresh = false,
    bool enableNavigationOutsideOfHost = false,
  }) {
    final args = _createParams(
      url,
      headers,
      enableJavaScript,
      clearCache,
      clearCookies,
      rect,
      userAgent,
      enableLocalStorage,
      enableScroll,
      enableSwipeToRefresh,
      enableNavigationOutsideOfHost,
    );

    return _channel.invokeMethod('launch', args);
  }

  /// Reload the WebView with [url] and new parameters
  /// - [headers] specify additional HTTP headers
  /// - [enableJavaScript] enable/disable javaScript inside WebView
  ///     iOS WebView: Not implemented yet
  /// - [clearCache] clear WebView cache
  /// - [clearCookies] clear WebView cookies
  /// - [rect]: show in rect, fullscreen if null
  /// - [userAgent]: set the User-Agent of WebView
  /// - [enableLocalStorage] enable localStorage API on WebView
  ///     for iOS supports iOS <= 9.0, for iOS < 9.0 enabled by default
  /// - [enableScroll]: enable or disable enableScroll
  /// - [enableSwipeToRefresh]: enable or disable Swipe to Refresh
  ///     iOS WIP
  /// - [enableNavigationOutsideOfHost]: enable or disable navigation outside of url host
  Future reload(
    String url, {
    Map<String, String> headers,
    bool enableJavaScript = true,
    bool clearCache = false,
    bool clearCookies = false,
    Rect rect,
    String userAgent,
    bool enableLocalStorage = true,
    bool enableScroll = true,
    bool enableSwipeToRefresh = false,
    bool enableNavigationOutsideOfHost = false,
  }) {
    final args = _createParams(
      url,
      headers,
      enableJavaScript,
      clearCache,
      clearCookies,
      rect,
      userAgent,
      enableLocalStorage,
      enableScroll,
      enableSwipeToRefresh,
      enableNavigationOutsideOfHost,
    );

    return _channel.invokeMethod('reload', args);
  }

  Map<String, dynamic> _createParams(
    String url,
    Map<String, String> headers,
    bool enableJavaScript,
    bool clearCache,
    bool clearCookies,
    Rect rect,
    String userAgent,
    bool enableLocalStorage,
    bool enableScroll,
    bool enableSwipeToRefresh,
    bool enableNavigationOutsideOfHost,
  ) {
    final args = <String, dynamic>{
      'url': url,
      'enableJavaScript': enableJavaScript ?? true,
      'clearCache': clearCache ?? false,
      'clearCookies': clearCookies ?? false,
      'userAgent': userAgent,
      'enableLocalStorage': enableLocalStorage ?? true,
      'enableScroll': enableScroll ?? true,
      'enableSwipeToRefresh': enableSwipeToRefresh ?? false,
      'headers': headers,
      'enableNavigationOutsideOfHost': enableNavigationOutsideOfHost ?? false
    };

    if (rect != null) {
      args['rect'] = {
        'left': rect.left,
        'top': rect.top,
        'width': rect.width,
        'height': rect.height
      };
    }

    return args;
  }

  /// Open the url.
  /// - [headers] specify additional HTTP headers
  /// - [enableNavigationOutsideOfHost]: enable or disable navigation outside of url host
  Future openUrl(
    String url, {
    Map<String, String> headers,
    bool enableNavigationOutsideOfHost = false,
  }) =>
      _channel.invokeMethod(
        'openUrl',
        {
          'url': url,
          'headers': headers,
          'enableNavigationOutsideOfHost': enableNavigationOutsideOfHost
        },
      );

  /// Execute Javascript inside WebView
  Future<String> evalJavascript(String code) {
    final res = _channel.invokeMethod('eval', {'code': code});
    return res;
  }

  /// Stop loading WebView
  Future stopLoading() => _channel.invokeMethod('stopLoading');

  /// Close the WebView
  Future close() => _channel.invokeMethod('close');

  /// Reloads the WebView.
  Future refresh() => _channel.invokeMethod('refresh');

  /// Checks if WebView has back route
  Future hasBack() => _channel.invokeMethod('hasBack');

  /// Navigates back on the WebView.
  Future back() => _channel.invokeMethod('back');

  /// Checks if WebView has forward route
  Future hasForward() => _channel.invokeMethod('hasForward');

  /// Navigates forward on the WebView.
  Future forward() => _channel.invokeMethod('forward');

  /// Clears all cookies of WebView
  Future clearCookies() => _channel.invokeMethod("clearCookies");

  /// Clears WebView cache
  Future clearCache() => _channel.invokeMethod("clearCache");

  /// Get cookies from webview
//  Future<Map<String, String>> getCookies() async {
//    final cookiesString = await evalJavascript('document.cookie');
//    final cookies = <String, String>{};
//
//    if (cookiesString?.isNotEmpty == true) {
//      cookiesString.split(';').forEach((String cookie) {
//        final split = cookie.split('=');
//        cookies[split[0]] = split[1];
//      });
//    }
//
//    return cookies;
//  }

  /// Resize WebView
  Future resize(Rect rect) {
    final args = {};
    args['rect'] = {
      'left': rect.left,
      'top': rect.top,
      'width': rect.width,
      'height': rect.height
    };
    return _channel.invokeMethod('resize', args);
  }

  /// Disposes all Streams and closes WebView
  void dispose() async {
    await close();
    _onStateChanged.close();
    _instance = null;
  }
}
