enum NodeType {
  ARRAY,
  OBJECT,
  KEY_VALUE_PAIR,
  STRING,
  NUMBER,
  TRUE,
  FALSE,
  NULL
}

class Node {
  final NodeType type;
  final String text;
  final List<Node> children;
  Node(this.type, {this.text, this.children = const []});

  @override
  String toString() {
    if (text != null)
      return '"$text" => $type';
    else if (children?.isNotEmpty == true)
      return '"' +
          children.map((c) => c.toString()).toList().toString() +
          '" => $type';
    return type.toString();
  }
}
