import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_summary/presentation/providers/ai_summary_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../screens/browser_screen.dart';
import '../providers/browser_providers.dart';

class SummaryPanel extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const SummaryPanel({
    super.key,
    required this.onClose,
  });

  @override
  ConsumerState<SummaryPanel> createState() => _SummaryPanelState();
}

class _SummaryPanelState extends ConsumerState<SummaryPanel> {
  bool _showTranslation = false;
  bool _isExtracting = false;

  @override
  Widget build(BuildContext context) {
    // Get current active tab
    final activeTab = ref.watch(browserTabsProvider.notifier).activeTab;
    final tabId = activeTab?.id ?? '';

    // Use per-tab summary and translation providers
    final summaryState = ref.watch(tabSummaryProvider(tabId));
    final translationState = ref.watch(tabTranslationProvider(tabId));
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
              ],
            ),
          ),

          // Content
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: summaryState.when(
                data: (summary) {
                  if (summary == null) {
                    return _buildNoSummaryState(theme);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Word count reduction
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.compress,
                              size: 16,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${summary.originalWordCount} → ${summary.summarizedWordCount} words '
                              '(${((1 - summary.summarizedWordCount / summary.originalWordCount) * 100).toStringAsFixed(0)}% reduction)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Toggle between summary and translation
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Summary'),
                            selected: !_showTranslation,
                            onSelected: (selected) {
                              setState(() => _showTranslation = false);
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Translation'),
                            selected: _showTranslation,
                            onSelected: (selected) {
                              setState(() => _showTranslation = true);
                            },
                          ),
                          const Spacer(),
                          if (_showTranslation)
                            DropdownButton<String>(
                              value: selectedLanguage,
                              items: AppConstants.supportedLanguages.entries
                                  .where((e) => e.key != 'en')
                                  .map((e) => DropdownMenuItem(
                                        value: e.key,
                                        child: Text(e.value),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  final currentTabId = ref
                                          .read(browserTabsProvider.notifier)
                                          .activeTab
                                          ?.id ??
                                      '';
                                  ref
                                      .read(selectedLanguageProvider.notifier)
                                      .state = value;
                                  // Trigger translation
                                  ref
                                      .read(tabTranslationProvider(currentTabId)
                                          .notifier)
                                      .translate(
                                        summary.summarizedText,
                                        value,
                                      );
                                }
                              },
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Summary or Translation Text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _showTranslation
                            ? translationState.when(
                                data: (translation) => Text(
                                  translation?.translatedText ??
                                      'Select a language to translate',
                                  key: const ValueKey('translation'),
                                  style: theme.textTheme.bodyLarge,
                                ),
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (error, _) => Text(
                                  'Translation error: $error',
                                  style:
                                      TextStyle(color: theme.colorScheme.error),
                                ),
                              )
                            : Text(
                                summary.summarizedText,
                                key: const ValueKey('summary'),
                                style: theme.textTheme.bodyLarge,
                              ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: $error',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Action Buttons
          if (summaryState.value != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    onTap: () {
                      final currentTabId = ref
                              .read(browserTabsProvider.notifier)
                              .activeTab
                              ?.id ??
                          '';
                      final text = _showTranslation
                          ? ref
                              .read(tabTranslationProvider(currentTabId))
                              .value
                              ?.translatedText
                          : summaryState.value?.summarizedText;
                      if (text != null) {
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      }
                    },
                  ),
                  _ActionButton(
                    icon: Icons.download,
                    label: 'Download',
                    onTap: () {
                      // Save summary to file
                    },
                  ),
                  _ActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () {
                      // Share summary
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoSummaryState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.article_outlined,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No summary generated yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Click "Generate Summary" to summarize the current page content',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _isExtracting
              ? const CircularProgressIndicator()
              : FilledButton.icon(
                  onPressed: _generateSummary,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Summary'),
                ),
        ],
      ),
    );
  }

  Future<void> _generateSummary() async {
    setState(() {
      _isExtracting = true;
    });

    try {
      // Get page content getter from provider
      final contentGetter = ref.read(pageContentGetterProvider);
      String? pageContent;

      if (contentGetter != null) {
        pageContent = await contentGetter();
      }

      if (pageContent == null || pageContent.isEmpty) {
        // Fallback: show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Could not extract page content. Please try again.'),
            ),
          );
        }
        setState(() {
          _isExtracting = false;
        });
        return;
      }

      // Clean up the extracted text
      pageContent = pageContent.trim();
      if (pageContent.length > 10000) {
        pageContent = pageContent.substring(0, 10000); // Limit text length
      }

      // Generate summary for current tab
      final currentTabId =
          ref.read(browserTabsProvider.notifier).activeTab?.id ?? '';
      await ref
          .read(tabSummaryProvider(currentTabId).notifier)
          .generateSummary(pageContent);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExtracting = false;
        });
      }
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
