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
    on<LoadAllResumesEvent>(onLoadAllResumes);
    on<LoadResumeByIdEvent>(onLoadResumeById);
    on<CreateResumeEvent>(onCreateResume);
    on<UpdateResumeEvent>(onUpdateResume);
    on<DeleteResumeEvent>(onDeleteResume);
    on<SelectResumeEvent>(onSelectResume);
  }

  Future<void> onLoadAllResumes(
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

  Future<void> onLoadResumeById(
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

  Future<void> onCreateResume(
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

  Future<void> onUpdateResume(
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

  Future<void> onDeleteResume(
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

  void onSelectResume(SelectResumeEvent event, Emitter<ResumeState> emit) {
    emit(ResumeSelected(event.resume));
  }
}
