enum Environment { dev, staging, prod }

class EnvConfig {
  static Environment environment = Environment.dev;

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

  // Google Places (New) key for the pickup address search. Supplied at build
  // time so it stays out of source control:
  //   flutter run --dart-define=GOOGLE_PLACES_API_KEY=AIza...
  // Restrict it to the Places API (New) in Google Cloud. Empty → the search
  // screen says it isn't set up and the typed address is used as-is.
  static const String googlePlacesApiKey =
      String.fromEnvironment('GOOGLE_PLACES_API_KEY');
}
