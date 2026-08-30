class PastPaperModel {
  final String id;
  final String board;
  final int year;
  final String paperNumber;
  final String pdfUrl;

  PastPaperModel({
    required this.id,
    required this.board,
    required this.year,
    required this.paperNumber,
    required this.pdfUrl,
  });

  factory PastPaperModel.fromJson(Map<String, dynamic> json) {
    return PastPaperModel(
      id: json['id'] ?? '',
      board: json['board'] ?? 'Edexcel',
      year: json['year'] ?? 2024,
      paperNumber: json['paper_number'] ?? '',
      pdfUrl: json['pdf_url'] ?? '',
    );
  }
}
