import 'package:equatable/equatable.dart';
import '../../domain/entities/resume.dart';

abstract class ResumeEvent extends Equatable {
  const ResumeEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllResumesEvent extends ResumeEvent {
  const LoadAllResumesEvent();
}

class LoadResumeByIdEvent extends ResumeEvent {
  final String id;

  const LoadResumeByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateResumeEvent extends ResumeEvent {
  final Resume resume;

  const CreateResumeEvent(this.resume);

  @override
  List<Object?> get props => [resume];
}

class UpdateResumeEvent extends ResumeEvent {
  final Resume resume;

  const UpdateResumeEvent(this.resume);

  @override
  List<Object?> get props => [resume];
}

class DeleteResumeEvent extends ResumeEvent {
  final String id;

  const DeleteResumeEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectResumeEvent extends ResumeEvent {
  final Resume resume;

  const SelectResumeEvent(this.resume);

  @override
  List<Object?> get props => [resume];
}
