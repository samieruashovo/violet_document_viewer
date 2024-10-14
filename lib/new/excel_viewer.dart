import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<List<List<dynamic>>> loadExcelFile(String filepath) async {
  // Open a file picker to select an Excel file
  String? filePath = filepath;

  // = await FilePicker.platform.pickFiles(
  //   type: FileType.custom,
  //   allowedExtensions: ['xls', 'xlsx'],
  // ).then((result) => result?.files.single.path);

  if (filePath == null) {
    throw Exception('No file selected');
  }

  // Load the Excel file
  var bytes = File(filePath).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  // Extract data from the Excel file
  List<List<dynamic>> rows = [];
  for (var table in excel.tables.keys) {
    for (var row in excel.tables[table]!.rows) {
      rows.add(row.map((cell) => cell?.value).toList());
    }
  }
  return rows;
}

class ExcelViewer extends StatefulWidget {
  String filePath;
  ExcelViewer(this.filePath);
  @override
  _ExcelViewerState createState() => _ExcelViewerState();
}

class _ExcelViewerState extends State<ExcelViewer> {
  List<List<dynamic>>? _excelData;

  void _loadData() async {
    print(widget.filePath);
    try {
      final data = await loadExcelFile(widget.filePath);
      setState(() {
        _excelData = data;
      });
    } catch (e) {
      // Handle error (e.g., show a dialog)
      print(e);
    }
  }

  @override
  void initState() {
    _loadData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Excel Viewer'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.open_in_new),
      //       onPressed: _loadData,
      //     ),
      //   ],
      // ),
      body: _excelData == null
          ? Center(child: Text('Load an Excel file to see the data'))
          : SingleChildScrollView(
              child: DataTable(
                columns: _excelData![0]
                    .map((column) => DataColumn(label: Text(column.toString())))
                    .toList(),
                rows: _excelData!.sublist(1).map(
                  (row) {
                    return DataRow(
                      cells: row
                          .map((cell) => DataCell(Text(cell.toString())))
                          .toList(),
                    );
                  },
                ).toList(),
              ),
            ),
    );
  }
}
