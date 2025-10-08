class UserModel {
  final String id;
  final String name;
  final String email;
  String? imageUrl;
  List<String> favouriteEventsIds;
  // List<dynamic> favouriteEventsIds;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    required this.favouriteEventsIds,
  });
  UserModel.fromJson(Map<String, dynamic> json)
    : this(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        imageUrl: json['imageUrl'],
        favouriteEventsIds: (json['favouriteEventsIds'] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'imageUrl': imageUrl,
    'favouriteEventsIds': favouriteEventsIds,
  };
}
