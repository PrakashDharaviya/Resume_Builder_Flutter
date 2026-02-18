import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_resume.dart';
import '../../domain/usecases/delete_resume.dart';
import '../../domain/usecases/get_all_resumes.dart';
import '../../domain/usecases/get_resume_by_id.dart';
import '../../domain/usecases/update_resume.dart';
import 'resume_event.dart';
import 'resume_state.dart';

class ResumeBloc extends Bloc<ResumeEvent, ResumeState> {
  final GetAllResumes getAllResumes;
  final GetResumeById getResumeById;
  final CreateResume createResume;
  final UpdateResume updateResume;
  final DeleteResume deleteResume;

  ResumeBloc({
    required this.getAllResumes,
    required this.getResumeById,
    required this.createResume,
    required this.updateResume,
    required this.deleteResume,
  }) : super(const ResumeInitial()) {
    on<LoadAllResumesEvent>(_onLoadAllResumes);
    on<LoadResumeByIdEvent>(_onLoadResumeById);
    on<CreateResumeEvent>(_onCreateResume);
    on<UpdateResumeEvent>(_onUpdateResume);
    on<DeleteResumeEvent>(_onDeleteResume);
    on<SelectResumeEvent>(_onSelectResume);
  }

  Future<void> _onLoadAllResumes(
    LoadAllResumesEvent event,
    Emitter<ResumeState> emit,
  ) async {
    emit(const ResumeLoading());

    final result = await getAllResumes();

    result.fold(
      (failure) => emit(ResumeError(failure.message)),
      (resumes) => emit(ResumeListLoaded(resumes)),
    );
  }

  Future<void> _onLoadResumeById(
    LoadResumeByIdEvent event,
    Emitter<ResumeState> emit,
  ) async {
    emit(const ResumeLoading());

    final result = await getResumeById(event.id);

    result.fold(
      (failure) => emit(ResumeError(failure.message)),
      (resume) => emit(ResumeLoaded(resume)),
    );
  }

  Future<void> _onCreateResume(
    CreateResumeEvent event,
    Emitter<ResumeState> emit,
  ) async {
    emit(const ResumeLoading());

    final result = await createResume(event.resume);

    result.fold(
      (failure) => emit(ResumeError(failure.message)),
      (resume) => emit(ResumeCreated(resume)),
    );
  }

  Future<void> _onUpdateResume(
    UpdateResumeEvent event,
    Emitter<ResumeState> emit,
  ) async {
    emit(const ResumeLoading());

    final result = await updateResume(event.resume);

    result.fold(
      (failure) => emit(ResumeError(failure.message)),
      (resume) => emit(ResumeUpdated(resume)),
    );
  }

  Future<void> _onDeleteResume(
    DeleteResumeEvent event,
    Emitter<ResumeState> emit,
  ) async {
    emit(const ResumeLoading());

    final result = await deleteResume(event.id);

    result.fold(
      (failure) => emit(ResumeError(failure.message)),
      (_) => emit(const ResumeDeleted()),
    );
  }

  void _onSelectResume(SelectResumeEvent event, Emitter<ResumeState> emit) {
    emit(ResumeSelected(event.resume));
  }
}
