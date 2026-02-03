import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/browser_address_bar.dart';
import '../widgets/browser_tab_bar.dart';
import '../widgets/browser_webview.dart';
import '../widgets/summary_panel.dart';
import '../providers/browser_providers.dart';
import '../../../../core/constants/app_constants.dart';

// Type alias for page content getter function
typedef PageContentGetter = Future<String?> Function();

// Provider to share page content getter with summary panel
final pageContentGetterProvider =
    StateProvider<PageContentGetter?>((ref) => null);

class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({super.key});

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  bool _showSummaryPanel = false;
  final Map<String, GlobalKey<BrowserWebViewState>> _webViewKeys = {};

  @override
  void initState() {
    super.initState();
    // Initialize with a default tab if none exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabs = ref.read(browserTabsProvider);
      if (tabs.isEmpty) {
        ref.read(browserTabsProvider.notifier).createTab(
              url: AppConstants.defaultHomePage,
            );
      }
    });
  }

  void _toggleSummaryPanel() {
    setState(() {
      _showSummaryPanel = !_showSummaryPanel;
    });

    // Update the page content getter when opening summary panel
    if (_showSummaryPanel) {
      final activeTab = ref.read(browserTabsProvider.notifier).activeTab;
      if (activeTab != null) {
        ref.read(pageContentGetterProvider.notifier).state = () async {
          return _getWebViewKey(activeTab.id).currentState?.getPageContent();
        };
      }
    }
  }

  GlobalKey<BrowserWebViewState> _getWebViewKey(String tabId) {
    if (!_webViewKeys.containsKey(tabId)) {
      _webViewKeys[tabId] = GlobalKey<BrowserWebViewState>();
    }
    return _webViewKeys[tabId]!;
  }

  void _cleanupOldKeys(List<String> currentTabIds) {
    _webViewKeys.removeWhere((key, value) => !currentTabIds.contains(key));
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ref.watch(browserTabsProvider);
    final tabsNotifier = ref.watch(browserTabsProvider.notifier);
    final activeTab = tabsNotifier.activeTab;

    // Cleanup old keys
    _cleanupOldKeys(tabs.map((t) => t.id).toList());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            BrowserTabBar(
              tabs: tabs,
              activeIndex: tabsNotifier.activeTabIndex ?? 0,
              onTabSelected: (index) {
                ref.read(browserTabsProvider.notifier).switchTab(index);
              },
              onTabClosed: (id) {
                ref.read(browserTabsProvider.notifier).closeTab(id);
              },
              onNewTab: () {
                ref.read(browserTabsProvider.notifier).createTab();
              },
            ),

            // Address Bar
            if (activeTab != null)
              BrowserAddressBar(
                initialUrl: activeTab.url,
                progress: activeTab.progress,
                canGoBack: activeTab.canGoBack,
                canGoForward: activeTab.canGoForward,
                onUrlSubmitted: (url) {
                  // Update the tab URL and load in WebView
                  ref.read(browserTabsProvider.notifier).updateTab(
                        activeTab.id,
                        url: url,
                      );
                  // Load URL in WebView
                  _getWebViewKey(activeTab.id).currentState?.loadUrl(url);
                },
                onBack: () {
                  _getWebViewKey(activeTab.id).currentState?.goBack();
                },
                onForward: () {
                  _getWebViewKey(activeTab.id).currentState?.goForward();
                },
                onRefresh: () {
                  _getWebViewKey(activeTab.id).currentState?.reload();
                },
              ),

            // WebView Content
            Expanded(
              child: Stack(
                children: [
                  if (activeTab != null)
                    BrowserWebView(
                      key: _getWebViewKey(activeTab.id),
                      tabId: activeTab.id,
                      initialUrl: activeTab.url,
                    ),

                  // Summary Panel (Collapsible)
                  if (_showSummaryPanel)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SummaryPanel(
                        onClose: _toggleSummaryPanel,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleSummaryPanel,
        icon: Icon(_showSummaryPanel ? Icons.close : Icons.auto_awesome),
        label: Text(_showSummaryPanel ? 'Close' : 'Summarize'),
      ),
    );
  }
}
