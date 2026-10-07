enum Environment { dev, staging, prod }

class EnvConfig {
  static Environment environment = Environment.dev;

  // When false, onboarding runs on in-memory local data sources instead of
  // the Supabase project below.
  static const bool useSupabase = true;

  // Dev only: OTP codes are generated locally and printed to the debug
  // console instead of being texted, so no SMS provider is needed.
  // Staging/prod send real SMS through Supabase phone auth.
  static bool get useDevOtp => environment == Environment.dev;

  static String get supabaseUrl {
    switch (environment) {
      case Environment.dev:
      case Environment.staging:
      case Environment.prod:
        return 'https://cojraqxramlirnepncrd.supabase.co';
    }
  }

  // Publishable key: safe to ship in the client. Never put a secret or
  // service_role key here.
  static String get supabasePublishableKey {
    switch (environment) {
      case Environment.dev:
      case Environment.staging:
      case Environment.prod:
        return 'sb_publishable_fNCY2oyYmmvkCYKO8ZbAIg_7UJIhC0a';
    }
  }
}
