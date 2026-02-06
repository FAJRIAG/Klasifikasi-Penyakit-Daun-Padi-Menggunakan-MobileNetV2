import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/prediction.dart';
import '../models/disease_info.dart';
import '../services/gemini_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/history_provider.dart';
import '../models/detection_record.dart';

/// Screen displaying prediction results and disease information
class ResultScreen extends StatefulWidget {
  final File imageFile;
  final Prediction prediction;
  
  final String? existingDiagnosis; // Optional parameter for history
  
  const ResultScreen({
    Key? key,
    required this.imageFile,
    required this.prediction,
    this.existingDiagnosis,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? _geminiAnalysis; // Start with null to show loading
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingDiagnosis != null) {
      _geminiAnalysis = widget.existingDiagnosis;
      _isAnalyzing = false;
    } else {
      _startGeminiAnalysis();
    }
  }

  void _startGeminiAnalysis() async {
    final geminiService = Provider.of<GeminiService>(context, listen: false);
    final result = await geminiService.analyzeDisease(widget.imageFile, widget.prediction.className);
    
    if (mounted) {
      setState(() {
        _geminiAnalysis = result;
        _isAnalyzing = false;
      });
      // Save to History using HistoryService
      _saveToHistory(result);
    }
  }

  void _saveToHistory(String? diagnosis) async {
    try {
      if (diagnosis == null) return;
      
      final record = DetectionRecord(
        imagePath: widget.imageFile.path,
        label: widget.prediction.className,
        confidence: widget.prediction.confidence,
        timestamp: DateTime.now(),
        diagnosis: diagnosis,
      );
      
      // Use Provider to save
      await context.read<HistoryProvider>().saveDetection(record);
    } catch (e) {
      debugPrint("Failed to save history: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final diseaseInfo = DiseaseInfo.getInfo(widget.prediction.className);
    final isHealthy = widget.prediction.isHealthy;
    final theme = Theme.of(context);
    
    // Sort probabilities to get Top 3
    final sortedProbabilities = widget.prediction.allProbabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCandidates = sortedProbabilities.take(3).toList();
    
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text('Hasil Deteksi'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  widget.imageFile,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- GEMINI AI SECTION ---
            // --- GEMINI AI SECTION ---
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade800, Colors.teal.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header AI
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Pakar AI Analysis",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: _isAnalyzing 
                      ? const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text("Sedang menganalisis foto...", style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : MarkdownBody(
                          data: _geminiAnalysis ?? "Gagal memuat analisis.",
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                            strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                        ),
                  ),
                ],
              ),
            ),
            
            // Result Card
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isHealthy 
                      ? [Colors.green.shade400, Colors.green.shade700]
                      : [Colors.orange.shade400, Colors.deepOrange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isHealthy ? Colors.green : Colors.orange).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isHealthy ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hasil Diagnosis:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                diseaseInfo != null ? diseaseInfo.name : widget.prediction.diseaseName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Confidence Meter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tingkat Keyakinan',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.prediction.confidenceText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: widget.prediction.confidence / 100,
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                         Text(
                          'Estimasi: ${widget.prediction.confidenceLevel}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    Divider(color: Colors.white.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    
                    // Possible Candidates
                    const Text(
                      'Kemungkinan Lain:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    ...topCandidates.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.white.withOpacity(0.7)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key.replaceAll('___', ' ').replaceAll('_', ' '),
                              style: const TextStyle(fontSize: 13, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${(entry.value * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            
            if (widget.prediction.confidence < 50)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade50,
                  border: Border.all(color: Colors.yellow.shade700),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.yellow.shade800),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tingkat keyakinan rendah. Hasil mungkin tidak akurat.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            if (diseaseInfo != null) ...[
              const SizedBox(height: 24),
              
              // Description
              _buildInfoSection(
                title: 'Deskripsi Database',
                icon: Icons.info_outline,
                child: Text(
                  diseaseInfo.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),

              // Cause (Penyebab)
              if (diseaseInfo.cause.isNotEmpty)
                _buildInfoSection(
                  title: 'Penyebab',
                  icon: Icons.bug_report,
                  child: Text(
                    diseaseInfo.cause,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  color: Colors.orange.shade700,
                ),
              
              // Symptoms
              _buildInfoSection(
                title: 'Gejala',
                icon: Icons.list_alt,
                color: Colors.orange.shade700,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: diseaseInfo.symptoms.map((symptom) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              symptom,
                              style: const TextStyle(fontSize: 15, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),
              
              // Treatments
              _buildInfoSection(
                title: isHealthy ? 'Perawatan' : 'Penanganan',
                icon: isHealthy ? Icons.spa : Icons.medical_services,
                color: Colors.green.shade700,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: diseaseInfo.treatments.asMap().entries.map((entry) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 15, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),

              // Prevention (Pencegahan) - Only for diseases
              if (!isHealthy && diseaseInfo.prevention.isNotEmpty)
                _buildInfoSection(
                  title: 'Pencegahan',
                  icon: Icons.shield,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: diseaseInfo.prevention.asMap().entries.map((entry) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.check_circle_outline,
                                size: 20,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 15, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              
              // Severity
              if (!isHealthy)
                _buildInfoSection(
                  title: 'Tingkat Keparahan',
                  icon: Icons.priority_high,
                  color: diseaseInfo.severity == 'Tinggi' ? Colors.red : Colors.orange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: diseaseInfo.severity == 'Tinggi' 
                          ? Colors.red.shade100 
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: diseaseInfo.severity == 'Tinggi'
                            ? Colors.red.shade400
                            : Colors.orange.shade400,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          diseaseInfo.severity == 'Tinggi' 
                              ? Icons.error 
                              : Icons.warning,
                          color: diseaseInfo.severity == 'Tinggi'
                              ? Colors.red.shade800
                              : Colors.orange.shade800,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            diseaseInfo.severity,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: diseaseInfo.severity == 'Tinggi'
                                  ? Colors.red.shade800
                                  : Colors.orange.shade800,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ] else ...[
               const SizedBox(height: 24),
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.grey.shade100,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.grey.shade300),
                 ),
                 child: Column(
                   children: [
                     Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                     const SizedBox(height: 16),
                     const Text(
                       'Informasi detail belum tersedia untuk kategori ini.',
                       textAlign: TextAlign.center,
                       style: TextStyle(fontSize: 16, color: Colors.grey),
                     ),
                     const SizedBox(height: 8),
                     Text(
                       'Label: ${widget.prediction.className}',
                       style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.grey),
                     ),
                   ],
                 ),
               ),
            ],
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Deteksi Lagi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Widget child,
    Color? color,
  }) {
    final themeColor = color ?? Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: themeColor),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
