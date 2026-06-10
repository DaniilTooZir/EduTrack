class BulkImportResult {
  final int imported;
  final List<String> skippedReasons;

  const BulkImportResult({required this.imported, required this.skippedReasons});

  int get skipped => skippedReasons.length;
}
