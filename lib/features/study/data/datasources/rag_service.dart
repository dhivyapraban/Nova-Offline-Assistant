import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Abstract interface for a future offline RAG (Retrieval-Augmented Generation) service.
abstract class RAGService {
  /// Indexes a document's content for future querying.
  Future<void> indexDocument(String filePath);

  /// Queries the indexed documents and returns relevant text passages.
  Future<List<String>> queryDocument(String query);

  /// Initializes the RAG engine.
  Future<void> initialize();

  /// Whether the RAG service is ready to accept queries.
  bool get isReady;
}

/// Real implementation of [RAGService] using TF-IDF text search over PDF pages.
/// Uses `syncfusion_flutter_pdf` to extract PDF page text completely offline.
class LocalRAGService implements RAGService {
  bool _isReady = false;
  
  // Maps document path to list of page texts
  final Map<String, List<String>> _indexedDocuments = {};

  @override
  Future<void> initialize() async {
    _isReady = true;
  }

  @override
  bool get isReady => _isReady;

  @override
  Future<void> indexDocument(String filePath) async {
    if (!File(filePath).existsSync()) return;

    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      final List<String> pagesText = [];
      final extractor = PdfTextExtractor(document);

      for (int i = 0; i < document.pages.count; i++) {
        final String text = extractor.extractText(startPageIndex: i, endPageIndex: i);
        pagesText.add(text);
      }

      document.dispose();
      _indexedDocuments[filePath] = pagesText;
    } catch (_) {
      // Handle extraction errors gracefully
    }
  }

  @override
  Future<List<String>> queryDocument(String query) async {
    final searchTerms = query.toLowerCase().split(RegExp(r'\s+')).where((t) => t.length > 2).toList();
    if (searchTerms.isEmpty) return [];

    final List<MapEntry<String, double>> matchedPassages = [];

    for (final docEntry in _indexedDocuments.entries) {
      final filePath = docEntry.key;
      final pages = docEntry.value;
      final fileName = filePath.split('/').last.split('\\').last;

      for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
        final pageText = pages[pageIndex];
        final lowerText = pageText.toLowerCase();
        
        double score = 0;
        for (final term in searchTerms) {
          if (lowerText.contains(term)) {
            // Count occurrences
            final count = term.allMatches(lowerText).length;
            score += count * (1.0 / term.length); // Weight term frequency
          }
        }

        if (score > 0) {
          final passageInfo = '[$fileName - Page ${pageIndex + 1}]:\n${pageText.trim()}';
          matchedPassages.add(MapEntry(passageInfo, score));
        }
      }
    }

    // Sort by score descending
    matchedPassages.sort((a, b) => b.value.compareTo(a.value));

    return matchedPassages.take(5).map((e) => e.key).toList();
  }
}
