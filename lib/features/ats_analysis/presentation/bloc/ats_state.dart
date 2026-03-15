import 'package:equatable/equatable.dart';
import 'package:resumebuilder/features/ats_analysis/domain/entities/ats_analysis.dart';

abstract class ATSState extends Equatable {
  const ATSState();

  @override
  List<Object?> get props => [];
}

class ATSInitial extends ATSState {
  const ATSInitial();
}

class AtsAnalysisLoading extends ATSState {
  const AtsAnalysisLoading();
}

class ATSAnalysisComplete extends ATSState {
  final ATSAnalysis analysis;

  const ATSAnalysisComplete(this.analysis);

  @override
  List<Object?> get props => [analysis];
}

class AtsAnalysisTimeout extends ATSState {
  final String message;

  const AtsAnalysisTimeout(this.message);

  @override
  List<Object?> get props => [message];
}

class AtsAnalysisError extends ATSState {
  final String message;

  const AtsAnalysisError(this.message);

  @override
  List<Object?> get props => [message];
}
