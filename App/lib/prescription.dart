import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'dart:math' as math;
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
// path_provider is not used in the snippet, but keeping import if needed elsewhere
// import 'package:path_provider/path_provider.dart';

// Define data classes outside other classes
class MedicationInfo {
  final String nameEnglish;
  final String nameTamil;
  final String dosageEnglish;
  final String dosageTamil;
  final String frequencyEnglish;
  final String frequencyTamil;
  final String durationEnglish;
  final String durationTamil;
  final String instructionsEnglish;
  final String instructionsTamil;

  MedicationInfo({
    required this.nameEnglish,
    required this.nameTamil,
    required this.dosageEnglish,
    required this.dosageTamil,
    required this.frequencyEnglish,
    required this.frequencyTamil,
    required this.durationEnglish,
    required this.durationTamil,
    required this.instructionsEnglish,
    required this.instructionsTamil,
  });
}

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() {
    return _PrescriptionScreenState();
  }
}

class _PrescriptionScreenState extends State<PrescriptionScreen>
    with SingleTickerProviderStateMixin {
  bool isUploading = false;
  bool isTranslated = false;
  File? _pdfFile;
  Uint8List? _pdfBytes;
  String? _fileName;
  String? _pdfText;
  String _displayLanguage = 'both'; // 'both', 'english', 'tamil'
  late TabController _tabController;
  List<MedicationInfo> medications = [];
  // Store notes separately for easy access based on language selection
  List<String> doctorNotesEnglish = [];
  List<String> doctorNotesTamil = [];

  // API key for translation/analysis - Replace with your Gemini API key
  final String apiKey =
      "AIzaSyBCHuTW6rD1va_V3H0rT0dQkAmcIy1baNQ"; // IMPORTANT: Replace with your actual key

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // Essential for web platform
    );

    if (result != null) {
      setState(() {
        _pdfFile = null; // Reset previous file/bytes
        _pdfBytes = null;
        if (kIsWeb) {
          // For web, use bytes directly
          _pdfBytes = result.files.first.bytes;
          _fileName = result.files.first.name;
        } else {
          // For non-web platforms, we can use File
          _pdfFile = File(result.files.first.path!);
          _fileName = result.files.first.path!.split('/').last;
        }
        isTranslated = false; // Reset translation state
        medications = []; // Clear previous results
        doctorNotesEnglish = []; // Clear previous results
        doctorNotesTamil = []; // Clear previous results
      });
      processPrescription(); // Start processing the new file
    }
  }

  Future<String> _extractTextFromPdf() async {
    // Ensure there's data to process
    if ((kIsWeb && _pdfBytes == null) || (!kIsWeb && _pdfFile == null)) {
      throw Exception("No PDF data available to extract text.");
    }

    // Load the PDF document
    PdfDocument document;
    if (kIsWeb) {
      document = PdfDocument(inputBytes: _pdfBytes);
    } else {
      document = PdfDocument(inputBytes: await _pdfFile!.readAsBytes());
    }

    // Initialize text extractor
    PdfTextExtractor extractor = PdfTextExtractor(document);

    // Extract text from all pages
    String text =
        extractor.extractText(); // Simplified extraction for all pages

    // Dispose the document
    document.dispose();

    return text;
  }

  // ===========================================================================
  // Corrected API Call Function (Attempt 3: Using gemini-2.0-flash with v1beta)
  // ===========================================================================
  Future<Map<String, dynamic>> _analyzePrescription(
      String prescriptionText) async {
    print('Analyzing prescription with Gemini API (gemini-2.0-flash)...');

    // **Corrected Gemini API endpoint**
    // Use 'gemini-2.0-flash' with the 'v1beta' API version, based on curl example.
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey'); // <-- Corrected URL

    // Prepare the prompt with prescription analysis
    const systemPrompt =
        '''Analyze the following medical prescription text and extract:
    1. All medications with details (name, dosage, frequency, duration, instructions)
    2. Doctor's notes or special instructions
    3. Translate all medication information and instructions to Tamil

    Format your response STRICTLY as a JSON object only, with the following structure:
    {
      "medications": [
        {
          "nameEnglish": "Medication name in English",
          "nameTamil": "Medication name in Tamil",
          "dosageEnglish": "Dosage in English",
          "dosageTamil": "Dosage in Tamil",
          "frequencyEnglish": "How often to take in English",
          "frequencyTamil": "How often to take in Tamil",
          "durationEnglish": "How long to take in English",
          "durationTamil": "How long to take in Tamil",
          "instructionsEnglish": "Special instructions in English",
          "instructionsTamil": "Special instructions in Tamil"
        }
      ],
      "doctorNotesEnglish": ["Note 1 in English", "Note 2 in English"],
      "doctorNotesTamil": ["Note 1 in Tamil", "Note 2 in Tamil"]
    }
    Return ONLY the raw JSON object without any markdown formatting (like ``````) or explanations.''';

    // Create request body following Gemini API format
    final requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": systemPrompt},
            {"text": prescriptionText}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.4, // Adjust temperature for creativity vs consistency
        "maxOutputTokens": 2048 // Adjust based on expected response size
      }
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        print('Received response from Gemini API');
        final jsonResponse = jsonDecode(response.body);

        // Defensive check for response structure
        if (jsonResponse['candidates'] == null ||
            jsonResponse['candidates'].isEmpty ||
            jsonResponse['candidates'][0]['content'] == null ||
            jsonResponse['candidates'][0]['content']['parts'] == null ||
            jsonResponse['candidates'][0]['content']['parts'].isEmpty) {
          print('Invalid response structure from API: ${response.body}');
          throw Exception(
              'Invalid response structure from API: Missing candidates, content, or parts');
        }
        final responseText =
            jsonResponse['candidates'][0]['content']['parts'][0]['text'];

        // Attempt to parse the JSON directly
        try {
          final Map<String, dynamic> resultJson =
              jsonDecode(responseText.trim());
          print('Successfully parsed JSON response.');
          return resultJson;
        } catch (jsonError) {
          print('Error parsing JSON directly: $jsonError');
          print('Raw response text: $responseText');
          // Fallback: Try extracting JSON using regex (less reliable)
          final RegExp regex = RegExp(r'\{[\s\S]*\}');
          final match = regex.firstMatch(responseText);
          if (match != null) {
            final extractedJson = match.group(0);
            print(
                'Attempting to parse JSON extracted via regex: $extractedJson');
            try {
              return jsonDecode(extractedJson!);
            } catch (regexJsonError) {
              print('Error parsing JSON extracted via regex: $regexJsonError');
              throw Exception(
                  'Could not parse JSON from response, even with regex fallback.');
            }
          } else {
            throw Exception(
                'Could not parse JSON from response and regex found no match.');
          }
        }
      } else {
        // Log the detailed error from the API response body
        print('Error response: ${response.statusCode}: ${response.body}');
        // Extract the message from the error if possible
        String errorMessage = 'API returned status ${response.statusCode}';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson['error'] != null &&
              errorJson['error']['message'] != null) {
            errorMessage = 'API Error: ${errorJson['error']['message']}';
          }
        } catch (_) {
          // Ignore if response body is not valid JSON
        }
        throw Exception('Failed to analyze prescription: $errorMessage');
      }
    } catch (e) {
      print('Error analyzing with AI: $e');
      // Re-throw the specific exception caught or a general one
      throw Exception(
          'Error contacting or processing response from analysis API: $e');
    }
  }
  // ===========================================================================
  // End of Corrected API Call Function
  // ===========================================================================

  void processPrescription() async {
    // Check if there is a file/bytes to process
    if ((kIsWeb && _pdfBytes == null) || (!kIsWeb && _pdfFile == null)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No PDF file selected.')));
      return;
    }

    setState(() {
      isUploading = true;
      isTranslated = false; // Ensure previous results are cleared visually
      medications = [];
      doctorNotesEnglish = [];
      doctorNotesTamil = [];
    });

    try {
      // 1. Extract text from PDF
      _pdfText = await _extractTextFromPdf();
      print(
          'PDF text extracted (first 100 chars): ${_pdfText!.substring(0, math.min(_pdfText!.length, 100))}...');

      // Basic check if text extraction yielded anything
      if (_pdfText == null || _pdfText!.trim().isEmpty) {
        throw Exception(
            "Extracted text is empty. The PDF might be image-based or corrupted.");
      }

      // 2. Analyze and translate prescription using the API
      final analysisResult = await _analyzePrescription(_pdfText!);

      // 3. Parse medications
      // Defensive parsing: check if 'medications' key exists and is a list
      if (analysisResult['medications'] is! List) {
        throw Exception(
            "API response missing 'medications' list or it's not a list.");
      }
      List<dynamic> medicationsData = analysisResult["medications"];
      List<MedicationInfo> parsedMedications = medicationsData
          .map((medData) {
            // Defensive parsing for each medication item
            if (medData is! Map) return null; // Skip invalid entries
            return MedicationInfo(
              nameEnglish: medData["nameEnglish"]?.toString() ?? "Unknown",
              nameTamil: medData["nameTamil"]?.toString() ?? "அறியப்படாதது",
              dosageEnglish:
                  medData["dosageEnglish"]?.toString() ?? "Not specified",
              dosageTamil:
                  medData["dosageTamil"]?.toString() ?? "குறிப்பிடப்படவில்லை",
              frequencyEnglish:
                  medData["frequencyEnglish"]?.toString() ?? "Not specified",
              frequencyTamil: medData["frequencyTamil"]?.toString() ??
                  "குறிப்பிடப்படவில்லை",
              durationEnglish:
                  medData["durationEnglish"]?.toString() ?? "Not specified",
              durationTamil:
                  medData["durationTamil"]?.toString() ?? "குறிப்பிடப்படவில்லை",
              instructionsEnglish:
                  medData["instructionsEnglish"]?.toString() ?? "None",
              instructionsTamil:
                  medData["instructionsTamil"]?.toString() ?? "எதுவும் இல்லை",
            );
          })
          .whereType<MedicationInfo>()
          .toList(); // Filter out nulls

      // 4. Parse doctor notes
      // Defensive parsing for notes and store separately
      List<String> parsedNotesEnglish =
          (analysisResult["doctorNotesEnglish"] is List)
              ? List<String>.from(
                  analysisResult["doctorNotesEnglish"].map((e) => e.toString()))
              : [];
      List<String> parsedNotesTamil =
          (analysisResult["doctorNotesTamil"] is List)
              ? List<String>.from(
                  analysisResult["doctorNotesTamil"].map((e) => e.toString()))
              : [];

      setState(() {
        isUploading = false;
        isTranslated = true;
        medications = parsedMedications;
        doctorNotesEnglish = parsedNotesEnglish; // Store English notes
        doctorNotesTamil = parsedNotesTamil; // Store Tamil notes
      });
    } catch (e) {
      print('Error processing prescription: $e');
      setState(() {
        isUploading = false;
        isTranslated = false;
        // Clear any potentially partially processed data
        medications = [];
        doctorNotesEnglish = [];
        doctorNotesTamil = [];
        _fileName = null; // Optionally clear filename on error
      });

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Processing Error'),
          // Show the specific error message from the exception
          content: Text(
              'Failed to process the prescription: ${e.toString()}. Please ensure the PDF contains selectable text, check your API key and model access, then try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _sharePrescriptionDetails() async {
    if (!isTranslated || medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No prescription details to share.')));
      return;
    }

    // Build the content string - show based on _displayLanguage
    String content = "💊 My Prescription Details 💊\n\n";
    bool showEnglish =
        _displayLanguage == 'english' || _displayLanguage == 'both';
    bool showTamil = _displayLanguage == 'tamil' || _displayLanguage == 'both';

    for (var med in medications) {
      if (showEnglish) {
        content += "Medication: ${med.nameEnglish}\n";
        content += "Dosage: ${med.dosageEnglish}\n";
        content += "Frequency: ${med.frequencyEnglish}\n";
        content += "Duration: ${med.durationEnglish}\n";
        content += "Instructions: ${med.instructionsEnglish}\n";
        if (showTamil) content += "----\n"; // Separator if showing both
      }
      if (showTamil) {
        content += "மருந்து: ${med.nameTamil}\n";
        content += "அளவு: ${med.dosageTamil}\n";
        content += "அடுக்கு: ${med.frequencyTamil}\n";
        content += "காலம்: ${med.durationTamil}\n";
        content += "அறிவுறுத்தல்கள்: ${med.instructionsTamil}\n";
      }
      content += "\n"; // Space between medications
    }

    content += "--- Doctor's Notes ---\n";
    if (showEnglish && doctorNotesEnglish.isNotEmpty) {
      content += "(English)\n";
      for (var note in doctorNotesEnglish) {
        content += "• $note\n";
      }
      if (showTamil && doctorNotesTamil.isNotEmpty) content += "----\n";
    }
    if (showTamil && doctorNotesTamil.isNotEmpty) {
      content += "(தமிழ்)\n";
      for (var note in doctorNotesTamil) {
        content += "• $note\n";
      }
    }
    if (doctorNotesEnglish.isEmpty && doctorNotesTamil.isEmpty) {
      content += "No specific notes found.\n";
    }

    if (kIsWeb) {
      // For web, copy to clipboard
      await Clipboard.setData(ClipboardData(text: content));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Prescription details copied to clipboard!')),
      );
    } else {
      // For mobile, use share package
      await Share.share(content, subject: 'My Prescription Details');
    }
  }

  Future<void> _setReminders() async {
    // Placeholder for actual reminder functionality
    if (!isTranslated || medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No medications to set reminders for.')));
      return;
    }
    // In a real app, you would integrate with a notification/reminder package
    // e.g., flutter_local_notifications, awesome_notifications
    // Schedule notifications based on medication frequencies.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Reminders (Demo)'),
        content: const Text(
          'This feature is for demonstration. In a full app, reminders would be scheduled based on your prescription.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _findNearbyPharmacies() async {
    // Uses Google Maps search query
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=pharmacy+near+me');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url,
            mode: LaunchMode.externalApplication); // Prefer external app
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Could not open maps. Is a map application installed?')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening maps: $e')),
      );
    }
  }

  // Helper method for building Tool Cards - Defined within the State class
  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12), // Match Card's border radius
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF80CBC4)
                      .withOpacity(0.2), // Teal accent light
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF00796B), // Teal primary dark
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF00796B), // Teal primary dark
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00796B), // Teal Dark
              Color(0xFF26A69A), // Teal Medium
              Color(0xFF4DB6AC), // Teal Light
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Sliver App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent, // Use gradient background
                elevation: 0,
                floating: true, // App bar appears when scrolling down
                pinned: true, // App bar stays visible at the top
                expandedHeight: 150.0, // Height when expanded
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'மருந்து விளக்கி\nPrescription Translator',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                              blurRadius: 2.0,
                              color: Colors.black54,
                              offset: Offset(1, 1))
                        ]),
                    textAlign: TextAlign.center,
                  ),
                  centerTitle: true,
                  background: Container(
                    // Subtle gradient overlay on background image/icon
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.medical_services_outlined,
                        size: 60,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),

              // Main Content Area
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Upload Card ---
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.upload_file_rounded,
                                    color: Color(0xFF00796B),
                                    size: 30,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Upload Prescription',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00796B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Upload your prescription PDF (must contain text) for translation and analysis.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Upload Button
                              ElevatedButton.icon(
                                onPressed: isUploading
                                    ? null
                                    : _pickPdfFile, // Disable while uploading
                                icon: const Icon(Icons.picture_as_pdf_rounded),
                                label: const Text('SELECT PDF FILE'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00796B),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1.2,
                                  ),
                                  minimumSize: const Size(
                                      double.infinity, 50), // Full width button
                                ),
                              ),
                              // Display selected file name or uploading indicator
                              if (isUploading) ...[
                                const SizedBox(height: 24),
                                const Column(
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF00796B)),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Processing your prescription...',
                                      style: TextStyle(
                                        color: Color(0xFF00796B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (_fileName != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.teal[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.teal[100]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle_outline,
                                          size: 20, color: Colors.teal[700]),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _fileName!,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.teal[800],
                                              fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ), // End Upload Card

                      const SizedBox(height: 24),

                      // --- Results Section (Conditional) ---
                      if (isTranslated &&
                          !isUploading &&
                          medications.isNotEmpty) ...[
                        // Language Toggle Card
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Display Language',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00796B),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment(
                                      value: 'english',
                                      label: Text('English'),
                                      icon: Icon(Icons.language),
                                    ),
                                    ButtonSegment(
                                      value: 'tamil',
                                      label: Text('தமிழ்'),
                                      icon: Icon(Icons.translate),
                                    ),
                                    ButtonSegment(
                                      value: 'both',
                                      label: Text('Both'),
                                      icon: Icon(Icons.compare_arrows),
                                    ),
                                  ],
                                  // Use a non-const Set here as _displayLanguage changes
                                  selected: <String>{_displayLanguage},
                                  onSelectionChanged:
                                      (Set<String> newSelection) {
                                    setState(() {
                                      // Ensure only one selection is possible if needed
                                      _displayLanguage = newSelection.first;
                                    });
                                  },
                                  style: SegmentedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.grey[700],
                                    selectedBackgroundColor:
                                        const Color(0xFF80CBC4), // Teal accent
                                    selectedForegroundColor: Colors.white,
                                  ),
                                  showSelectedIcon:
                                      false, // Optional: hide checkmark
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tab Bar Container
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset:
                                        const Offset(0, -2) // Shadow above tabs
                                    )
                              ]),
                          child: TabBar(
                            controller: _tabController,
                            labelColor:
                                const Color(0xFF00796B), // Active tab color
                            unselectedLabelColor:
                                Colors.grey[600], // Inactive tab color
                            indicatorColor:
                                const Color(0xFF00796B), // Underline color
                            indicatorWeight: 3.0,
                            tabs: const [
                              Tab(
                                  icon: Icon(Icons.medication_outlined),
                                  text: 'Medications'),
                              Tab(
                                  icon: Icon(Icons.note_alt_outlined),
                                  text: 'Notes'),
                              Tab(
                                  icon: Icon(Icons.build_circle_outlined),
                                  text: 'Tools'),
                            ],
                          ),
                        ),

                        // Tab Content Container
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          // Use ConstrainedBox for flexible height
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minHeight: 300, // Ensure minimum height
                                maxHeight:
                                    600 // Limit maximum height for scrollability
                                ),
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // --- Medications Tab ---
                                _buildMedicationsTab(),

                                // --- Notes Tab ---
                                _buildNotesTab(),

                                // --- Tools Tab ---
                                _buildToolsTab(),
                              ],
                            ),
                          ),
                        ),
                      ], // End conditional results section

                      // Show message if translated but no meds found
                      if (isTranslated && !isUploading && medications.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30.0),
                          child: Card(
                            color: Colors.yellow[50],
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'Processing complete, but no medication details could be extracted. Please ensure the PDF contains clear, selectable text.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.orange[800], fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                    ], // Children of main Column
                  ),
                ), // Padding
              ), // SliverToBoxAdapter
            ], // Slivers
          ),
        ), // SafeArea
      ), // Container
    ); // Scaffold
  }

  // Helper method to build Medications Tab content
  Widget _buildMedicationsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Medications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00796B),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            // Use ListView.separated for dividers
            child: ListView.separated(
              itemCount: medications.length,
              itemBuilder: (context, index) {
                return MedicationCard(
                  medication: medications[index],
                  displayLanguage:
                      _displayLanguage, // Pass current language choice
                );
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 8), // Space between cards
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build Notes Tab content
  Widget _buildNotesTab() {
    // Determine which notes to display based on the selected language
    bool showEnglishNotes =
        _displayLanguage == 'english' || _displayLanguage == 'both';
    bool showTamilNotes =
        _displayLanguage == 'tamil' || _displayLanguage == 'both';

    List<Widget> noteWidgets = [];
    String title = "Doctor's Notes";

    if (showEnglishNotes && doctorNotesEnglish.isNotEmpty) {
      if (showTamilNotes && doctorNotesTamil.isNotEmpty) {
        // Add header if showing both
        noteWidgets.add(const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text("English:",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black54)),
        ));
      }
      noteWidgets.addAll(
          doctorNotesEnglish.map((note) => _buildNoteItem(note)).toList());
      if (showTamilNotes && doctorNotesTamil.isNotEmpty) {
        noteWidgets.add(const SizedBox(height: 16)); // Spacer between languages
      }
    }
    if (showTamilNotes && doctorNotesTamil.isNotEmpty) {
      if (showEnglishNotes && doctorNotesEnglish.isNotEmpty) {
        // Add header if showing both
        noteWidgets.add(const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text("தமிழ்:",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black54)),
        ));
      }
      noteWidgets.addAll(
          doctorNotesTamil.map((note) => _buildNoteItem(note)).toList());
    }

    // Determine title based on displayed content
    if (showEnglishNotes && !showTamilNotes) title = "Doctor's Notes (English)";
    if (!showEnglishNotes && showTamilNotes)
      title = "மருத்துவரின் குறிப்புகள் (தமிழ்)";
    if (showEnglishNotes && showTamilNotes)
      title = "Doctor's Notes / மருத்துவரின் குறிப்புகள்";

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00796B),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: (doctorNotesEnglish.isEmpty && doctorNotesTamil.isEmpty)
                ? Center(
                    child: Text("No specific doctor's notes found.",
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 16)))
                : ListView(
                    children: noteWidgets, // Display the generated note widgets
                  ),
          ),
        ],
      ),
    );
  }

  // Helper widget for individual note items in the Notes Tab
  Widget _buildNoteItem(String noteText) {
    return Card(
      elevation: 1,
      color: Colors.blueGrey[50],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.blueGrey[100]!)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.speaker_notes_outlined,
              color: Colors.blueGrey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                noteText,
                style: TextStyle(fontSize: 16, color: Colors.blueGrey[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build Tools Tab content
  Widget _buildToolsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Helpful Tools',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00796B),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            // Use ListView for scrollability if more tools are added
            child: ListView(
              children: [
                _buildToolCard(
                  icon: Icons.share_rounded,
                  title: 'Share Prescription',
                  description: 'Share details based on selected language',
                  onTap: _sharePrescriptionDetails,
                ),
                _buildToolCard(
                  icon: Icons.notifications_active_rounded,
                  title: 'Set Medication Reminders',
                  description: 'Setup reminders for your medications (Demo)',
                  onTap: _setReminders,
                ),
                _buildToolCard(
                  icon: Icons.local_pharmacy_rounded,
                  title: 'Find Nearby Pharmacies',
                  description: 'Locate pharmacies near you using maps',
                  onTap: _findNearbyPharmacies,
                ),
                // Add more tools here if needed
              ],
            ),
          ),
        ],
      ),
    );
  }
} // End _PrescriptionScreenState

