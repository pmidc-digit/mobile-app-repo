import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewBodyLoad extends StatefulWidget {
  final String pageTitle;
  final String pageUrl;
  final bool headerFooterRequired;

  const WebViewBodyLoad({
    super.key,
    required this.pageTitle,
    required this.pageUrl,
    required this.headerFooterRequired,
  });

  @override
  State<WebViewBodyLoad> createState() => _WebViewBodyLoadState();
}

class _WebViewBodyLoadState extends State<WebViewBodyLoad> {
  bool isLoading = true;
  bool hasAccessToken = false;
  bool wasLoggedIn = false;
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    try {
      await _requestPermissions();
      if (mounted) {
        await _checkAndPromptLocationServices();
      }
    } catch (e) {
      debugPrint('Permission initialization error: $e');
    }
  }

  Future<void> _checkAndPromptLocationServices() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Enable Location Services'),
            content: const Text(
              'Location services are required for this feature. Please enable them in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Geolocator.openLocationSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Location service check error: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await Permission.location.request();
      await Permission.camera.request();
      await Permission.microphone.request();

      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.request();
        if (!photosStatus.isGranted) {
          await Permission.storage.request();
        }
      }
    } catch (e) {
      debugPrint('Request permissions error: $e');
    }
  }

  void _handleLogout() {
    if (!mounted || !wasLoggedIn) return;
    debugPrint('Logging out and returning to main screen...');
    wasLoggedIn = false;
    hasAccessToken = false;

    // Use addPostFrameCallback to avoid unmounting PlatformView during active native JNI dispatch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  bool _isLogoutUrl(String url) {
    if (!wasLoggedIn) return false;
    final lower = url.toLowerCase();
    // Only detect explicit logout actions, never standard login/dashboard pages
    return lower.contains('/logout') ||
        lower.contains('user/logout') ||
        lower.contains('action=logout');
  }

  Future<void> _checkToken() async {
    if (_webViewController == null || !mounted) return;

    try {
      const jsCode = """
        (function() {
          try {
            var keys = [
              'token',
              'Citizen.token',
              'Employee.token',
              'citizen.token',
              'employee.token',
              'auth-token',
              'token-id'
            ];
            for (var i = 0; i < keys.length; i++) {
              var val = localStorage.getItem(keys[i]);
              if (val && val !== 'null' && val !== 'undefined' && val.trim() !== '') {
                return true;
              }
            }
            var userKeys = ['User', 'Citizen.user-info', 'Employee.user-info'];
            for (var j = 0; j < userKeys.length; j++) {
              var s = sessionStorage.getItem(userKeys[j]) || localStorage.getItem(userKeys[j]);
              if (s && s !== 'null' && s !== 'undefined') {
                try {
                  var parsed = JSON.parse(s);
                  if (parsed && (parsed.access_token || parsed.token)) {
                    return true;
                  }
                } catch(e) {}
              }
            }
            return false;
          } catch(e) {
            return false;
          }
        })();
      """;

      final dynamic result =
          await _webViewController!.evaluateJavascript(source: jsCode);
      final bool loggedIn = result == true || result == 'true';

      if (!mounted) return;

      // Update state without forcefully popping the route during navigation
      if (loggedIn != hasAccessToken) {
        setState(() {
          hasAccessToken = loggedIn;
          if (loggedIn) {
            wasLoggedIn = true;
          }
        });
      }
    } catch (e) {
      debugPrint('Token check error: $e');
    }
  }

  Future<void> _launchExternal(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No app available to open: ${uri.scheme}')),
        );
      }
    } catch (e) {
      debugPrint('External launch error for $uri: $e');
    }
  }

  Future<bool> _handlePop() async {
    if (_webViewController != null && await _webViewController!.canGoBack()) {
      await _webViewController!.goBack();
      return false; // Handled internally within the webview
    }

    if (hasAccessToken) {
      if (!mounted) return false;
      final bool? confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Confirm Exit'),
          content: const Text(
            'Are you sure you want to return to the home screen?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      return confirm ?? false;
    }

    return true; // Allow pop if not logged in
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) return;
          final allowPop = await _handlePop();
          if (allowPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: !hasAccessToken
              ? AppBar(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  title: Text(
                    widget.pageTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () async {
                      final allowPop = await _handlePop();
                      if (allowPop && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Home',
                      icon: const Icon(Icons.home),
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                )
              : null,
          body: SafeArea(
            top: true,
            bottom: true,
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(widget.pageUrl),
                  ),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    allowsInlineMediaPlayback: true,
                    mediaPlaybackRequiresUserGesture: false,
                    useOnDownloadStart: true,
                    allowsBackForwardNavigationGestures: true,
                    domStorageEnabled: true,
                    databaseEnabled: true,
                    thirdPartyCookiesEnabled: true,
                    sharedCookiesEnabled: true,
                    geolocationEnabled: true,
                    cacheEnabled: true,
                    useHybridComposition: true,
                    supportMultipleWindows: false,
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onPermissionRequest: (controller, request) async {
                    final grantedResources = <PermissionResourceType>[];
                    for (final resource in request.resources) {
                      if (resource == PermissionResourceType.CAMERA) {
                        final status = await Permission.camera.request();
                        if (status.isGranted) grantedResources.add(resource);
                      } else if (resource ==
                          PermissionResourceType.MICROPHONE) {
                        final status = await Permission.microphone.request();
                        if (status.isGranted) grantedResources.add(resource);
                      } else {
                        grantedResources.add(resource);
                      }
                    }

                    return PermissionResponse(
                      resources: grantedResources,
                      action: grantedResources.isNotEmpty
                          ? PermissionResponseAction.GRANT
                          : PermissionResponseAction.DENY,
                    );
                  },
                  onGeolocationPermissionsShowPrompt:
                      (controller, origin) async {
                    try {
                      var status = await Permission.location.status;
                      if (!status.isGranted) {
                        status = await Permission.location.request();
                      }
                      return GeolocationPermissionShowPromptResponse(
                        origin: origin,
                        allow: status.isGranted,
                        retain: true,
                      );
                    } catch (e) {
                      debugPrint('Geolocation prompt error: $e');
                      return GeolocationPermissionShowPromptResponse(
                        origin: origin,
                        allow: false,
                        retain: false,
                      );
                    }
                  },
                  onLoadStop: (controller, url) async {
                    if (!mounted) return;
                    setState(() {
                      isLoading = false;
                    });

                    final urlStr = url?.toString() ?? '';
                    if (wasLoggedIn && _isLogoutUrl(urlStr)) {
                      _handleLogout();
                      return;
                    }

                    await Future.delayed(const Duration(seconds: 1));
                    _checkToken();
                  },
                  onUpdateVisitedHistory:
                      (controller, url, androidIsReload) async {
                    final urlStr = url?.toString() ?? '';
                    if (wasLoggedIn && _isLogoutUrl(urlStr)) {
                      _handleLogout();
                      return;
                    }

                    await Future.delayed(const Duration(milliseconds: 500));
                    _checkToken();
                  },
                  onRenderProcessGone: (controller, detail) async {
                    debugPrint(
                      'WebView render process gone: didCrash=${detail.didCrash}',
                    );
                    if (mounted) {
                      controller.reload();
                    }
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    final uri = navigationAction.request.url;
                    if (uri == null) return NavigationActionPolicy.ALLOW;
                    final scheme = uri.scheme.toLowerCase();
                    const webSchemes = {
                      'http',
                      'https',
                      'about',
                      'data',
                      'blob',
                      'javascript',
                      'file',
                    };
                    if (webSchemes.contains(scheme)) {
                      return NavigationActionPolicy.ALLOW;
                    }
                    // tel:, mailto:, sms:, upi:, intent:, whatsapp:, etc.
                    await _launchExternal(uri);
                    return NavigationActionPolicy.CANCEL;
                  },
                  onReceivedError: (controller, request, error) {
                    debugPrint(
                      'WebView error: ${error.description} (${error.type})',
                    );
                    if (request.isForMainFrame != false &&
                        mounted &&
                        isLoading) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  onDownloadStartRequest:
                      (controller, downloadStartRequest) async {
                    await _launchExternal(downloadStartRequest.url);
                  },
                ),
                if (isLoading)
                  Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: hasAccessToken
              ? FloatingActionButton.small(
                  tooltip: 'Home',
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Return to Home'),
                        content: const Text(
                          'Do you want to return to the home screen?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: const Icon(Icons.home),
                )
              : null,
        ),
      ),
    );
  }
}
