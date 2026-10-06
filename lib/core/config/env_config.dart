enum Environment { dev, staging, prod }

class EnvConfig {
  static Environment environment = Environment.dev;

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
