import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

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
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
   _checkAndPromptLocationServices();
   _requestPermissions();

  }

  Future<void> _checkAndPromptLocationServices() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled && mounted) {
    // Show dialog to explain why location is needed
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enable Location Services'),
        content: Text('Location services are required for this feature. Please enable them in settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openLocationSettings(); // Opens device location settings
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}


Future<void> _requestPermissions() async {
 // await Permission.location.request();
  await Permission.camera.request();
  // await Permission.microphone.request();

  if (Platform.isAndroid) {
    if (Platform.version.compareTo('33') >= 0) {
      await Permission.photos.request();
    } else {
      await Permission.storage.request();
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: const Color(0xFF16222A),
      //   title: Text( widget.pageTitle, style: TextStyle(color: Colors.white),
      //   )
      //   ),
      body: Stack(
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
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStop: (controller, url) async {
              setState(() {
                isLoading = false;
              });
            },
            // Use the new, cross-platform geolocation callback
            onGeolocationPermissionsShowPrompt: (controller, origin) async {
              return GeolocationPermissionShowPromptResponse(
                origin: origin,
                allow: true,
                retain: true,
              );
            },
          ),
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
