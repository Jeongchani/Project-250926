
/// lib/core/auth.dart

/// 🧱 Auth scaffolding for future expansion
/// - Today: anonymous only (local unique id)
/// - Future: upgrade to email/social and link with server user id

enum AuthStatus { anonymous, authenticated }

class Account {
  final String userId;      // local or server user id
  final AuthStatus status;  // anonymous or authenticated
  final String? email;      // present when authenticated (email flow)
  final String? provider;   // e.g., 'email', 'google', 'apple'

  const Account({
    required this.userId,
    required this.status,
    this.email,
    this.provider,
  });

  Account copyWith({String? userId, AuthStatus? status, String? email, String? provider}) {
    return Account(
      userId: userId ?? this.userId,
      status: status ?? this.status,
      email: email ?? this.email,
      provider: provider ?? this.provider,
    );
  }
}