// --- Medication Card Widget ---
class MedicationCard extends StatelessWidget {
  final MedicationInfo medication;
  final String displayLanguage; // To control which language(s) to show

  const MedicationCard({
    super.key, // Use super.key for widget constructors
    required this.medication,
    required this.displayLanguage,
  });

  @override
  Widget build(BuildContext context) {
    // Determine visibility based on displayLanguage
    bool showEnglish =
        displayLanguage == 'english' || displayLanguage == 'both';
    bool showTamil = displayLanguage == 'tamil' || displayLanguage == 'both';

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero, // Margin is handled by ListView.separated
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Medication Name Section ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF80CBC4)
                        .withOpacity(0.2), // Teal accent light
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.medication_liquid_rounded, // More specific icon
                    color: Color(0xFF00796B), // Teal primary dark
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showEnglish)
                        Text(
                          medication.nameEnglish,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      if (showTamil)
                        Padding(
                          // Add slight padding if both are shown
                          padding: EdgeInsets.only(top: showEnglish ? 4.0 : 0),
                          child: Text(
                            medication.nameTamil,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: showEnglish
                                  ? Colors.black54
                                  : Colors
                                      .black87, // Dim Tamil if English shown
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(), // Visual separator
            const SizedBox(height: 10),

            // --- Medication Details Section ---
            // Using the helper method for each detail line
            _buildMedicationDetail(
              icon: Icons.straighten_rounded, // Dosage icon
              titleEnglish: 'Dosage',
              titleTamil: 'அளவு',
              valueEnglish: medication.dosageEnglish,
              valueTamil: medication.dosageTamil,
              showEnglish: showEnglish,
              showTamil: showTamil,
            ),
            _buildMedicationDetail(
              icon: Icons.access_time_filled_rounded, // Frequency icon
              titleEnglish: 'Frequency',
              titleTamil: 'அடுக்கு',
              valueEnglish: medication.frequencyEnglish,
              valueTamil: medication.frequencyTamil,
              showEnglish: showEnglish,
              showTamil: showTamil,
            ),
            _buildMedicationDetail(
              icon: Icons.calendar_today_rounded, // Duration icon
              titleEnglish: 'Duration',
              titleTamil: 'காலம்',
              valueEnglish: medication.durationEnglish,
              valueTamil: medication.durationTamil,
              showEnglish: showEnglish,
              showTamil: showTamil,
            ),
            _buildMedicationDetail(
              icon: Icons.info_outline_rounded, // Instructions icon
              titleEnglish: 'Instructions',
              titleTamil: 'அறிவுறுத்தல்கள்',
              valueEnglish: medication.instructionsEnglish,
              valueTamil: medication.instructionsTamil,
              showEnglish: showEnglish,
              showTamil: showTamil,
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Method for Medication Detail Row (within MedicationCard) ---
  Widget _buildMedicationDetail({
    required IconData icon,
    required String titleEnglish,
    required String titleTamil,
    required String valueEnglish,
    required String valueTamil,
    required bool showEnglish,
    required bool showTamil,
  }) {
    // Don't build the row if neither language is selected for display
    if (!showEnglish && !showTamil) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF00796B), // Teal primary dark
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showEnglish)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[850],
                          height: 1.4), // Default text style
                      children: [
                        TextSpan(
                          text: '$titleEnglish: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        TextSpan(
                          text: valueEnglish,
                        ),
                      ],
                    ),
                  ),
                if (showTamil)
                  Padding(
                    padding: EdgeInsets.only(
                        top: showEnglish ? 4.0 : 0), // Space if both shown
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[850],
                            height: 1.4), // Default text style
                        children: [
                          TextSpan(
                            text: '$titleTamil: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          TextSpan(
                            text: valueTamil,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
