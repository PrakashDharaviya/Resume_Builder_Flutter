import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/ats_analysis/domain/usecases/analyze_resume.dart';
import 'package:resumebuilder/features/ats_analysis/presentation/bloc/ats_event.dart';
import 'package:resumebuilder/features/ats_analysis/presentation/bloc/ats_state.dart';

class ATSBloc extends Bloc<ATSEvent, ATSState> {
  final AnalyzeResume analyzeResume;

  ATSBloc({required this.analyzeResume}) : super(const ATSInitial()) {
    on<AnalyzeResumeEvent>(onAnalyzeResume);
  }

  Future<void> onAnalyzeResume(
    AnalyzeResumeEvent event,
    Emitter<ATSState> emit,
  ) async {
    emit(const AtsAnalysisLoading());

    final result = await analyzeResume(event.resumeData);

    result.fold((failure) {
      if (failure is TimeoutFailure) {
        emit(AtsAnalysisTimeout(failure.message));
      } else {
        emit(AtsAnalysisError(failure.message));
      }
    }, (analysis) => emit(ATSAnalysisComplete(analysis)));
  }
}
