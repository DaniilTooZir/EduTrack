import 'dart:io';

import 'package:edu_track/models/academic_period.dart';
import 'package:edu_track/models/final_grade.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/lesson_attendance.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/utils/date_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const _kGradeColors = {
  5: PdfColor(0.180, 0.490, 0.196),
  4: PdfColor(0.333, 0.545, 0.184),
  3: PdfColor(0.902, 0.318, 0.000),
};
const _kRedColor = PdfColor(0.729, 0.094, 0.094);

PdfColor _gradeColor(int value) => _kGradeColors[value] ?? _kRedColor;

PdfColor _avgColor(double avg) {
  if (avg >= 4.5) return _kGradeColors[5]!;
  if (avg >= 3.5) return _kGradeColors[4]!;
  if (avg >= 2.5) return _kGradeColors[3]!;
  return _kRedColor;
}

class JournalPdfExporter {
  static Future<void> share({
    required List<Student> students,
    required List<Lesson> lessons,
    required Map<String, Grade> gradeMap,
    required Map<String, LessonAttendance> attendanceMap,
    required Map<String, DateTime?> lessonDateMap,
    required Map<String, FinalGrade> finalGradeMap,
    required AcademicPeriod? period,
    required String subjectName,
    required String groupName,
    String? pageLabel,
  }) async {
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    String fmtDate(DateTime? d) => d != null ? formatShortDate(d) : '?';

    double computeAvg(Student s) {
      final grades = lessons.map((l) => gradeMap['${s.id}|${l.id!}']).whereType<Grade>().toList();
      if (grades.isEmpty) return 0;
      return grades.map((g) => g.value).reduce((a, b) => a + b) / grades.length;
    }

    pw.Widget pad(pw.Widget child) =>
        pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3), child: child);

    pw.Widget hdr(String t) =>
        pad(pw.Text(t, textAlign: pw.TextAlign.center, style: pw.TextStyle(font: fontBold, fontSize: 7.5)));

    pw.Widget cell(String t, {PdfColor? color}) => pad(
      pw.Text(t, textAlign: pw.TextAlign.center, style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: color)),
    );

    pw.Widget gradeCell(Student student, Lesson lesson) {
      final key = '${student.id}|${lesson.id!}';
      final grade = gradeMap[key];
      final attendance = attendanceMap[key];
      if (grade != null) return cell('${grade.value}', color: _gradeColor(grade.value));
      if (attendance != null) return cell('Н', color: _kRedColor);
      return pad(pw.SizedBox());
    }

    pw.Widget avgCell(Student student) {
      final avg = computeAvg(student);
      if (avg == 0) return pad(pw.SizedBox());
      return cell(avg.toStringAsFixed(1), color: _avgColor(avg));
    }

    final showFinal = period != null;
    final colWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(130),
      for (var i = 0; i < lessons.length; i++) i + 1: const pw.FixedColumnWidth(36),
      lessons.length + 1: const pw.FixedColumnWidth(44),
      if (showFinal) lessons.length + 2: const pw.FixedColumnWidth(44),
    };

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header:
            (_) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Журнал успеваемости', style: pw.TextStyle(font: fontBold, fontSize: 15)),
                pw.SizedBox(height: 4),
                pw.Text('Предмет: $subjectName  ·  Группа: $groupName', style: pw.TextStyle(font: font, fontSize: 9.5)),
                if (period != null)
                  pw.Text(
                    pageLabel != null
                        ? 'Период: ${period.name}  ·  Месяц: $pageLabel'
                        : 'Период: ${period.name}  (${fmtDate(period.startDate)} — ${fmtDate(period.endDate)})',
                    style: pw.TextStyle(font: font, fontSize: 9),
                  ),
                pw.SizedBox(height: 6),
                pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                pw.SizedBox(height: 4),
              ],
            ),
        build:
            (_) => [
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: colWidths,
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pad(pw.Text('Студент', style: pw.TextStyle(font: fontBold, fontSize: 7.5))),
                      for (final l in lessons) hdr(fmtDate(lessonDateMap[l.id])),
                      hdr('Ср.'),
                      if (showFinal) hdr('Итог'),
                    ],
                  ),
                  for (final student in students)
                    pw.TableRow(
                      children: [
                        pad(
                          pw.Text('${student.surname} ${student.name}', style: pw.TextStyle(font: font, fontSize: 7.5)),
                        ),
                        for (final lesson in lessons) gradeCell(student, lesson),
                        avgCell(student),
                        if (showFinal)
                          cell(
                            finalGradeMap[student.id]?.value.toString() ?? '—',
                            color:
                                finalGradeMap[student.id] != null
                                    ? _gradeColor(finalGradeMap[student.id]!.value)
                                    : PdfColors.grey600,
                          ),
                      ],
                    ),
                ],
              ),
            ],
      ),
    );

    final bytes = await doc.save();
    final filename = 'журнал_${groupName}_$subjectName.pdf';

    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Сохранить журнал успеваемости',
        fileName: filename,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (savePath != null) {
        final path = savePath.endsWith('.pdf') ? savePath : '$savePath.pdf';
        await File(path).writeAsBytes(bytes);
      }
    } else {
      await Printing.sharePdf(bytes: bytes, filename: filename);
    }
  }
}
