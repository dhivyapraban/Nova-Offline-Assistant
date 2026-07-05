import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import '../../data/datasources/rag_service.dart';

class PdfViewerPage extends StatefulWidget {
  final String filePath;
  const PdfViewerPage({super.key, required this.filePath});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final PdfViewerController _controller = PdfViewerController();
  final List<int> _bookmarks = [];
  final LocalRAGService _ragService = LocalRAGService();
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isIndexing = false;

  @override
  void initState() {
    super.initState();
    _startIndexing();
  }

  Future<void> _startIndexing() async {
    setState(() => _isIndexing = true);
    await _ragService.initialize();
    await _ragService.indexDocument(widget.filePath);
    if (mounted) {
      setState(() => _isIndexing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = widget.filePath.split('/').last.split('\\').last;

    return Scaffold(
      appBar: AppBar(
        title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: _isIndexing 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.search_rounded),
            onPressed: _isIndexing ? null : () => _showSearchSheet(context, theme),
            tooltip: 'Search Document (Offline RAG)',
          ),
          IconButton(
            icon: Icon(_bookmarks.contains(_currentPage) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _bookmarks.contains(_currentPage) ? theme.colorScheme.primary : null),
            onPressed: () {
              setState(() {
                if (_bookmarks.contains(_currentPage)) { _bookmarks.remove(_currentPage); }
                else { _bookmarks.add(_currentPage); }
              });
            },
            tooltip: 'Bookmark page',
          ),
          if (_bookmarks.isNotEmpty) IconButton(
            icon: const Icon(Icons.list_rounded),
            onPressed: () => _showBookmarks(context, theme),
            tooltip: 'Bookmarks',
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: File(widget.filePath).existsSync()
            ? SfPdfViewer.file(
                File(widget.filePath),
                controller: _controller,
                onDocumentLoaded: (details) => setState(() => _totalPages = details.document.pages.count),
                onPageChanged: (details) => setState(() => _currentPage = details.newPageNumber),
              )
            : Center(child: Text('File not found: $fileName')),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Page $_currentPage of $_totalPages', style: theme.textTheme.bodySmall),
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.remove), iconSize: 18,
                onPressed: () => _controller.zoomLevel = (_controller.zoomLevel - 0.25).clamp(0.5, 3.0)),
              IconButton(icon: const Icon(Icons.add), iconSize: 18,
                onPressed: () => _controller.zoomLevel = (_controller.zoomLevel + 0.25).clamp(0.5, 3.0)),
            ]),
          ]),
        ),
      ]),
    );
  }

  void _showBookmarks(BuildContext context, ThemeData theme) {
    showModalBottomSheet(context: context, builder: (context) => ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        Text('Bookmarks', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ..._bookmarks.map((page) => ListTile(
          leading: const Icon(Icons.bookmark_rounded),
          title: Text('Page $page'),
          onTap: () { _controller.jumpToPage(page); Navigator.pop(context); },
        )),
      ],
    ));
  }

  void _showSearchSheet(BuildContext context, ThemeData theme) {
    String query = '';
    List<String> results = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ask or search in document...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => query = val,
                    onSubmitted: (val) async {
                      if (val.trim().isNotEmpty) {
                        final res = await _ragService.queryDocument(val);
                        setState(() => results = res);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: () async {
                    if (query.trim().isNotEmpty) {
                      final res = await _ragService.queryDocument(query);
                      setState(() => results = res);
                    }
                  },
                ),
              ]),
              const SizedBox(height: 16),
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Text('Type terms to search offline inside this PDF.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final item = results[index];
                          // Parse out page number
                          final pageMatch = RegExp(r'Page (\d+)').firstMatch(item);
                          final pageNumber = pageMatch != null ? int.tryParse(pageMatch.group(1)!) : null;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Result ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(item, maxLines: 5, overflow: TextOverflow.ellipsis),
                              ),
                              onTap: () {
                                if (pageNumber != null) {
                                  _controller.jumpToPage(pageNumber);
                                }
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
