class ProgressModel {
  final String id;
  final String topicTitle;
  final double score;
  final DateTime completedAt;

  ProgressModel({
    required this.id,
    required this.topicTitle,
    required this.score,
    required this.completedAt,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'] ?? '',
      topicTitle: json['topic']?['title'] ?? 'Chemistry Topic',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : DateTime.now(),
    );
  }
}
