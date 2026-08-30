class QuestionModel {
  final String id;
  final String topicId;
  final String questionText;
  final List<String> options;
  final int correctOption;
  final String? explanation;

  QuestionModel({
    required this.id,
    required this.topicId,
    required this.questionText,
    required this.options,
    required this.correctOption,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      topicId: json['topic_id'] ?? '',
      questionText: json['question_text'] ?? '',
      options: (json['options'] is List)
          ? List<String>.from(json['options'])
          : [],
      correctOption: json['correct_option'] ?? 0,
      explanation: json['explanation'],
    );
  }
}
