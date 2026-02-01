import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
 
  await Permission.location.request();
  await Permission.camera.request();
  await Permission.microphone.request();

}

Future<void> _checkToken() async {
  if (_webViewController == null || !mounted) return;
  
  try {
    final tokenResult = await _webViewController!.evaluateJavascript(
      source: "localStorage.getItem('token')"
    );
    
    //print('✅✅✅✅ Token found: $tokenResult');
    
    if (mounted && tokenResult != null && tokenResult.toString().isNotEmpty) {
      setState(() {
        hasAccessToken = true;  // Hide AppBar
      });
    }
    else{
      setState(() {
        hasAccessToken=false;
      });
    }
  } catch (e) {
    print('❌ Token check error: $e');
  }
 }

Future<bool> _onBackPressed() async {
  if (!hasAccessToken) return true;  // Allow normal back if not logged in

  bool? confirm = await showDialog<bool>(
    context: context,
    barrierDismissible: false,  // Prevent outside taps
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

  return confirm ?? false;  // Default to stay if dialog dismissed unexpectedly
}


  @override
  Widget build(BuildContext context) {

 return PopScope(
  canPop: false,  // Enable interception
  onPopInvokedWithResult: (bool didPop, Object? result) async {
    if (didPop) return;  // Already popped (rare)
    
    // Veto pop only if logged in by showing dialog
    if (await _onBackPressed()) {
      if (mounted) Navigator.of(context).pop();
    }
  },
  child:  Scaffold(
      appBar: !hasAccessToken  // Conditional: Hide if token exists
          ? AppBar(
              title: Text(widget.pageTitle),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          : null,
      body: Stack(
        children: [
          InAppWebView(
              onPermissionRequest: (controller, request) async {
              return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
             );
            },
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

             await Future.delayed(Duration(seconds: 2));  // Initial delay
             _checkToken();
            },
      
              // Check on every URL change (handles SPA navigation)
            onUpdateVisitedHistory: (controller, url, androidIsReload) async {
              await Future.delayed(Duration(milliseconds: 500));
              _checkToken();
            },

            // Use the new, cross-platform geolocation callback
            onGeolocationPermissionsShowPrompt: (controller, origin) async {
              return GeolocationPermissionShowPromptResponse(
                origin: origin,
                allow: true,
                retain: true,
              );
            },

              // ADD THIS SINGLE CALLBACK (5 lines total)
            // onDownloadStartRequest: (controller, downloadStartRequest) async {
            //     // Opens download URL in DEFAULT BROWSER
            //   final url = downloadStartRequest.url.toString();
            //   print('✅✅✅ Opening download in browser: $url');
            // },
            onDownloadStartRequest: (controller, downloadStartRequest) async {
               final downloadUrl = downloadStartRequest.url.toString();
  
               // 🚀 Opens DEFAULT MOBILE BROWSER for download
               if (await canLaunchUrl(Uri.parse(downloadUrl))) {
                await launchUrl(
                Uri.parse(downloadUrl),
                mode: LaunchMode.externalApplication,  // Opens system browser
                );
               }
  
               //print('✅✅✅ Opened browser for download: $downloadUrl');
             },


          ),
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    )
  );
  }
}
