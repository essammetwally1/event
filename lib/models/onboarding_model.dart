class OnboardingModel {
  final String imageAsset;
  final String title;
  final String description;

  OnboardingModel({
    required this.imageAsset,
    required this.title,
    required this.description,
  });

  static List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      imageAsset: 'assets/onboarding/1.png',
      title: 'Personalize Your Experience',
      description:
          'Choose your preferred theme and language to get started with a comfortable, tailored experience that suits your style.',
    ),
    OnboardingModel(
      imageAsset: 'assets/onboarding/2.png',
      title: 'Find Events That Inspire You',
      description:
          "Dive into a world of events crafted to fit your unique interests. Whether you're into live music, art workshops, professional networking, or simply discovering new experiences, we have something for everyone. Our curated recommendations will help you explore, connect, and make the most of every opportunity around you.",
    ),
    OnboardingModel(
      imageAsset: 'assets/onboarding/3.png',
      title: 'Effortless Event Planning',
      description:
          "Take the hassle out of organizing events with our all-in-one planning tools. From setting up invites and managing RSVPs to scheduling reminders and coordinating details, we’ve got you covered. Plan with ease and focus on what matters – creating an unforgettable experience for you and your guests.",
    ),
    OnboardingModel(
      imageAsset: 'assets/onboarding/4.png',
      title: 'Connect with Friends & Share Moments',
      description:
          'Make every event memorable by sharing the experience with others. Our platform lets you invite friends, keep everyone in the loop, and celebrate moments together. Capture and share the excitement with your network, so you can relive the highlights and cherish the memories.',
    ),
  ];
}
