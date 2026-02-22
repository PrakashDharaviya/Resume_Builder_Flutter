// Mock Firebase Service - UI Only
// No actual Firebase implementation

class FirebaseService {
  // Mock sign in with email
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Admin login
    if (email == 'admin@resumeiq.com') {
      return {
        'uid': 'admin_001',
        'email': email,
        'displayName': 'Admin User',
        'role': 'admin',
        'isBlocked': false,
        'isPremium': true,
      };
    }

    // Blocked user demo
    if (email == 'blocked@test.com') {
      return {
        'uid': 'blocked_001',
        'email': email,
        'displayName': 'Blocked User',
        'role': 'user',
        'isBlocked': true,
        'isPremium': false,
      };
    }

    // Regular user login
    return {
      'uid': 'mock_uid_123',
      'email': email,
      'displayName': 'John Doe',
      'role': 'user',
      'isBlocked': false,
      'isPremium': false,
    };
  }

  // Mock sign up with email
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful registration
    return {
      'uid': 'mock_uid_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'displayName': displayName,
      'role': 'user',
      'isBlocked': false,
      'isPremium': false,
    };
  }

  // Mock sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock successful Google login
    return {
      'uid': 'mock_google_uid_123',
      'email': 'user@gmail.com',
      'displayName': 'Google User',
      'photoURL': 'https://via.placeholder.com/150',
      'role': 'user',
      'isBlocked': false,
      'isPremium': false,
    };
  }

  // Mock sign out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock get current user
  Map<String, dynamic>? getCurrentUser() {
    // Return mock user or null
    return {
      'uid': 'mock_uid_123',
      'email': 'user@example.com',
      'displayName': 'John Doe',
      'role': 'user',
      'isBlocked': false,
      'isPremium': false,
    };
  }

  // Mock password reset
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  // Check if user is signed in
  bool isSignedIn() {
    return true; // Mock always signed in for UI testing
  }
}
