import 'package:flutter/material.dart';
import '../models/progress_model.dart';
import '../services/api_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _apiService = ApiService();
  List<ProgressModel> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    try {
      final res = await _apiService.getProgress();
      final list = (res.data['data'] as List).map((p) => ProgressModel.fromJson(p)).toList();
      setState(() {
        _records = list;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load student progress')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double overallAvg = _records.isEmpty
        ? 0.0
        : _records.map((r) => r.score).reduce((a, b) => a + b) / _records.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Learning Analytics', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
          : _records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.analytics_outlined, size: 56, color: Color(0xFF64748B)),
                      const SizedBox(height: 16),
                      const Text(
                        'No quiz attempts yet.',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Complete quizzes on the home screen to track your mastery.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF38BDF8),
                  backgroundColor: const Color(0xFF1E293B),
                  onRefresh: _fetchProgress,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Overview summary card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text('Total Quizzes', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                const SizedBox(height: 4),
                                Text('${_records.length}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                            Column(
                              children: [
                                const Text('Average Score', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  '${overallAvg.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: overallAvg >= 70 ? Colors.greenAccent : const Color(0xFF38BDF8),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Recent Quiz Attempts', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ..._records.map((item) {
                        final isGoodScore = item.score >= 70.0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.06)),
                          ),
                          child: ListTile(
                            title: Text(item.topicTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Text('Completed: ${item.completedAt.toLocal().toString().split(' ')[0]}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isGoodScore ? Colors.green.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${item.score.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: isGoodScore ? Colors.greenAccent : Colors.amberAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
