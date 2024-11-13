class AdPostSatge1State {
  final String title;
  final String description;
  final Map priceDetails;
  int? adId;

  AdPostSatge1State(
      {required this.title,
      required this.description,
      required this.priceDetails,
      int? adId});

  AdPostSatge1State copyWith(
      String? title, String? description, Map? priceDetails, int? adId) {
    return AdPostSatge1State(
        title: title ?? this.title,
        description: description ?? this.description,
        priceDetails: priceDetails ?? this.priceDetails,
        adId: adId ?? this.adId);
  }
}
