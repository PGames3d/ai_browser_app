import 'package:flutter/material.dart';

class BrowserAddressBar extends StatefulWidget {
  final String initialUrl;
  final double progress;
  final bool canGoBack;
  final bool canGoForward;
  final Function(String) onUrlSubmitted;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onRefresh;

  const BrowserAddressBar({
    super.key,
    required this.initialUrl,
    required this.progress,
    required this.canGoBack,
    required this.canGoForward,
    required this.onUrlSubmitted,
    required this.onBack,
    required this.onForward,
    required this.onRefresh,
  });

  @override
  State<BrowserAddressBar> createState() => _BrowserAddressBarState();
}

class _BrowserAddressBarState extends State<BrowserAddressBar> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void didUpdateWidget(covariant BrowserAddressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialUrl != widget.initialUrl && !_isEditing) {
      _controller.text = widget.initialUrl;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatUrl(String input) {
    input = input.trim();
    if (input.isEmpty) return input;

    // Check if it's already a valid URL
    if (input.startsWith('http://') || input.startsWith('https://')) {
      return input;
    }

    // Check if it looks like a domain
    if (input.contains('.') && !input.contains(' ')) {
      return 'https://$input';
    }

    // Treat as search query
    return 'https://www.google.com/search?q=${Uri.encodeComponent(input)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              IconButton(
                onPressed: widget.canGoBack ? widget.onBack : null,
                icon: const Icon(Icons.arrow_back),
                iconSize: 20,
                tooltip: 'Back',
              ),
              
              // Forward Button
              IconButton(
                onPressed: widget.canGoForward ? widget.onForward : null,
                icon: const Icon(Icons.arrow_forward),
                iconSize: 20,
                tooltip: 'Forward',
              ),
              
              // Refresh Button
              IconButton(
                onPressed: widget.onRefresh,
                icon: Icon(
                  widget.progress > 0 && widget.progress < 1
                      ? Icons.close
                      : Icons.refresh,
                ),
                iconSize: 20,
                tooltip: 'Refresh',
              ),
              
              // URL TextField
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _controller,
                    onTap: () {
                      setState(() => _isEditing = true);
                      _controller.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _controller.text.length,
                      );
                    },
                    onSubmitted: (value) {
                      setState(() => _isEditing = false);
                      widget.onUrlSubmitted(_formatUrl(value));
                    },
                    decoration: InputDecoration(
                      hintText: 'Search or enter URL',
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: theme.colorScheme.outline,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    style: theme.textTheme.bodyMedium,
                    textInputAction: TextInputAction.go,
                  ),
                ),
              ),
              
              // More options
              IconButton(
                onPressed: () {
                  _showMoreOptions(context);
                },
                icon: const Icon(Icons.more_vert),
                iconSize: 20,
                tooltip: 'More options',
              ),
            ],
          ),
          
          // Progress Indicator
          if (widget.progress > 0 && widget.progress < 1)
            LinearProgressIndicator(
              value: widget.progress,
              minHeight: 2,
              backgroundColor: Colors.transparent,
            ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download Page'),
            onTap: () {
              Navigator.pop(context);
              // Trigger download
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              // Share URL
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            onTap: () {
              Navigator.pop(context);
              // Show history
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
