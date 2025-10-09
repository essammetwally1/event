class UserModel {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  final List<String> favouriteEventsIds;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    required this.favouriteEventsIds,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      imageUrl: json['imageUrl'] as String?,
      favouriteEventsIds:
          (json['favouriteEventsIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'imageUrl': imageUrl,
    'favouriteEventsIds': favouriteEventsIds,
  };

  /// This makes updates much easier without rewriting everything manually.
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    List<String>? favouriteEventsIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      favouriteEventsIds: favouriteEventsIds ?? this.favouriteEventsIds,
    );
  }
}
