class ServiceConfig {
  static const mode = String.fromEnvironment(
    'MILO_SERVICES',
    defaultValue: 'playtest',
  );
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const monthly = String.fromEnvironment('MILO_MONTHLY_PRODUCT');
  static const annual = String.fromEnvironment('MILO_ANNUAL_PRODUCT');
  static bool get live => mode == 'live';
  static bool get configured => url.startsWith('https://') && key.isNotEmpty;
  static Set<String> get products => [monthly, annual].where((id) => id.isNotEmpty).toSet();
}
