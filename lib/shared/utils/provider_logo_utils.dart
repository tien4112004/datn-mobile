class ProviderLogoUtils {
  static String getLogoPath(String provider) {
    switch (provider.toLowerCase()) {
      case 'openai':
        return 'assets/images/providers/openai.png';
      case 'google':
        return 'assets/images/providers/google.png';
      case 'deepseek':
        return 'assets/images/providers/deepseek.png';
      case 'localai':
        return 'assets/images/providers/localai.png';
      case 'openrouter':
        return 'assets/images/providers/openrouter.png';
      default:
        return 'assets/images/providers/openrouter.png';
    }
  }
}
