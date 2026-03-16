import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';

final ocrProvider =
    StateNotifierProvider<OcrNotifier, AsyncValue<Map<String, String>?>>((ref) {
  return OcrNotifier();
});

class OcrNotifier extends StateNotifier<AsyncValue<Map<String, String>?>> {
  OcrNotifier() : super(const AsyncValue.data(null));

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  /// Scans bill using Camera (Currently using ImagePicker, but native edge detection/crop can be used here)
  Future<void> scanFromCamera() async {
    state = const AsyncValue.loading();
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) {
        state = const AsyncValue.data(null);
        return;
      }
      await _processImageFile(File(image.path));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Uploads bill image from Gallery
  Future<void> scanFromGallery() async {
    state = const AsyncValue.loading();
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        state = const AsyncValue.data(null);
        return;
      }
      await _processImageFile(File(image.path));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Uploads bill PDF
  Future<void> scanFromPdf() async {
    state = const AsyncValue.loading();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.single.path == null) {
        state = const AsyncValue.data(null);
        return;
      }
      final document = PdfDocument(inputBytes: await File(result.files.single.path!).readAsBytes());
      final String text = PdfTextExtractor(document).extractText();
      document.dispose();
      final parsedData = _parseBillText(text);
      state = AsyncValue.data(parsedData);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _processImageFile(File file) async {
    try {
      // Preprocess image for OCR accuracy: Grayscale, Contrast, etc.
      final preprocessedFile = await _preprocessImage(file);
      
      final inputImage = InputImage.fromFile(preprocessedFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      final parsedData = _parseBillText(recognizedText.text);
      state = AsyncValue.data(parsedData);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<File> _preprocessImage(File originalImage) async {
    // 1. Read bytes
    final bytes = await originalImage.readAsBytes();
    img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) return originalImage;

    // 2. Grayscale
    img.grayscale(decodedImage);

    // 3. Contrast adjustment 
    // We adjust color contrast using the image library (e.g. factor 1.5)
    img.adjustColor(decodedImage, contrast: 1.5);

    // NOTE: Edge Detection, Auto Crop, Remove Shadows can be added via 
    // OpenCV natively or cunning_document_scanner for camera captures in real-world scenarios.
    
    // 4. Save to temp directory
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/preprocessed_ocr_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(img.encodeJpg(decodedImage, quality: 90));
    return tempFile;
  }

  Map<String, String> _parseBillText(String text) {
    final data = <String, String>{};
    
    // Amount matching
    final amountRegex = RegExp(r'(?:Rs\.?|₹|Amount|Total|Amt.)\s*([\d,]+(?:[\.\d]+)?)', caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(text);
    if (amountMatch != null) {
      data['amountExact'] = amountMatch.group(1)?.replaceAll(',', '') ?? '';
    }
    
    // Due Date matching
    final dueRegex = RegExp(r'(?:Due Date|dueDate|Pay By)\s*[:\-]*\s*(\d{2}[/\-]\d{2}[/\-]\d{2,4})', caseSensitive: false);
    final dueMatch = dueRegex.firstMatch(text);
    if (dueMatch != null) {
      data['dueDate'] = dueMatch.group(1) ?? '';
    }

    // Units
    final unitsRegex = RegExp(r'(?:Units|Consumption)\s*[:\-]*\s*(\d+)', caseSensitive: false);
    final unitsMatch = unitsRegex.firstMatch(text);
    if (unitsMatch != null) {
      data['units'] = unitsMatch.group(1) ?? '';
    }

    // Bill Number
    final billRegex = RegExp(r'(?:Bill No|Invoice No|Doc No|Bill #)\s*[:\-]*\s*([A-Za-z0-9\-]+)', caseSensitive: false);
    final billMatch = billRegex.firstMatch(text);
    if (billMatch != null) {
      data['billNumber'] = billMatch.group(1) ?? '';
    }

    data['rawText'] = text; 
    return data;
  }
}
