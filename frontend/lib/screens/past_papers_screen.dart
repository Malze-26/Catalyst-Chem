import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/past_paper_model.dart';
import '../services/api_service.dart';

class PastPapersScreen extends StatefulWidget {
  final String initialBoard;
  const PastPapersScreen({super.key, required this.initialBoard});

  @override
  State<PastPapersScreen> createState() => _PastPapersScreenState();
}

class _PastPapersScreenState extends State<PastPapersScreen> {
  final _apiService = ApiService();
  late String _selectedBoard;
  List<PastPaperModel> _papers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedBoard = widget.initialBoard;
    _fetchPapers();
  }

  Future<void> _fetchPapers() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getPastPapers(board: _selectedBoard);
      final list = (res.data['data'] as List).map((p) => PastPaperModel.fromJson(p)).toList();
      setState(() => _papers = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load past papers')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PDF file. Verify URL or internet connection.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Past Papers (PDF)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Exam Board:', style: TextStyle(color: Colors.white70, fontSize: 15)),
                  DropdownButton<String>(
                    value: _selectedBoard,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 14),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'Edexcel', child: Text('Edexcel')),
                      DropdownMenuItem(value: 'Cambridge', child: Text('Cambridge')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedBoard = val);
                        _fetchPapers();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                  : _papers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.picture_as_pdf_outlined, size: 48, color: Color(0xFF64748B)),
                              const SizedBox(height: 12),
                              Text('No past papers currently listed for $_selectedBoard.', style: const TextStyle(color: Color(0xFF94A3B8))),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _papers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final paper = _papers[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.06)),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 24),
                                ),
                                title: Text(
                                  '${paper.board} ${paper.year}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(paper.paperNumber, style: const TextStyle(color: Color(0xFF94A3B8))),
                                trailing: IconButton(
                                  icon: const Icon(Icons.open_in_new_rounded, color: Color(0xFF38BDF8)),
                                  tooltip: 'Open PDF',
                                  onPressed: () => _openPdf(paper.pdfUrl),
                                ),
                              ),
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}
