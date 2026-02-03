import 'package:flutter/material.dart';
import '../../domain/entities/browser_tab.dart';

class BrowserTabBar extends StatelessWidget {
  final List<BrowserTab> tabs;
  final int activeIndex;
  final Function(int) onTabSelected;
  final Function(String) onTabClosed;
  final VoidCallback onNewTab;

  const BrowserTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.onNewTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 42,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isActive = index == activeIndex;
                
                return GestureDetector(
                  onTap: () => onTabSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 180,
                    margin: const EdgeInsets.only(top: 4, left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.colorScheme.surface
                          : theme.colorScheme.surfaceContainerHigh,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      border: isActive
                          ? Border(
                              top: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Favicon
                        Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(right: 8),
                          child: tab.favicon != null
                              ? Image.network(
                                  tab.favicon!,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.public, size: 16),
                                )
                              : Icon(
                                  Icons.public,
                                  size: 16,
                                  color: theme.colorScheme.outline,
                                ),
                        ),
                        
                        // Title
                        Expanded(
                          child: Text(
                            tab.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isActive
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        
                        // Close button
                        InkWell(
                          onTap: () => onTabClosed(tab.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // New Tab Button
          IconButton(
            onPressed: onNewTab,
            icon: const Icon(Icons.add),
            iconSize: 20,
            tooltip: 'New Tab',
          ),
        ],
      ),
    );
  }
}
