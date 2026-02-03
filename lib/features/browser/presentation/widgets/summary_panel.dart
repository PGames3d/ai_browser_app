import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ai_summary/presentation/bloc/ai_summary_bloc.dart';
import '../../../ai_summary/presentation/bloc/ai_summary_state.dart';
import '../../../ai_summary/presentation/bloc/ai_summary_event.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/browser_bloc.dart';
import '../bloc/browser_state.dart';

class SummaryPanel extends StatefulWidget {
  final VoidCallback onClose;

  const SummaryPanel({
    super.key,
    required this.onClose,
  });

  @override
  State<SummaryPanel> createState() => _SummaryPanelState();
}

class _SummaryPanelState extends State<SummaryPanel> {
  bool _showTranslation = false;
  bool _isExtracting = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowserBloc, BrowserState>(
      builder: (context, browserState) {
        final activeTab = browserState.activeTab;
        final tabId = activeTab?.id ?? '';

        return BlocBuilder<AiSummaryBloc, AiSummaryState>(
          builder: (context, aiState) {
            final summaryResult = aiState.tabSummaries[tabId] ?? const SummaryResult.initial();
            final translationResult = aiState.tabTranslations[tabId] ?? const TranslationResult.initial();
            final selectedLanguage = aiState.selectedLanguage;
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
                      child: _buildContent(
                        context,
                        theme,
                        tabId,
                        summaryResult,
                        translationResult,
                        selectedLanguage,
                      ),
                    ),
                  ),

                  // Action Buttons
                  if (summaryResult.summary != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionButton(
                            icon: Icons.copy,
                            label: 'Copy',
                            onTap: () {
                              final text = _showTranslation
                                  ? translationResult.translation?.translatedText
                                  : summaryResult.summary?.summarizedText;
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
          },
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    String tabId,
    SummaryResult summaryResult,
    TranslationResult translationResult,
    String selectedLanguage,
  ) {
    if (summaryResult.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (summaryResult.error != null) {
      return Padding(
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
              'Error: ${summaryResult.error}',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
        ),
      );
    }

    final summary = summaryResult.summary;
    if (summary == null) {
      return _buildNoSummaryState(context, theme, tabId);
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
                // Trigger translation when switching to translation view
                // if no translation exists yet for this tab
                if (selected && translationResult.translation == null && !translationResult.isLoading) {
                  context.read<AiSummaryBloc>().add(TranslateTextEvent(
                        text: summary.summarizedText,
                        targetLanguage: selectedLanguage,
                        tabId: tabId,
                      ));
                }
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
                    context.read<AiSummaryBloc>().add(SelectLanguageEvent(value));
                    // Trigger translation
                    context.read<AiSummaryBloc>().add(TranslateTextEvent(
                          text: summary.summarizedText,
                          targetLanguage: value,
                          tabId: tabId,
                        ));
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
              ? _buildTranslationContent(
                  context,
                  theme,
                  translationResult,
                  tabId,
                  summary.summarizedText,
                  selectedLanguage,
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
  }

  Widget _buildTranslationContent(
    BuildContext context,
    ThemeData theme,
    TranslationResult translationResult,
    String tabId,
    String summarizedText,
    String selectedLanguage,
  ) {
    if (translationResult.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (translationResult.error != null) {
      return Column(
        children: [
          Text(
            'Translation error: ${translationResult.error}',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AiSummaryBloc>().add(TranslateTextEvent(
                    text: summarizedText,
                    targetLanguage: selectedLanguage,
                    tabId: tabId,
                  ));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      );
    }

    if (translationResult.translation != null) {
      return Text(
        translationResult.translation!.translatedText,
        key: const ValueKey('translation'),
        style: theme.textTheme.bodyLarge,
      );
    }

    // No translation yet - show translate button
    return Column(
      children: [
        Text(
          'Click to translate the summary',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            context.read<AiSummaryBloc>().add(TranslateTextEvent(
                  text: summarizedText,
                  targetLanguage: selectedLanguage,
                  tabId: tabId,
                ));
          },
          icon: const Icon(Icons.translate),
          label: const Text('Translate Now'),
        ),
      ],
    );
  }

  Widget _buildNoSummaryState(BuildContext context, ThemeData theme, String tabId) {
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
                  onPressed: () => _generateSummary(context, tabId),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Summary'),
                ),
        ],
      ),
    );
  }

  Future<void> _generateSummary(BuildContext context, String tabId) async {
    setState(() {
      _isExtracting = true;
    });

    try {
      // Get WebView controller directly from BrowserBloc state
      final browserState = context.read<BrowserBloc>().state;
      final controller = browserState.webViewControllers[tabId];
      String? pageContent;

      if (controller != null) {
        // Extract text content from the page using JavaScript
        final result = await controller.evaluateJavascript(
          source: 'document.body.innerText',
        );
        pageContent = result?.toString();
      }

      // Fallback: try pageContentGetter if available
      if ((pageContent == null || pageContent.isEmpty) && browserState.pageContentGetter != null) {
        pageContent = await browserState.pageContentGetter!();
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
      if (mounted) {
        final activeTab = context.read<BrowserBloc>().state.activeTab;
        context.read<AiSummaryBloc>().add(GenerateSummaryEvent(
              text: pageContent,
              sourceUrl: activeTab?.url,
              tabId: tabId,
            ));
      }
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
