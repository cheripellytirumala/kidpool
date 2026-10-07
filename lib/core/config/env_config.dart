enum Environment { dev, staging, prod }

class EnvConfig {
  static Environment environment = Environment.dev;

  // The app isn't linked to a Supabase project yet: onboarding runs on
  // in-memory local data sources and OTP codes are printed to the console.
  // Set to true (and update the URL/key below) once a project is configured.
  static const bool useSupabase = false;

  // Dev only: OTP codes are generated locally and printed to the debug
  // console instead of being texted, so no SMS provider is needed.
  // Staging/prod send real SMS through Supabase phone auth.
  static bool get useDevOtp => environment == Environment.dev;

  static String get supabaseUrl {
    switch (environment) {
      case Environment.dev:
      case Environment.staging:
      case Environment.prod:
        return 'https://qktomioeszdqrgpcacvm.supabase.co';
    }
  }

  // Publishable key: safe to ship in the client. Never put a secret or
  // service_role key here.
  static String get supabasePublishableKey {
    switch (environment) {
      case Environment.dev:
      case Environment.staging:
      case Environment.prod:
        return 'sb_publishable_ZpTwf-Gf-QWtAyI2bJzIpg_b_OKxli4';
    }
  }
}
