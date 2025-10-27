class SpinConfigResponse {
  int? id;
  String? name;
  int? itemId;
  double? weight;
  String? itemType;
  String? itemContent;
  String? image;
  SpinConfigResponse(
      {this.id,
      this.name,
      this.itemId,
      this.weight,
      this.itemType,
      this.itemContent,
      this.image});

  SpinConfigResponse.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    itemId = json['ItemId'];
    weight = json['Weight'];
    itemType = json['ItemType'];
    itemContent = json['ItemContent'];
    image = json['Image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Name'] = name;
    data['ItemId'] = itemId;
    data['Weight'] = weight;
    data['ItemType'] = itemType;
    data['ItemContent'] = itemContent;
    data["Image"] = image;

    return data;
  }
}
