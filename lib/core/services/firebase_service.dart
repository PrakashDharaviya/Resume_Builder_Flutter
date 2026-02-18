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

    // Mock successful login
    return {'uid': 'mock_uid_123', 'email': email, 'displayName': 'John Doe'};
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
