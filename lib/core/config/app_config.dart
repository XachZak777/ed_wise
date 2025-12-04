class AppConfig {
  // Authentication: Always use Firebase (no mock auth)
  static const bool useMockAuth = false;
  
  // Study Plans & Forum: Use mock data for presentation/demo
  static const bool useMockStudyPlans = true;
  static const bool useMockForum = true;
  
  // Other features: Set to true to use mock data instead of Firebase
  static const bool useMockData = false;
  
  // Mock data delay simulation (in milliseconds)
  static const int mockDataDelay = 500;
}

