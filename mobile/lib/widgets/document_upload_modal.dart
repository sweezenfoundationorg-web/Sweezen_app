import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import 'custom_gold_button.dart';

class UploadedDocResult {
  final String fileName;
  final String docType;
  final String fileSize;
  final String uploadDate;
  final String? filePath;

  UploadedDocResult({
    required this.fileName,
    required this.docType,
    required this.fileSize,
    required this.uploadDate,
    this.filePath,
  });
}

class DocumentUploadModal extends StatefulWidget {
  final String initialDocType;

  const DocumentUploadModal({
    Key? key,
    this.initialDocType = 'Government ID Proof',
  }) : super(key: key);

  static Future<UploadedDocResult?> show(BuildContext context, {String docType = 'Government ID Proof'}) {
    return showModalBottomSheet<UploadedDocResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DocumentUploadModal(initialDocType: docType),
    );
  }

  @override
  State<DocumentUploadModal> createState() => _DocumentUploadModalState();
}

class _DocumentUploadModalState extends State<DocumentUploadModal> {
  late String _selectedDocType;
  String? _selectedFileName;
  String? _selectedFileSize;
  String? _selectedFilePath;

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _statusMessage = '';

  final List<String> _docTypes = [
    'Government ID Proof (Aadhaar / Voter ID)',
    'PAN Card / Tax ID',
    'Educational Degree / Student ID',
    'Resume / CV (PDF)',
    'Field Volunteer Certification',
  ];

  final List<Map<String, String>> _sampleFiles = [
    {'name': 'aadhaar_card_aarav_sharma.pdf', 'size': '1.8 MB', 'type': 'PDF Document'},
    {'name': 'voter_id_proof_card_2026.jpg', 'size': '2.4 MB', 'type': 'JPG Image'},
    {'name': 'resume_aarav_sharma_sweezen.pdf', 'size': '850 KB', 'type': 'PDF Document'},
    {'name': 'pan_card_verification.png', 'size': '1.2 MB', 'type': 'PNG Image'},
    {'name': 'panchayat_recommendation_letter.pdf', 'size': '3.1 MB', 'type': 'PDF Document'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDocType = widget.initialDocType;
  }

  Future<void> _pickFromFileManager() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final sizeInMb = (file.size / (1024 * 1024)).toStringAsFixed(1);
        setState(() {
          _selectedFileName = file.name;
          _selectedFileSize = '${sizeInMb} MB';
          _selectedFilePath = file.path;
        });
      }
    } catch (e) {
      debugPrint('FilePicker error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final length = await image.length();
        final sizeInMb = (length / (1024 * 1024)).toStringAsFixed(1);
        setState(() {
          _selectedFileName = image.name;
          _selectedFileSize = '${sizeInMb} MB';
          _selectedFilePath = image.path;
        });
      }
    } catch (e) {
      debugPrint('ImagePicker gallery error: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final length = await photo.length();
        final sizeInMb = (length / (1024 * 1024)).toStringAsFixed(1);
        setState(() {
          _selectedFileName = photo.name;
          _selectedFileSize = '${sizeInMb} MB';
          _selectedFilePath = photo.path;
        });
      }
    } catch (e) {
      debugPrint('ImagePicker camera error: $e');
    }
  }

  void _selectSampleFile(Map<String, String> file) {
    setState(() {
      _selectedFileName = file['name'];
      _selectedFileSize = file['size'];
      _selectedFilePath = null;
    });
  }

  void _startUpload() async {
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or browse a document file first!')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.1;
      _statusMessage = 'Encrypting document file...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _uploadProgress = 0.45;
      _statusMessage = 'Uploading to Sweezen Secure Cloud storage...';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _uploadProgress = 0.85;
      _statusMessage = 'Verifying OCR and document authenticity...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _uploadProgress = 1.0;
      _statusMessage = 'Upload Completed & Verified!';
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final result = UploadedDocResult(
      fileName: _selectedFileName!,
      docType: _selectedDocType,
      fileSize: _selectedFileSize ?? '1.5 MB',
      uploadDate: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      filePath: _selectedFilePath,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.primaryNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppTheme.goldAccent, width: 2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title & Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.cardNavy,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.goldAccent.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.cloud_upload_rounded, color: AppTheme.goldAccent, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select & Upload Document',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Supports PDF, JPG, PNG up to 10MB',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Document Type Dropdown
            const Text('Document Type:', style: TextStyle(color: AppTheme.amberGold, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _docTypes.contains(_selectedDocType) ? _selectedDocType : _docTypes.first,
                  isExpanded: true,
                  dropdownColor: AppTheme.cardNavy,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.amberGold),
                  items: _docTypes.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDocType = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Source Action Chips (Browse, Gallery, Camera)
            const Text('Choose Source:', style: TextStyle(color: AppTheme.amberGold, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSourceChip(Icons.folder_open, 'File Manager', _pickFromFileManager),
                const SizedBox(width: 8),
                _buildSourceChip(Icons.photo_library, 'Gallery', _pickFromGallery),
                const SizedBox(width: 8),
                _buildSourceChip(Icons.camera_alt, 'Camera Scan', _pickFromCamera),
              ],
            ),
            const SizedBox(height: 20),

            // File Selection Picker List
            const Text('Select File to Attach:', style: TextStyle(color: AppTheme.amberGold, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: _sampleFiles.map((file) {
                  final isSelected = _selectedFileName == file['name'];
                  final isPdf = file['name']!.endsWith('.pdf');
                  return GestureDetector(
                    onTap: () => _selectSampleFile(file),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.amberGold.withOpacity(0.15) : Colors.transparent,
                        border: Border(bottom: BorderSide(color: Colors.white10)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPdf ? Icons.picture_as_pdf : Icons.image,
                            color: isPdf ? Colors.redAccent : AppTheme.amberGold,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file['name']!,
                                  style: TextStyle(
                                    color: isSelected ? AppTheme.lightGold : Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${file['type']} • ${file['size']}',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: AppTheme.amberGold)
                          else
                            const Icon(Icons.circle_outlined, color: Colors.white30, size: 20),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Selected File Preview Card
            if (_selectedFileName != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardNavy,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.goldAccent.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, color: AppTheme.goldAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ready to upload: $_selectedFileName', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('Size: ${_selectedFileSize ?? "1.5 MB"}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Progress Bar if Uploading
            if (_isUploading) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_statusMessage, style: const TextStyle(color: AppTheme.amberGold, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('${(_uploadProgress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _uploadProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.amberGold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Submit Upload Button
            SizedBox(
              width: double.infinity,
              child: CustomGoldButton(
                text: _isUploading ? 'UPLOADING...' : 'CONFIRM & UPLOAD DOCUMENT',
                icon: Icons.upload_file_rounded,
                onPressed: _isUploading ? () {} : _startUpload,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceChip(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.cardNavy,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.amberGold, size: 20),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
