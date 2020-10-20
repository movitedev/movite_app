const bool isProduction = bool.fromEnvironment('dart.vm.product');

const testConfig = {
  'url': 'http://192.168.1.15:8080'
};

const productionConfig = {
  'url': 'https://movite.herokuapp.com'
};

final environment = isProduction ? productionConfig : testConfig;