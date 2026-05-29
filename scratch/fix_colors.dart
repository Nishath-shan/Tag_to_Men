import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.contains('theme.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    final originalContent = content;

    content = content.replaceAll('context.color.', 'context.');

    if (content != originalContent) {
      file.writeAsStringSync(content);
      print('Updated \${file.path}');
    }
  }
}
