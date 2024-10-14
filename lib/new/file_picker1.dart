import 'package:file_picker/file_picker.dart';

Future<void> pickDirectory() async {
  String? directoryPath = await FilePicker.platform.getDirectoryPath();
  if (directoryPath != null) {
    // Display files and folders in the UI
  }
}
