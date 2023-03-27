const bool isProduction = bool.fromEnvironment('dart.vm.product');

const testConfig = {
  'url': 'http://192.168.1.11:8080',
  'mapBoxApiKey': String.fromEnvironment("mapBoxApiKey")
};

const productionConfig = {
  'url': 'https://movite.onrender.com',
  'mapBoxApiKey': String.fromEnvironment("mapBoxApiKey")
};

final environment = isProduction ? productionConfig : testConfig;