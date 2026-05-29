import 'dart:io';

void main() {
  final result = Process.runSync('flutter.bat', ['analyze', '--no-fatal-infos']);
  final lines = result.stdout.toString().split('\n');
  for (final line in lines) {
    if (line.contains('invalid_constant') || line.contains('const_initialized_with_non_constant_value')) {
      final parts = line.split(' - ');
      if (parts.length >= 3) {
        final locationPart = parts[2]; 
        final locParts = locationPart.split(':');
        if (locParts.length >= 2) {
          final filePath = locParts[0].trim();
          final lineNumber = int.tryParse(locParts[1]);

          if (lineNumber != null) {
            final targetFile = File(filePath);
            if (targetFile.existsSync()) {
              final fileLines = targetFile.readAsLinesSync();
              final idx = lineNumber - 1;
              if (idx >= 0 && idx < fileLines.length) {
                bool fixed = false;
                // search backwards for the nearest 'const' up to 5 lines
                for (int i = idx; i >= 0 && i >= idx - 5; i--) {
                  var targetLine = fileLines[i];
                  if (targetLine.contains('const ')) {
                    if (RegExp(r'const\s+[a-zA-Z0-9_]+\s*=').hasMatch(targetLine)) {
                      fileLines[i] = targetLine.replaceFirst('const ', 'final ');
                    } else {
                      fileLines[i] = targetLine.replaceFirst('const ', '');
                    }
                    fixed = true;
                    break;
                  }
                }
                if (fixed) {
                  targetFile.writeAsStringSync(fileLines.join('\n'));
                  print('Fixed \$filePath:\$lineNumber');
                }
              }
            }
          }
        }
      }
    }
  }
}
