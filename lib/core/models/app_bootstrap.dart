class AppBootstrap {
  final Map<String, dynamic> user;
  final List<dynamic> workspaces;
  final Map<String, dynamic> activeWorkspace;
  final List<String> modules;
  final String defaultLanding;

  const AppBootstrap({
    required this.user,
    required this.workspaces,
    required this.activeWorkspace,
    required this.modules,
    required this.defaultLanding,
  });

  factory AppBootstrap.fromJson(Map<String, dynamic> json) {
    return AppBootstrap(
      user: Map<String, dynamic>.from(json['user'] ?? {}),

      workspaces: List<dynamic>.from(json['workspaces'] ?? []),

      activeWorkspace: Map<String, dynamic>.from(
        json['active_workspace'] ?? {},
      ),

      modules: (json['modules'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),

      defaultLanding: (json['default_landing'] ?? 'dashboard').toString(),
    );
  }

  String get displayName => (user['name'] ?? user['username'] ?? '').toString();

  String get username => (user['username'] ?? '').toString();
}
