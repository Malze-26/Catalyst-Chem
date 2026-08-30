import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../models/question_model.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';

class QuizScreen extends StatefulWidget {
  final TopicModel topic;
  const QuizScreen({super.key, required this.topic});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _apiService = ApiService();
  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final res = await _apiService.getQuizQuestions(widget.topic.id);
      final list = (res.data['data'] as List).map((q) => QuestionModel.fromJson(q)).toList();
      setState(() {
        _questions = list;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load quiz questions')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _submitAnswer() {
    if (_selectedOption == null) return;
    setState(() {
      _answered = true;
      if (_selectedOption == _questions[_currentIndex].correctOption) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      final scorePercentage = (_correctCount / _questions.length) * 100;
      try {
        await _apiService.submitQuizScore(widget.topic.id, scorePercentage);
      } catch (_) {}
      if (mounted) _showResultDialog(scorePercentage);
    }
  }

  void _showResultDialog(double score) {
    final bool isPassed = score >= 70.0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isPassed ? '🎉 Excellent Job!' : '📚 Keep Practicing!',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topic: ${widget.topic.title}',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPassed ? Colors.green.withOpacity(0.15) : Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Accuracy:', style: TextStyle(color: Colors.white70, fontSize: 15)),
                  Text(
                    '${score.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: isPassed ? Colors.greenAccent : Colors.amberAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Correct Answers: $_correctCount out of ${_questions.length}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'Done & Return',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: Text(widget.topic.title),
          backgroundColor: const Color(0xFF1E293B),
        ),
        body: const Center(
          child: Text('No questions currently available for this topic.', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          'Question ${_currentIndex + 1} of ${_questions.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Linear Progress Indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                minHeight: 6,
                backgroundColor: const Color(0xFF1E293B),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Text(
                question.questionText,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(question.options.length, (idx) {
              final isCorrect = idx == question.correctOption;
              final isSelected = idx == _selectedOption;

              Color bgColor = const Color(0xFF1E293B);
              Color borderColor = Colors.white.withOpacity(0.06);

              if (_answered) {
                if (isCorrect) {
                  bgColor = Colors.green.shade900.withOpacity(0.5);
                  borderColor = Colors.greenAccent;
                } else if (isSelected && !isCorrect) {
                  bgColor = Colors.red.shade900.withOpacity(0.5);
                  borderColor = Colors.redAccent;
                }
              } else if (isSelected) {
                bgColor = const Color(0xFF0284C7).withOpacity(0.2);
                borderColor = const Color(0xFF38BDF8);
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: _answered ? null : () => setState(() => _selectedOption = idx),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: isSelected || (_answered && isCorrect) ? 1.5 : 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + idx),
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF0F172A) : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            question.options[idx],
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (_answered && question.explanation != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2B48),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_rounded, color: Color(0xFF38BDF8), size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Explanation',
                          style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      question.explanation!,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            CustomButton(
              text: _answered
                  ? (_currentIndex == _questions.length - 1 ? 'Finish & Save Score' : 'Next Question')
                  : 'Check Answer',
              onPressed: _selectedOption == null
                  ? null
                  : _answered
                      ? _nextQuestion
                      : _submitAnswer,
            ),
          ],
        ),
      ),
    );
  }
}
