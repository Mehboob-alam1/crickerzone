/// Extracts text paragraphs from `news/detail`, applying `format` link/url
/// substitutions similar to the Cricbuzz app.
List<String> parseNewsDetailParagraphs(Map<String, dynamic> detail) {
  final urlMap = <String, String>{};
  final linkMap = <String, String>{};
  final format = detail['format'];
  if (format is List) {
    for (final f in format) {
      if (f is! Map) continue;
      final type = f['type']?.toString();
      final values = f['value'];
      if (values is! List) continue;
      for (final v in values) {
        if (v is! Map) continue;
        final id = v['id']?.toString();
        if (id == null) continue;
        final val = v['value']?.toString() ?? '';
        if (type == 'urls') {
          urlMap[id] = val;
        } else if (type == 'links') {
          linkMap[id] = val;
        }
      }
    }
  }

  final paragraphs = <String>[];
  final content = detail['content'];
  if (content is! List) return paragraphs;

  for (final block in content) {
    if (block is! Map) continue;
    if (block.containsKey('ad')) continue;
    final inner = block['content'];
    if (inner is! Map) continue;
    if (inner['contentType']?.toString() != 'text') continue;
    var text = inner['contentValue']?.toString() ?? '';
    linkMap.forEach((id, replacement) {
      text = text.replaceAll(id, replacement);
    });
    urlMap.forEach((id, replacement) {
      text = text.replaceAll(id, replacement);
    });
    if (text.trim().isNotEmpty) {
      paragraphs.add(text.trim());
    }
  }
  return paragraphs;
}

String newsCoverImageUrl(Map<String, dynamic> json) {
  final cover = json['coverImage'];
  if (cover is Map && cover['id'] != null) {
    return 'https://static.cricbuzz.com/a/img/v1/i1/c${cover['id']}/i.jpg';
  }
  if (json['imageId'] != null) {
    return 'https://static.cricbuzz.com/a/img/v1/i1/c${json['imageId']}/i.jpg';
  }
  return '';
}
