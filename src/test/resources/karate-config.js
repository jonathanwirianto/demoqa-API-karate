function fn() {
  var env = karate.env || 'dev';

  var config = {
    baseUrl: 'https://demoqa.com'
  };

  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 10000);

  karate.configure('retry', { count: 3, interval: 1000 });

  return config;
}
