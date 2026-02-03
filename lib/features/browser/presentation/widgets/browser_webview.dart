import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/browser_bloc.dart';
import '../bloc/browser_event.dart';
import 'package:uuid/uuid.dart';

class BrowserWebView extends StatefulWidget {
  final String tabId;
  final String initialUrl;
  final Function(InAppWebViewController)? onControllerReady;

  const BrowserWebView({
    super.key,
    required this.tabId,
    required this.initialUrl,
    this.onControllerReady,
  });

  @override
  State<BrowserWebView> createState() => BrowserWebViewState();
}

class BrowserWebViewState extends State<BrowserWebView> {
  InAppWebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _lastLoadedUrl;

  InAppWebViewController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    _lastLoadedUrl = widget.initialUrl;
  }

  @override
  void didUpdateWidget(covariant BrowserWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the URL has changed externally, load the new URL
    if (widget.initialUrl != _lastLoadedUrl && _controller != null) {
      _loadUrl(widget.initialUrl);
    }
  }

  Future<void> _loadUrl(String url) async {
    _lastLoadedUrl = url;
    await _controller?.loadUrl(
      urlRequest: URLRequest(url: WebUri(url)),
    );
  }

  Future<void> goBack() async {
    if (await _controller?.canGoBack() ?? false) {
      await _controller?.goBack();
    }
  }

  Future<void> goForward() async {
    if (await _controller?.canGoForward() ?? false) {
      await _controller?.goForward();
    }
  }

  Future<void> reload() async {
    await _controller?.reload();
  }

  Future<void> loadUrl(String url) async {
    await _loadUrl(url);
  }

  Future<String?> getPageContent() async {
    final html = await _controller?.evaluateJavascript(
      source: 'document.body.innerText',
    );
    return html?.toString();
  }

  void _openInExternalBrowser() async {
    final uri = Uri.parse(widget.initialUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // On web platform, InAppWebView cannot embed external sites due to CORS/X-Frame-Options
    if (kIsWeb) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.public,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Web Browser',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'External websites cannot be embedded on the web platform due to browser security restrictions.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openInExternalBrowser,
              icon: const Icon(Icons.open_in_new),
              label: Text('Open ${Uri.parse(widget.initialUrl).host}'),
            ),
            const SizedBox(height: 8),
            Text(
              'Run on Android/iOS for full browser functionality',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(widget.initialUrl),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
            transparentBackground: true,
            supportZoom: true,
            useWideViewPort: true,
            loadWithOverviewMode: true,
            allowsInlineMediaPlayback: true,
            useShouldOverrideUrlLoading: true,
            cacheEnabled: true,
            domStorageEnabled: true,
            databaseEnabled: true,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          ),
          onWebViewCreated: (controller) {
            _controller = controller;
            context.read<BrowserBloc>().add(SetWebViewControllerEvent(
                  tabId: widget.tabId,
                  controller: controller,
                ));
            widget.onControllerReady?.call(controller);
          },
          onLoadStart: (controller, url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
              _errorMessage = null;
            });

            context.read<BrowserBloc>().add(UpdateTabEvent(
                  id: widget.tabId,
                  url: url.toString(),
                  progress: 0.1,
                ));
          },
          onProgressChanged: (controller, progress) {
            context.read<BrowserBloc>().add(UpdateTabEvent(
                  id: widget.tabId,
                  progress: progress / 100,
                ));
          },
          onLoadStop: (controller, url) async {
            setState(() {
              _isLoading = false;
            });

            final title = await controller.getTitle();
            final canGoBack = await controller.canGoBack();
            final canGoForward = await controller.canGoForward();

            if (!mounted) return;

            context.read<BrowserBloc>().add(UpdateTabEvent(
                  id: widget.tabId,
                  url: url.toString(),
                  title: title ?? url.toString(),
                  progress: 1.0,
                  canGoBack: canGoBack,
                  canGoForward: canGoForward,
                ));

            // Add to history
            if (url != null) {
              context.read<BrowserBloc>().add(AddToHistoryEvent(
                    id: const Uuid().v4(),
                    url: url.toString(),
                    title: title ?? url.toString(),
                  ));
            }
          },
          onTitleChanged: (controller, title) {
            context.read<BrowserBloc>().add(UpdateTabEvent(
                  id: widget.tabId,
                  title: title ?? 'Untitled',
                ));
          },
          onReceivedError: (controller, request, error) {
            setState(() {
              _hasError = true;
              _errorMessage = error.description;
              _isLoading = false;
            });
          },
          onConsoleMessage: (controller, consoleMessage) {
            // Log console messages for debugging
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url;

            // Handle special URL schemes (tel:, mailto:, etc.)
            if (url != null) {
              final scheme = url.scheme;
              if (scheme == 'tel' || scheme == 'mailto' || scheme == 'sms') {
                // Launch external app
                return NavigationActionPolicy.CANCEL;
              }
            }

            return NavigationActionPolicy.ALLOW;
          },
          onDownloadStartRequest: (controller, request) async {
            // Handle download requests
            _showDownloadDialog(request);
          },
        ),

        // Loading overlay
        if (_isLoading)
          Container(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),

        // Error overlay
        if (_hasError)
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load page',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage ?? 'Unknown error occurred',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _controller?.reload();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showDownloadDialog(DownloadStartRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download File'),
        content: Text(
            'Do you want to download: ${request.suggestedFilename ?? 'file'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Trigger download using the browser repository
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
}
