import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../bloc/file_manager_bloc.dart';
import '../bloc/file_manager_state.dart';
import '../bloc/file_manager_event.dart';
import '../../domain/entities/file_item.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileManagerBloc, FileManagerState>(
      builder: (context, state) {
        final files = state.files;
        final isLoading = state.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Files'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<FileManagerBloc>().add(const LoadFilesEvent());
                },
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : files.isEmpty
                  ? _buildEmptyState(context)
                  : _buildFileList(context, files),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.read<FileManagerBloc>().add(const PickFileEvent()),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No files yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Downloaded files and picked documents will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(BuildContext context, List<FileItem> files) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (ctx) => _summarizeFile(context, file),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.auto_awesome,
                label: 'Summarize',
              ),
              SlidableAction(
                onPressed: (ctx) => _deleteFile(context, file),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: _getFileIcon(file.type),
              title: Text(
                file.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${_formatFileSize(file.size)} • ${DateFormat('MMM d, yyyy').format(file.downloadedAt)}',
              ),
              trailing: file.isSummarized == true
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () => _openFile(context, file),
            ),
          ),
        );
      },
    );
  }

  Widget _getFileIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'docx':
      case 'doc':
        icon = Icons.description;
        color = Colors.blue;
        break;
      case 'xlsx':
      case 'xls':
        icon = Icons.table_chart;
        color = Colors.green;
        break;
      case 'pptx':
      case 'ppt':
        icon = Icons.slideshow;
        color = Colors.orange;
        break;
      case 'txt':
        icon = Icons.text_snippet;
        color = Colors.grey;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _openFile(BuildContext context, FileItem file) async {
    context.read<FileManagerBloc>().add(SelectFileEvent(file));

    if (file.path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File path is not available')),
      );
      return;
    }

    try {
      final fileToOpen = File(file.path);

      if (!await fileToOpen.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File not found: ${file.name}')),
          );
        }
        return;
      }

      // Try to open with system default app
      final uri = Uri.file(file.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback: show file details dialog
        if (context.mounted) {
          _showFileDetailsDialog(context, file);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: ${e.toString()}')),
        );
      }
    }
  }

  void _showFileDetailsDialog(BuildContext context, FileItem file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(file.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${file.type.toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Size: ${_formatFileSize(file.size)}'),
            const SizedBox(height: 8),
            Text('Path: ${file.path}'),
            const SizedBox(height: 8),
            Text(
                'Added: ${DateFormat('MMM d, yyyy').format(file.downloadedAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _summarizeFile(BuildContext context, FileItem file) {
    // Navigate to summary screen or trigger summarization
    context.read<FileManagerBloc>().add(SelectFileEvent(file));
  }

  void _deleteFile(BuildContext context, FileItem file) {
    context.read<FileManagerBloc>().add(RemoveFileEvent(file.id));
  }
}
