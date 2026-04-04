String? foodImageUrlFromKey(String? imageKey) {
  if (imageKey == null || imageKey.trim().isEmpty) return null;

  final key = imageKey.trim();
  if (key.startsWith('http://') || key.startsWith('https://')) {
    return key;
  }

  return 'https://swe5006-nus-g3-public-dev-ap-southeast-1-282793424364.s3.ap-southeast-1.amazonaws.com/images/$key';
}
