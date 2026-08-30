import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/topic_card.dart';
import 'quiz_screen.dart';
import 'past_papers_screen.dart';
import 'progress_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  final String targetBoard;
  const HomeScreen({super.key, required this.targetBoard});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  late String _selectedBoard;
  List<TopicModel> _topics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedBoard = widget.targetBoard;
    _fetchTopics();
  }

  Future<void> _fetchTopics() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getTopics(board: _selectedBoard);
      final list = (res.data['data'] as List).map((t) => TopicModel.fromJson(t)).toList();
      setState(() => _topics = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not fetch topics. Please check backend connection.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.science, color: Color(0xFF38BDF8), size: 22),
            SizedBox(width: 8),
            Text(
              'ChemBridge Prep',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded, color: Color(0xFF38BDF8)),
            tooltip: 'My Progress',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF38BDF8)),
            tooltip: 'Past Papers',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PastPapersScreen(initialBoard: _selectedBoard))),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF38BDF8),
        backgroundColor: const Color(0xFF1E293B),
        onRefresh: _fetchTopics,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Board Switcher Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Active Syllabus', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text('$_selectedBoard Chemistry', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedBoard,
                        dropdownColor: const Color(0xFF0369A1),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'Edexcel', child: Text('Edexcel')),
                          DropdownMenuItem(value: 'Cambridge', child: Text('Cambridge')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedBoard = val);
                            _fetchTopics();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chemistry Topics', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${_topics.length} topics', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                    : _topics.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF64748B)),
                                const SizedBox(height: 12),
                                Text(
                                  'No topics found for $_selectedBoard.',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _topics.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final topic = _topics[index];
                              return TopicCard(
                                topic: topic,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => QuizScreen(topic: topic)),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
