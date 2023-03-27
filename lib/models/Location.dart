class Location {
  String? type;
  List? coordinates;

  Location(String type, List? coordinates) {
    this.type = type;
    this.coordinates = coordinates;
  }

  Location.fromJson(Map json)
      : type = json['type'],
        coordinates = json['coordinates'];

  Map toJson() {
    return {'type': type, 'coordinates': coordinates};
  }
}
