import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mseva_punjab/theme/app_theme.dart';
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
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _checkAndPromptLocationServices();
    _requestPermissions();
  }

  Future<void> _checkAndPromptLocationServices() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      await showDialog<void>(
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
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  Future<void> _checkToken() async {
    if (_webViewController == null || !mounted) return;

    try {
      final tokenResult = await _webViewController!.evaluateJavascript(
        source: "localStorage.getItem('token')",
      );

      if (mounted && tokenResult != null && tokenResult.toString().isNotEmpty) {
        setState(() => hasAccessToken = true);
      } else if (mounted) {
        setState(() => hasAccessToken = false);
      }
    } catch (e) {
      debugPrint('Token check error: $e');
    }
  }

  Future<bool> _onBackPressed() async {
    if (!hasAccessToken) return true;

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Exit?'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!mounted) return;
        if (await _onBackPressed() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: hasAccessToken
            ? null
            : AppBar(
                title: Text(widget.pageTitle),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
        body: Stack(
          children: [
            InAppWebView(
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
              initialUrlRequest: URLRequest(url: WebUri(widget.pageUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                allowsInlineMediaPlayback: true,
                mediaPlaybackRequiresUserGesture: false,
                useOnDownloadStart: true,
                allowsBackForwardNavigationGestures: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStop: (controller, url) async {
                setState(() => isLoading = false);
                await Future<void>.delayed(const Duration(seconds: 2));
                _checkToken();
              },
              onUpdateVisitedHistory: (controller, url, androidIsReload) async {
                await Future<void>.delayed(const Duration(milliseconds: 500));
                _checkToken();
              },
              onGeolocationPermissionsShowPrompt: (controller, origin) async {
                return GeolocationPermissionShowPromptResponse(
                  origin: origin,
                  allow: true,
                  retain: true,
                );
              },
              onDownloadStartRequest: (controller, downloadStartRequest) async {
                final downloadUrl = downloadStartRequest.url.toString();
                if (await canLaunchUrl(Uri.parse(downloadUrl))) {
                  await launchUrl(
                    Uri.parse(downloadUrl),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
            if (isLoading)
              ColoredBox(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/mSeva.jpg',
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(
                        color: AppColors.blue,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loading...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.lightGrey,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
