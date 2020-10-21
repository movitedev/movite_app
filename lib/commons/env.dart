const bool isProduction = bool.fromEnvironment('dart.vm.product');

const testConfig = {
  'url': 'http://192.168.1.15:8080',
  'kGoogleApiKey': String.fromEnvironment("kGoogleApiKey")
};

const productionConfig = {
  'url': 'https://movite.herokuapp.com',
  'kGoogleApiKey': String.fromEnvironment("kGoogleApiKey")
};

final environment = isProduction ? productionConfig : testConfig;