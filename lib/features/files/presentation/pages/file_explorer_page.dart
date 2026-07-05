import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import '../../domain/entities/file_item.dart';

final fileControllerProvider = StateNotifierProvider<FileController, FileState>((ref) => FileController());
final fileFilterProvider = StateProvider<FileType?>((ref) => null);

class FileState {
  final List<FileItem> files;
  final bool isLoading;
  const FileState({this.files = const [], this.isLoading = false});
  FileState copyWith({List<FileItem>? files, bool? isLoading}) =>
    FileState(files: files ?? this.files, isLoading: isLoading ?? this.isLoading);
}

class FileController extends StateNotifier<FileState> {
  FileController() : super(const FileState());
  void setFiles(List<FileItem> files) => state = state.copyWith(files: files);
}

class FileExplorerPage extends ConsumerWidget {
  const FileExplorerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileState = ref.watch(fileControllerProvider);
    final filter = ref.watch(fileFilterProvider);
    final theme = Theme.of(context);
    final filtered = filter == null ? fileState.files : fileState.files.where((f) => f.type == filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Files')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(
          decoration: InputDecoration(hintText: 'Search files...', prefixIcon: const Icon(Icons.search_rounded),
            filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        )),
        SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          _buildFilterChip(ref, 'All', null, filter == null, theme),
          _buildFilterChip(ref, 'PDF', FileType.pdf, filter == FileType.pdf, theme),
          _buildFilterChip(ref, 'DOCX', FileType.docx, filter == FileType.docx, theme),
          _buildFilterChip(ref, 'PPT', FileType.ppt, filter == FileType.ppt, theme),
          _buildFilterChip(ref, 'Images', FileType.image, filter == FileType.image, theme),
        ])).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.folder_open_rounded, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No files found', style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                const SizedBox(height: 8),
                Text('Use the search bar or file picker to find files',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final file = filtered[i];
                  return ListTile(
                    leading: Icon(_getFileIcon(file.type), color: _getFileColor(file.type)),
                    title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${_formatSize(file.sizeBytes)} • ${file.extension.toUpperCase()}'),
                    onTap: () => OpenFilex.open(file.path),
                  ).animate().fadeIn(duration: 200.ms, delay: Duration(milliseconds: i * 30));
                }),
        ),
      ]),
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String label, FileType? type, bool selected, ThemeData theme) {
    return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(
      label: Text(label), selected: selected,
      onSelected: (_) => ref.read(fileFilterProvider.notifier).state = type));
  }

  IconData _getFileIcon(FileType type) => switch (type) {
    FileType.pdf => Icons.picture_as_pdf_rounded,
    FileType.docx => Icons.description_rounded,
    FileType.ppt => Icons.slideshow_rounded,
    FileType.image => Icons.image_rounded,
    FileType.audio => Icons.audiotrack_rounded,
    FileType.video => Icons.videocam_rounded,
    _ => Icons.insert_drive_file_rounded,
  };

  Color _getFileColor(FileType type) => switch (type) {
    FileType.pdf => const Color(0xFFFF5252),
    FileType.docx => const Color(0xFF448AFF),
    FileType.ppt => const Color(0xFFFF6D00),
    FileType.image => const Color(0xFF00E676),
    _ => const Color(0xFF90A4AE),
  };

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}
