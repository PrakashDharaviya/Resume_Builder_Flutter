import 'package:equatable/equatable.dart';

abstract class ATSEvent extends Equatable {
  const ATSEvent();

  @override
  List<Object?> get props => [];
}

class AnalyzeResumeEvent extends ATSEvent {
  final Map<String, dynamic> resumeData;

  const AnalyzeResumeEvent(this.resumeData);

  @override
  List<Object?> get props => [resumeData];
}
