package demoqa;

import com.intuit.karate.junit5.Karate;

class DemoQaRunnerTest {

  @Karate.Test
  Karate testAll() {
    return Karate.run(
        "classpath:demoqa/account.feature",
        "classpath:demoqa/bookstore.feature"
    );
  }
}
