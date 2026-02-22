import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../auth/domain/entities/user.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;

  // Keep a cache for user search
  List<User> _cachedUsers = [];

  AdminBloc({required this.repository}) : super(const AdminInitial()) {
    // Dashboard
    on<LoadAdminDashboard>(_onLoadDashboard);

    // Templates
    on<LoadTemplates>(_onLoadTemplates);
    on<AddTemplate>(_onAddTemplate);
    on<UpdateTemplate>(_onUpdateTemplate);
    on<DeleteTemplate>(_onDeleteTemplate);

    // Users
    on<LoadUsers>(_onLoadUsers);
    on<ToggleBlockUser>(_onToggleBlockUser);
    on<TogglePremiumUser>(_onTogglePremiumUser);
    on<SearchUsers>(_onSearchUsers);

    // ATS Config
    on<LoadATSConfig>(_onLoadATSConfig);
    on<UpdateATSConfig>(_onUpdateATSConfig);

    // Announcements
    on<LoadAnnouncements>(_onLoadAnnouncements);
    on<AddAnnouncement>(_onAddAnnouncement);
    on<ToggleAnnouncement>(_onToggleAnnouncement);
    on<DeleteAnnouncement>(_onDeleteAnnouncement);
  }

  // ========== Dashboard ==========
  void _onLoadDashboard(LoadAdminDashboard event, Emitter<AdminState> emit) {
    emit(const AdminLoading());
    final result = repository.getAdminStats();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (stats) => emit(AdminDashboardLoaded(stats: stats)),
    );
  }

  // ========== Templates ==========
  void _onLoadTemplates(LoadTemplates event, Emitter<AdminState> emit) {
    emit(const AdminLoading());
    final result = repository.getAllTemplates();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (templates) => emit(TemplatesLoaded(templates: templates)),
    );
  }

  void _onAddTemplate(AddTemplate event, Emitter<AdminState> emit) {
    repository.addTemplate(event.template);
    final result = repository.getAllTemplates();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      templates,
    ) {
      emit(const AdminActionSuccess(message: 'Template added successfully'));
      emit(TemplatesLoaded(templates: templates));
    });
  }

  void _onUpdateTemplate(UpdateTemplate event, Emitter<AdminState> emit) {
    repository.updateTemplate(event.template);
    final result = repository.getAllTemplates();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      templates,
    ) {
      emit(const AdminActionSuccess(message: 'Template updated successfully'));
      emit(TemplatesLoaded(templates: templates));
    });
  }

  void _onDeleteTemplate(DeleteTemplate event, Emitter<AdminState> emit) {
    repository.deleteTemplate(event.templateId);
    final result = repository.getAllTemplates();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      templates,
    ) {
      emit(const AdminActionSuccess(message: 'Template deleted'));
      emit(TemplatesLoaded(templates: templates));
    });
  }

  // ========== Users ==========
  void _onLoadUsers(LoadUsers event, Emitter<AdminState> emit) {
    emit(const AdminLoading());
    final result = repository.getAllUsers();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      users,
    ) {
      _cachedUsers = users;
      emit(UsersLoaded(users: users));
    });
  }

  void _onToggleBlockUser(ToggleBlockUser event, Emitter<AdminState> emit) {
    repository.toggleBlockUser(event.uid);
    final result = repository.getAllUsers();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      users,
    ) {
      _cachedUsers = users;
      emit(const AdminActionSuccess(message: 'User status updated'));
      emit(UsersLoaded(users: users));
    });
  }

  void _onTogglePremiumUser(TogglePremiumUser event, Emitter<AdminState> emit) {
    repository.togglePremiumUser(event.uid);
    final result = repository.getAllUsers();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      users,
    ) {
      _cachedUsers = users;
      emit(const AdminActionSuccess(message: 'User premium status updated'));
      emit(UsersLoaded(users: users));
    });
  }

  void _onSearchUsers(SearchUsers event, Emitter<AdminState> emit) {
    if (event.query.isEmpty) {
      emit(UsersLoaded(users: _cachedUsers));
      return;
    }

    final query = event.query.toLowerCase();
    final filtered = _cachedUsers
        .where(
          (u) =>
              u.displayName.toLowerCase().contains(query) ||
              u.email.toLowerCase().contains(query),
        )
        .toList();

    emit(UsersLoaded(users: _cachedUsers, filteredUsers: filtered));
  }

  // ========== ATS Config ==========
  void _onLoadATSConfig(LoadATSConfig event, Emitter<AdminState> emit) {
    emit(const AdminLoading());
    final result = repository.getATSConfig();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (config) => emit(ATSConfigLoaded(config: config)),
    );
  }

  void _onUpdateATSConfig(UpdateATSConfig event, Emitter<AdminState> emit) {
    final result = repository.updateATSConfig(event.config);
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      config,
    ) {
      emit(const AdminActionSuccess(message: 'ATS configuration saved'));
      emit(ATSConfigLoaded(config: config));
    });
  }

  // ========== Announcements ==========
  void _onLoadAnnouncements(LoadAnnouncements event, Emitter<AdminState> emit) {
    emit(const AdminLoading());
    final result = repository.getAllAnnouncements();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (announcements) =>
          emit(AnnouncementsLoaded(announcements: announcements)),
    );
  }

  void _onAddAnnouncement(AddAnnouncement event, Emitter<AdminState> emit) {
    repository.addAnnouncement(event.announcement);
    final result = repository.getAllAnnouncements();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      announcements,
    ) {
      emit(const AdminActionSuccess(message: 'Announcement created'));
      emit(AnnouncementsLoaded(announcements: announcements));
    });
  }

  void _onToggleAnnouncement(
    ToggleAnnouncement event,
    Emitter<AdminState> emit,
  ) {
    repository.toggleAnnouncement(event.announcementId);
    final result = repository.getAllAnnouncements();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      announcements,
    ) {
      emit(const AdminActionSuccess(message: 'Announcement status updated'));
      emit(AnnouncementsLoaded(announcements: announcements));
    });
  }

  void _onDeleteAnnouncement(
    DeleteAnnouncement event,
    Emitter<AdminState> emit,
  ) {
    repository.deleteAnnouncement(event.announcementId);
    final result = repository.getAllAnnouncements();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      announcements,
    ) {
      emit(const AdminActionSuccess(message: 'Announcement deleted'));
      emit(AnnouncementsLoaded(announcements: announcements));
    });
  }
}
