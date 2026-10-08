/// Only what exists in the Supabase project. Features without a table here
/// (schools, kids, circles, rides) run on in-memory data sources.
class ApiConstants {
  // Edge functions
  static const String requestOtpFunction = 'request-otp';
  static const String verifyOtpFunction = 'verify-otp';

  // RPCs
  static const String checkAppVersionRpc = 'check_app_version';

  // Tables
  static const String profilesTable = 'profiles';
}
