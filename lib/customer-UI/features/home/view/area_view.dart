class AreaNode {
  final int id;
  final String name;
  final String type; // country / governorate / city
  final List<AreaNode> children;

  AreaNode({
    required this.id,
    required this.name,
    required this.type,
    required this.children,
  });

  factory AreaNode.fromJson(Map<String, dynamic> json) {
    final childrenJson = (json['children'] as List?) ?? [];
    return AreaNode(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      children: childrenJson
          .whereType<Map<String, dynamic>>()
          .map((c) => AreaNode.fromJson(c))
          .toList(),
    );
  }
}
