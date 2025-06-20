class DirectoryItem {
  final String name;
  final bool isDir;
  final int action;
  final List<DirectoryItem>? children;

  DirectoryItem({
    required this.name,
    required this.isDir,
    required this.action,
    this.children,
  });

  factory DirectoryItem.fromJson(Map<String, dynamic> json) {
    return DirectoryItem(
      name: json['name'],
      isDir: json['isDir'],
      action: json['action'],
      children: json['children'] != null
          ? (json['children'] as List)
              .map((child) => DirectoryItem.fromJson(child))
              .toList()
          : null,
    );
  }
}
