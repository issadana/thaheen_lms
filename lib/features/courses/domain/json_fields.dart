/// Small helpers that turn loosely typed JSON into clear [FormatException]s,
/// so a bad catalog fails with "lesson l3: durationSec ..." instead of a
/// `TypeError` deep inside a widget.
T readField<T>(Map<String, dynamic> json, String key, String where) {
  final value = json[key];
  if (value is T) return value;
  throw FormatException('$where: "$key" is missing or is not a $T');
}

String readId(Map<String, dynamic> json, String where) {
  final id = readField<String>(json, 'id', where);
  if (id.trim().isEmpty) throw FormatException('$where: "id" is empty');
  return id;
}

List<Map<String, dynamic>> readObjectList(
  Map<String, dynamic> json,
  String key,
  String where,
) {
  final list = readField<List<dynamic>>(json, key, where);
  return [
    for (final item in list)
      if (item is Map<String, dynamic>)
        item
      else
        throw FormatException('$where: every item in "$key" must be an object'),
  ];
}

void ensureUniqueIds(Iterable<String> ids, String where) {
  final seen = <String>{};
  for (final id in ids) {
    if (!seen.add(id)) throw FormatException('$where: duplicate id "$id"');
  }
}
