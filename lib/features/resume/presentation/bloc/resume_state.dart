import 'package:equatable/equatable.dart';
import '../../domain/entities/resume.dart';

abstract class ResumeState extends Equatable {
  const ResumeState();

  @override
  List<Object?> get props => [];
}

class ResumeInitial extends ResumeState {
  const ResumeInitial();
}

class ResumeLoading extends ResumeState {
  const ResumeLoading();
}

class ResumeListLoaded extends ResumeState {
  final List<Resume> resumes;

  const ResumeListLoaded(this.resumes);

  @override
  List<Object?> get props => [resumes];
}

class ResumeLoaded extends ResumeState {
  final Resume resume;

  const ResumeLoaded(this.resume);

  @override
  List<Object?> get props => [resume];
}

class ResumeSelected extends ResumeState {
  final Resume resume;

  const ResumeSelected(this.resume);

  @override
  List<Object?> get props => [resume];
}

class ResumeCreated extends ResumeState {
  final Resume resume;

  const ResumeCreated(this.resume);

  @override
  List<Object?> get props => [resume];
}

class ResumeUpdated extends ResumeState {
  final Resume resume;

  const ResumeUpdated(this.resume);

  @override
  List<Object?> get props => [resume];
}

class ResumeDeleted extends ResumeState {
  const ResumeDeleted();
}

class ResumeError extends ResumeState {
  final String message;

  const ResumeError(this.message);

  @override
  List<Object?> get props => [message];
}
