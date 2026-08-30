class TopicModel {
  final String id;
  final String board;
  final String level;
  final String title;
  final String? description;
  final int questionCount;

  TopicModel({
    required this.id,
    required this.board,
    required this.level,
    required this.title,
    this.description,
    this.questionCount = 0,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] ?? '',
      board: json['board'] ?? 'Edexcel',
      level: json['level'] ?? 'IGCSE',
      title: json['title'] ?? '',
      description: json['description'],
      questionCount: json['_count']?['questions'] ?? 0,
    );
  }
}
