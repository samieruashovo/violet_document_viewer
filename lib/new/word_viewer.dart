import 'package:flutter/material.dart';
import 'package:open_document/my_files/init.dart';
import 'package:open_document/open_document.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permission_service.dart';

class WOrdViewer extends StatefulWidget {
  final String filePath;

  const WOrdViewer({super.key, required this.filePath});
  @override
  _WOrdViewerState createState() => _WOrdViewerState();
}

class _WOrdViewerState extends State<WOrdViewer> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    // Wakelock.enable();
    super.initState();
    // if (!Platform.isMacOS) initCheckPermission();

    initPlatformState();
  }

  // void initCheckPermission() async {
  //   final _handler = PermissionsService();
  //   await _handler.requestPermission(
  //     Permission.storage,
  //     onPermissionDenied: () => setState(
  //       () => debugPrint("Error: "),
  //     ),
  //   );
  // }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String filePath;
    final url =
        "https://fase.org.br/wp-content/uploads/2014/05/exemplo-de-pdf.pdf";
    //final url = "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-zip-file.zip";
    //
    // Platform messages may fail, so we use a try/catch PlatformException.
    //"https://file-examples-com.github.io/uploads/2017/02/file_example_XLS_5000.xls";
    //"https://file-examples-com.github.io/uploads/2017/02/file_example_XLS_5000.xls";
    //"https://file-examples-com.github.io/uploads/2017/02/zip_10MB.zip";

    final name = await OpenDocument.getNameFile(url: url);

    final path = await OpenDocument.getPathDocument();

    filePath = "$path/$name";

    final isCheck = await OpenDocument.checkDocument(filePath: filePath);

    debugPrint("Exist: $isCheck \nPath: $filePath");
    try {
      if (!isCheck) {
        filePath = filePath;
      }
      await OpenDocument.openDocument(
        filePath: filePath,
      );
    } on OpenDocumentException catch (e) {
      debugPrint("ERROR: ${e.errorMessage}");
      filePath = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = filePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    StyleMyFile.elevatedButtonText = "Compartilhar";
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _pushScreen(),
          child: Icon(Icons.open_in_new),
        ),
      ),
    );
  }

  // Future<String> downloadFile(
  //     {required String filePath, required String url}) async {
  //   // CancelToken cancelToken = CancelToken();
  //   Dio dio = new Dio();
  //   await dio.download(
  //     url,
  //     filePath,
  //     onReceiveProgress: (count, total) {
  //       debugPrint('---Download----Rec: $count, Total: $total');
  //       setState(() {
  //         _platformVersion = ((count / total) * 100).toStringAsFixed(0) + "%";
  //       });
  //     },
  //   );

  //   return filePath;
  // }

  _pushScreen() async {
    String name = await OpenDocument.getNameFolder();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MyFilesScreen(filePath: name),
      ),
    );
  }
}
