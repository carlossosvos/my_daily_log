import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.name,
    this.pictureUrl,
    this.isEmailVerified = false,
  });

  final String id;
  final String email;
  final String? name;
  final String? pictureUrl;
  final bool isEmailVerified;

  @override
  List<Object?> get props => [id, email, name, pictureUrl, isEmailVerified];

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? pictureUrl,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }
}
