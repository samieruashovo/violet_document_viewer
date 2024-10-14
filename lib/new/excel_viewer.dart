import 'package:excel/excel.dart';
import 'dart:io';

Future<void> readExcel(String filePath) async {
  var file = File(filePath);
  var bytes = file.readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  for (var table in excel.tables.keys) {
    print(table); //sheet Name
    // print(excel.tables[table]!.maxCols);
    print(excel.tables[table]!.maxRows);
    for (var row in excel.tables[table]!.rows) {
      print('$row');
    }
  }
}
