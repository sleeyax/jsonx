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
  final List<int> text;
  final List<Node> children;
  Node(this.type, {this.text = const [], this.children = const []});

  @override
  String toString() {
    if (text?.isNotEmpty == true)
      return '"' + new String.fromCharCodes(text) + '" => $type';
    else if (children?.isNotEmpty == true)
      return '"' +
          children.map((c) => c.toString()).toList().toString() +
          '" => $type';
    return type.toString();
  }
}
