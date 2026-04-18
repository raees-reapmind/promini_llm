class ApiConfig {
  // Base URL
  static const String baseUrl = "https://generativelanguage.googleapis.com";

  // API Version
  static const String version = "v1beta";

  // Recommended Free Tier Models for 2026:
  // 1. "gemini-3-flash-preview" - Latest reasoning & 66K output limit
  // 2. "gemini-2.5-flash" - Current stable free-tier workhorse
  static const String model = "gemini-2.5-flash";

  // Endpoint Action
  static const String generateContent = "generateContent";

  // Full URL (computed)
  static String get generateContentUrl =>
      "$baseUrl/$version/models/$model:$generateContent";
}