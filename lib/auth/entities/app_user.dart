class AppUser {
  final String uid;
  final String email;
  /*final String firstName;
  final String middleInitial;
  final String lastName;*/

  AppUser({
    required this.uid,
    required this.email,
    /*required this.firstName,
    required this.middleInitial,
    required this.lastName*/
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      /*'firstName': firstName,
      'middleInitial': middleInitial,
      'lastName': lastName,*/
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'],
      email: jsonUser['email'],
      /*firstName: jsonUser['firstName'],
      middleInitial: jsonUser['middleInitial'],
      lastName: jsonUser['lastName']*/
    );
  }
}