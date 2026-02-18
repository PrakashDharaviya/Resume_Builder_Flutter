import 'package:equatable/equatable.dart';
import '../../domain/entities/ats_analysis.dart';

abstract class ATSState extends Equatable {
  const ATSState();

  @override
  List<Object?> get props => [];
}

class ATSInitial extends ATSState {
  const ATSInitial();
}

class ATSAnalyzing extends ATSState {
  const ATSAnalyzing();
}

class ATSAnalysisComplete extends ATSState {
  final ATSAnalysis analysis;

  const ATSAnalysisComplete(this.analysis);

  @override
  List<Object?> get props => [analysis];
}

class ATSError extends ATSState {
  final String message;

  const ATSError(this.message);

  @override
  List<Object?> get props => [message];
}
