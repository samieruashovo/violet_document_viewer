import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class WordViewerPage extends StatelessWidget {
  final String filePath;

  WordViewerPage({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OpenResult>(
      future: OpenFile.open(filePath),
      builder: (BuildContext context, AsyncSnapshot<OpenResult> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error occurred: ${snapshot.error}'); // Log the error
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          // Check if the file opened successfully
          if (snapshot.data?.type == ResultType.done) {
            return const SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Text("File opened successfully!"),
            );
          } else {
            return Center(
                child: Text("Could not open file: ${snapshot.data?.message}"));
          }
        }
        return const Center(child: Text("Unexpected state."));
      },
    );
  }
}
