import 'dart:io';

class CoverageSummary {
  CoverageSummary({required this.linesFound, required this.linesHit});

  final int linesFound;
  final int linesHit;

  double get percent => linesFound == 0 ? 100.0 : (linesHit / linesFound) * 100;
}

void main(List<String> arguments) {
  final filePath = arguments.isNotEmpty ? arguments.first : 'coverage/lcov.info';
  final file = File(filePath);
  if (!file.existsSync()) {
    stderr.writeln('Coverage file not found at $filePath');
    exit(1);
  }

  final summaryByFile = <String, CoverageSummary>{};
  String? currentFile;
  int? linesFound;
  int? linesHit;

  for (final rawLine in file.readAsLinesSync()) {
    final line = rawLine.trim();
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      linesFound = 0;
      linesHit = 0;
    } else if (line.startsWith('LF:')) {
      linesFound = int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      linesHit = int.parse(line.substring(3));
    } else if (line == 'end_of_record' && currentFile != null) {
      if (linesFound != null && linesHit != null) {
        summaryByFile[currentFile] = CoverageSummary(
          linesFound: linesFound!,
          linesHit: linesHit!,
        );
      }
      currentFile = null;
      linesFound = null;
      linesHit = null;
    }
  }

  var totalFound = 0;
  var totalHit = 0;
  final entries = summaryByFile.entries.toList()
    ..sort((a, b) => a.value.percent.compareTo(b.value.percent));

  stdout.writeln('Coverage summary (${entries.length} files)');
  for (final entry in entries) {
    final relative = entry.key.replaceAll('\\', '/');
    stdout.writeln(
      '${entry.value.percent.toStringAsFixed(1).padLeft(6)}% | '
      '${entry.value.linesHit.toString().padLeft(4)}/${entry.value.linesFound.toString().padRight(4)} | '
      '$relative',
    );
    totalFound += entry.value.linesFound;
    totalHit += entry.value.linesHit;
  }

  stdout.writeln('\nTotal coverage: '
      '${totalHit.toString()}/${totalFound.toString()} '
      '(${totalFound == 0 ? '0.0' : (totalHit / totalFound * 100).toStringAsFixed(1)}%)');
}
