enum Environment { dev, staging, prod }

class EnvConfig {
  static Environment environment = Environment.dev;

  static String get adminBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'https://admin.ebounti.com/api/';
      case Environment.staging:
        return 'https://admin.ebounti.com/api/'; // Example
      case Environment.prod:
        return 'https://admin.ebounti.com/api/'; // Example
    }
  }

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'https://groceriesapidev.ebounti.com/api/';
      case Environment.staging:
        return 'https://groceriesapidev.ebounti.com/api/';
      case Environment.prod:
        return 'https://groceriesapidev.ebounti.com/api/';
    }
  }
}
