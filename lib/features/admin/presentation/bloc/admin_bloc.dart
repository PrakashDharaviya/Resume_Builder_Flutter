import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumebuilder/features/admin/domain/entities/app_notification.dart';
import 'package:resumebuilder/features/admin/domain/repositories/admin_repository.dart';
import 'package:resumebuilder/features/admin/presentation/bloc/admin_event.dart';
import 'package:resumebuilder/features/admin/presentation/bloc/admin_state.dart';
import 'package:resumebuilder/features/auth/domain/entities/user.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;

  // Keep a cache for user search
  List<User> cachedUsers = [];

  AdminBloc({required this.repository}) : super(const AdminInitial()) {
    // Dashboard
    on<LoadAdminDashboard>(onLoadDashboard);

    // Templates
    on<LoadTemplates>(onLoadTemplates);
    on<FetchTemplates>(onFetchTemplates);
    on<AddTemplate>(onAddTemplate);
    on<UpdateTemplate>(onUpdateTemplate);
    on<DeleteTemplate>(onDeleteTemplate);

    // Users
    on<LoadUsers>(onLoadUsers);
    on<FetchUsers>(onFetchUsers);
    on<ToggleBlockUser>(onToggleBlockUser);
    on<TogglePremiumUser>(onTogglePremiumUser);
    on<DeleteUser>(onDeleteUser);
    on<SearchUsers>(onSearchUsers);

    // ATS Config
    on<LoadATSConfig>(onLoadATSConfig);
    on<UpdateATSConfig>(onUpdateATSConfig);

    // Announcements
    on<LoadAnnouncements>(onLoadAnnouncements);
    on<AddAnnouncement>(onAddAnnouncement);
    on<UpdateAnnouncement>(onUpdateAnnouncement);
    on<ToggleAnnouncement>(onToggleAnnouncement);
    on<DeleteAnnouncement>(onDeleteAnnouncement);

    // Notifications
    on<LoadNotifications>(onLoadNotifications);
    on<SendBroadcastNotification>(onSendBroadcastNotification);
    on<DeleteNotification>(onDeleteNotification);
  }

  // ========== Dashboard ==========
  Future<void> onLoadDashboard(
    LoadAdminDashboard event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    final result = await repository.getAdminStats();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (stats) => emit(AdminDashboardLoaded(stats: stats)),
    );
  }

  // ========== Templates ==========
  Future<void> onLoadTemplates(
    LoadTemplates event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    final result = await repository.getAllTemplates();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (templates) => emit(TemplatesLoaded(templates: templates)),
    );
  }

  Future<void> onFetchTemplates(
    FetchTemplates event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    final result = await repository.getAllTemplates();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (templates) => emit(AdminTemplatesLoaded(templates: templates)),
    );
  }

  Future<void> onAddTemplate(
    AddTemplate event,
    Emitter<AdminState> emit,
  ) async {
    await repository.addTemplate(event.template);
    final result = await repository.getAllTemplates();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      templates,
    ) {
      emit(const AdminActionSuccess(message: 'Template added successfully'));
      emit(TemplatesLoaded(templates: templates));
    });
  }

  Future<void> onUpdateTemplate(
    UpdateTemplate event,
    Emitter<AdminState> emit,
  ) async {
    await repository.updateTemplate(event.template);
    final result = await repository.getAllTemplates();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      templates,
    ) {
      emit(const AdminActionSuccess(message: 'Template updated successfully'));
      emit(TemplatesLoaded(templates: templates));
    });
  }

  Future<void> onDeleteTemplate(
    DeleteTemplate event,
    Emitter<AdminState> emit,
  ) async {
    await repository.deleteTemplate(event.templateId);
    final result = await repository.getAllTemplates();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      templates,
    ) {
      emit(const AdminActionSuccess(message: 'Template deleted'));
      emit(TemplatesLoaded(templates: templates));
    });
  }

  // ========== Users ==========
  Future<void> onLoadUsers(LoadUsers event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await repository.getAllUsers();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      users,
    ) {
      cachedUsers = users;
      emit(UsersLoaded(users: users));
    });
  }

  Future<void> onFetchUsers(FetchUsers event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await repository.getAllUsers();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      users,
    ) {
      cachedUsers = users;
      emit(AdminUsersLoaded(users: users));
    });
  }

  Future<void> onToggleBlockUser(
    ToggleBlockUser event,
    Emitter<AdminState> emit,
  ) async {
    await repository.toggleBlockUser(event.uid);
    final result = await repository.getAllUsers();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      users,
    ) {
      cachedUsers = users;
      emit(const AdminActionSuccess(message: 'User status updated'));
      emit(UsersLoaded(users: users));
    });
  }

  Future<void> onTogglePremiumUser(
    TogglePremiumUser event,
    Emitter<AdminState> emit,
  ) async {
    await repository.togglePremiumUser(event.uid);
    final result = await repository.getAllUsers();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      users,
    ) {
      cachedUsers = users;
      emit(const AdminActionSuccess(message: 'User premium status updated'));
      emit(UsersLoaded(users: users));
    });
  }

  Future<void> onDeleteUser(DeleteUser event, Emitter<AdminState> emit) async {
    await repository.deleteUser(event.uid);
    final result = await repository.getAllUsers();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      users,
    ) {
      cachedUsers = users;
      emit(const AdminActionSuccess(message: 'User deleted successfully'));
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
  Future<void> onLoadATSConfig(
    LoadATSConfig event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    final result = await repository.getATSConfig();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (config) => emit(ATSConfigLoaded(config: config)),
    );
  }

  Future<void> onUpdateATSConfig(
    UpdateATSConfig event,
    Emitter<AdminState> emit,
  ) async {
    final result = await repository.updateATSConfig(event.config);
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      config,
    ) {
      emit(const AdminActionSuccess(message: 'ATS configuration saved'));
      emit(ATSConfigLoaded(config: config));
    });
  }

  // ========== Announcements ==========
  Future<void> onLoadAnnouncements(
    LoadAnnouncements event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    final result = await repository.getAllAnnouncements();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (announcements) =>
          emit(AnnouncementsLoaded(announcements: announcements)),
    );
  }

  Future<void> onAddAnnouncement(
    AddAnnouncement event,
    Emitter<AdminState> emit,
  ) async {
    await repository.addAnnouncement(event.announcement);
    final result = await repository.getAllAnnouncements();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      announcements,
    ) {
      emit(const AdminActionSuccess(message: 'Announcement created'));
      emit(AnnouncementsLoaded(announcements: announcements));
    });
  }

  Future<void> onUpdateAnnouncement(
    UpdateAnnouncement event,
    Emitter<AdminState> emit,
  ) async {
    await repository.updateAnnouncement(event.announcement);
    final result = await repository.getAllAnnouncements();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      announcements,
    ) {
      emit(const AdminActionSuccess(message: 'Announcement updated'));
      emit(AnnouncementsLoaded(announcements: announcements));
    });
  }

  Future<void> onToggleAnnouncement(
    ToggleAnnouncement event,
    Emitter<AdminState> emit,
  ) async {
    await repository.toggleAnnouncement(event.announcementId);
    final result = await repository.getAllAnnouncements();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      announcements,
    ) {
      emit(const AdminActionSuccess(message: 'Announcement status updated'));
      emit(AnnouncementsLoaded(announcements: announcements));
    });
  }

  Future<void> onDeleteAnnouncement(
    DeleteAnnouncement event,
    Emitter<AdminState> emit,
  ) async {
    await repository.deleteAnnouncement(event.announcementId);
    final result = await repository.getAllAnnouncements();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      announcements,
    ) {
      emit(const AdminActionSuccess(message: 'Announcement deleted'));
      emit(AnnouncementsLoaded(announcements: announcements));
    });
  }

  // ========== Notifications ==========
  Future<void> onLoadNotifications(
    LoadNotifications event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    final result = await repository.getAllNotifications();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (notifications) =>
          emit(NotificationsLoaded(notifications: notifications)),
    );
  }

  Future<void> onSendBroadcastNotification(
    SendBroadcastNotification event,
    Emitter<AdminState> emit,
  ) async {
    final notification = AppNotification(
      id: '',
      title: event.title,
      message: event.body,
      createdAt: DateTime.now(),
      type: 'broadcast',
    );
    final result = await repository.addNotification(notification);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => emit(
        const AdminActionSuccess(message: 'Notification sent successfully'),
      ),
    );
  }

  Future<void> onDeleteNotification(
    DeleteNotification event,
    Emitter<AdminState> emit,
  ) async {
    await repository.deleteNotification(event.notificationId);
    final result = await repository.getAllNotifications();
    result.fold((failure) => emit(AdminError(message: failure.message)), (
      notifications,
    ) {
      emit(const AdminActionSuccess(message: 'Notification deleted'));
      emit(NotificationsLoaded(notifications: notifications));
    });
  }
}
