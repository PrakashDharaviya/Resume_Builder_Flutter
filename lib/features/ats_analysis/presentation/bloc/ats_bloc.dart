import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/analyze_resume.dart';
import 'ats_event.dart';
import 'ats_state.dart';

class ATSBloc extends Bloc<ATSEvent, ATSState> {
  final AnalyzeResume analyzeResume;

  ATSBloc({required this.analyzeResume}) : super(const ATSInitial()) {
    on<AnalyzeResumeEvent>(_onAnalyzeResume);
  }

  Future<void> _onAnalyzeResume(
    AnalyzeResumeEvent event,
    Emitter<ATSState> emit,
  ) async {
    emit(const ATSAnalyzing());

    final result = await analyzeResume(event.resumeData);

    result.fold(
      (failure) => emit(ATSError(failure.message)),
      (analysis) => emit(ATSAnalysisComplete(analysis)),
    );
  }
}
