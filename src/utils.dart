import 'package:pub_semver/pub_semver.dart';

T? nullableMerge<T>(T? a, T? b, {required T Function(T a, T b) onEqual, }) {
  if (a == null && b == null) return null;
  if (a == null && b != null) return b;
  if (a != null && b != null) return a;

  return onEqual(a!, b!);
}

Map<K, V> mergeMaps<K, V>(
  Map<K, V> a, 
  Map<K, V> b, {
  required V Function(V a, V b) onDuplicate,
}) {
  final duplicateKeys = a.keys.toSet().intersection(b.keys.toSet());
  
  return {
    ...a,
    ...b,
  }.map((key, value) {
    if (duplicateKeys.contains(key)) {
      return MapEntry(key, onDuplicate(a[key]!, b[key]!));
    }

    return MapEntry(key, value);
  });
}