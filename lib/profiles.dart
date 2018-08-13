final List<Profile> demoProfiles = [
  Profile(
    photos: [
      'assets/photo_1.jpg',
      'assets/photo_2.jpg',
      'assets/photo_3.jpg',
      'assets/photo_4.jpg',
    ],
    name: 'Someone Special',
    bio: 'This is the person you want!',
  ),
  Profile(
    photos: [
      'assets/photo_4.jpg',
      'assets/photo_3.jpg',
      'assets/photo_2.jpg',
      'assets/photo_1.jpg',
    ],
    name: 'Gross Person',
    bio: 'You better swipe left...',
  ),
];

class Profile {
  final List<String> photos;
  final String name;
  final String bio;

  Profile({
    this.photos,
    this.name,
    this.bio,
  });
}
