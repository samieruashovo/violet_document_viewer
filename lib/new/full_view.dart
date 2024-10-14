import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'word_viewer.dart';

class DocumentReaderApp extends StatefulWidget {
  @override
  _DocumentReaderAppState createState() => _DocumentReaderAppState();
}

class _DocumentReaderAppState extends State<DocumentReaderApp> {
  String? selectedFile;
  late TreeViewController _treeViewController;
  List<Node> rootNodes = [];

  @override
  void initState() {
    super.initState();
    _loadHomeDirectory(); // Load the user's home directory
  }

  /// Load the user's home directory
  void _loadHomeDirectory() {
    String? homeDirectory = _getHomeDirectory();

    if (homeDirectory != null) {
      Directory rootDirectory = Directory(homeDirectory);
      List<Node> rootDirectoryNodes = _buildFileSystemTree(rootDirectory);

      rootNodes.add(Node(
        label: 'Home',
        key: homeDirectory,
        children: rootDirectoryNodes,
        expanded: true,
      ));

      // Initialize the TreeViewController with the root node
      _treeViewController = TreeViewController(children: rootNodes);
    }
  }

  /// Get the home directory for the current user on Linux
  String? _getHomeDirectory() {
    if (Platform.isLinux || Platform.isMacOS) {
      return Platform.environment['HOME']; // Fetch the home directory path
    }
    return null;
  }

  /// Recursively build folder and file structure into tree nodes
  List<Node> _buildFileSystemTree(Directory directory) {
    List<Node> nodeList = [];
    try {
      List<FileSystemEntity> entities = directory.listSync();
      for (var entity in entities) {
        if (entity is Directory) {
          try {
            entity.listSync(); // This throws an exception if access is denied
            nodeList.add(Node(
              label: entity.path.split('/').last, // Folder name
              key: entity.path,
              children:
                  _buildFileSystemTree(entity), // Recursively add children
              expanded: false,
            ));
          } catch (e) {
            print("Permission denied: ${entity.path}");
          }
        } else if (entity is File &&
            (entity.path.endsWith('.pdf') ||
                entity.path.endsWith('.xlsx') ||
                entity.path.endsWith('.xls') ||
                entity.path.endsWith('.doc') ||
                entity.path.endsWith('.docx'))) {
          nodeList.add(Node(
            label: entity.path.split('/').last, // File name
            key: entity.path,
          ));
        }
      }
    } catch (e) {
      print("Error reading directory: $e");
    }
    return nodeList;
  }

  // String? selectedFileContent;

  /// Handle node tap (file selection)
  void _onNodeTap(String key) {
    setState(() {
      selectedFile = key;
    });
  }

  double _leftPanelWidth = 0.3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Violet Document Reader')),
      ),
      body: Row(
        children: [
          // Left side: Tree view for folders and files
          Expanded(
            flex: (_leftPanelWidth * 100).toInt(),
            child: TreeView(
              controller: _treeViewController,
              allowParentSelect: true,
              supportParentDoubleTap: true,
              onNodeTap: (key) {
                _onNodeTap(key);
              },
              theme: const TreeViewTheme(
                expanderTheme: ExpanderThemeData(
                  type: ExpanderType.plusMinus,
                  modifier: ExpanderModifier.none,
                  position: ExpanderPosition.start,
                  color: Colors.blue,
                  size: 20,
                ),
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                parentLabelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Drag handle to resize
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              setState(() {
                // Adjust the width based on drag
                _leftPanelWidth +=
                    details.delta.dx / MediaQuery.of(context).size.width;

                // Limit the width within a valid range
                if (_leftPanelWidth < 0.1) _leftPanelWidth = 0.1;
                if (_leftPanelWidth > 0.7) _leftPanelWidth = 0.7;
              });
            },
            child: Container(
              width: 8.0, // Width of the draggable divider
              color: Colors.grey[300],
              child: Center(
                child: Container(
                  width: 2.0,
                  height: double.infinity,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),

          // Right side: Display selected file
          Expanded(
            flex: (100 - _leftPanelWidth * 100).toInt(),
            child: selectedFile == null
                ? const Center(child: Text('No file selected'))
                : selectedFile!.endsWith('.pdf')
                    ? PdfViewer.asset(File(selectedFile!).path)
                    : selectedFile!.endsWith('.docx') ||
                            selectedFile!.endsWith('.doc')
                        ? WordViewerPage(filePath: File(selectedFile!).path)
                        : selectedFile!.endsWith('xlsx') ||
                                selectedFile!.endsWith('xls')
                            ? WordViewerPage(filePath: File(selectedFile!).path)
                            : const Center(
                                child: Text('Unsupported file format')),
          ),
        ],
      ),
    );
  }
}

// void main() => runApp(MaterialApp(home: DocumentReaderApp()));
