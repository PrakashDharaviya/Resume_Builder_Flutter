import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../auth/domain/entities/user.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;

  // Keep a cache for user search
  List<User> cachedUsers = [];

  AdminBloc({required this.repository}) : super(const AdminInitial()) {
    // Dashboard
    on<LoadAdminDashboard>(onLoadDashboard);

    // Templates
    on<LoadTemplates>(onLoadTemplates);
    on<AddTemplate>(onAddTemplate);
    on<UpdateTemplate>(onUpdateTemplate);
    on<DeleteTemplate>(onDeleteTemplate);

    // Users
    on<LoadUsers>(onLoadUsers);
    on<ToggleBlockUser>(onToggleBlockUser);
    on<TogglePremiumUser>(onTogglePremiumUser);
    on<SearchUsers>(onSearchUsers);

    // ATS Config
    on<LoadATSConfig>(onLoadATSConfig);
    on<UpdateATSConfig>(onUpdateATSConfig);

    // Announcements
    on<LoadAnnouncements>(onLoadAnnouncements);
    on<AddAnnouncement>(onAddAnnouncement);
    on<ToggleAnnouncement>(onToggleAnnouncement);
    on<DeleteAnnouncement>(onDeleteAnnouncement);
  }

  // ========== Dashboard ==========
  void onLoadDashboard(LoadAdminDashboard event, Emitter<AdminState> emit) {
    emit(const AdminLoading());
    final result = repository.getAdminStats();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (stats) => emit(AdminDashboardLoaded(stats: stats)),
    );
  }

  // ========== Templates ==========
  void onLoadTemplates(LoadTemplates event, Emitter<AdminState> emit) {
    emit(const AdminLoading());
    final result = repository.getAllTemplates();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (templates) => emit(TemplatesLoaded(templates: templates)),
    );
  }

  void onAddTemplate(AddTemplate event, Emitter<AdminState> emit) {
    repository.addTemplate(event.template);
    final result = repository.getAllTemplates();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      templates,
    ) {
      emit(const AdminActionSuccess(message: 'Template added successfully'));
      emit(TemplatesLoaded(templates: templates));
    });
  }

  void onUpdateTemplate(UpdateTemplate event, Emitter<AdminState> emit) {
    repository.updateTemplate(event.template);
    final result = repository.getAllTemplates();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      templates,
    ) {
      emit(const AdminActionSuccess(message: 'Template updated successfully'));
      emit(TemplatesLoaded(templates: templates));
    });
  }

  void onDeleteTemplate(DeleteTemplate event, Emitter<AdminState> emit) {
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
  void onLoadUsers(LoadUsers event, Emitter<AdminState> emit) {
    emit(const AdminLoading());
    final result = repository.getAllUsers();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      users,
    ) {
      cachedUsers = users;
      emit(UsersLoaded(users: users));
    });
  }

  void onToggleBlockUser(ToggleBlockUser event, Emitter<AdminState> emit) {
    repository.toggleBlockUser(event.uid);
    final result = repository.getAllUsers();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      users,
    ) {
      cachedUsers = users;
      emit(const AdminActionSuccess(message: 'User status updated'));
      emit(UsersLoaded(users: users));
    });
  }

  void onTogglePremiumUser(TogglePremiumUser event, Emitter<AdminState> emit) {
    repository.togglePremiumUser(event.uid);
    final result = repository.getAllUsers();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      users,
    ) {
      cachedUsers = users;
      emit(const AdminActionSuccess(message: 'User premium status updated'));
      emit(UsersLoaded(users: users));
    });
  }

  void onSearchUsers(SearchUsers event, Emitter<AdminState> emit) {
    if (event.query.isEmpty) {
      emit(UsersLoaded(users: cachedUsers));
      return;
    }

    final query = event.query.toLowerCase();
    final filtered = cachedUsers
        .where(
          (u) =>
              u.displayName.toLowerCase().contains(query) ||
              u.email.toLowerCase().contains(query),
        )
        .toList();

    emit(UsersLoaded(users: cachedUsers, filteredUsers: filtered));
  }

  // ========== ATS Config ==========
  void onLoadATSConfig(LoadATSConfig event, Emitter<AdminState> emit) {
    emit(const AdminLoading());
    final result = repository.getATSConfig();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (config) => emit(ATSConfigLoaded(config: config)),
    );
  }

  void onUpdateATSConfig(UpdateATSConfig event, Emitter<AdminState> emit) {
    final result = repository.updateATSConfig(event.config);
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      config,
    ) {
      emit(const AdminActionSuccess(message: 'ATS configuration saved'));
      emit(ATSConfigLoaded(config: config));
    });
  }

  // ========== Announcements ==========
  void onLoadAnnouncements(LoadAnnouncements event, Emitter<AdminState> emit) {
    emit(const AdminLoading());
    final result = repository.getAllAnnouncements();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (announcements) =>
          emit(AnnouncementsLoaded(announcements: announcements)),
    );
  }

  void onAddAnnouncement(AddAnnouncement event, Emitter<AdminState> emit) {
    repository.addAnnouncement(event.announcement);
    final result = repository.getAllAnnouncements();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      announcements,
    ) {
      emit(const AdminActionSuccess(message: 'Announcement created'));
      emit(AnnouncementsLoaded(announcements: announcements));
    });
  }

  void onToggleAnnouncement(
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

  void onDeleteAnnouncement(
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
