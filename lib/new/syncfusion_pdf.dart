import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfViewerPage extends StatelessWidget {
  final String filePath;

  PdfViewerPage({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return PdfViewer.asset('assets/hello.pdf');
  }
}
