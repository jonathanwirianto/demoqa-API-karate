Feature: Common helpers

Scenario: generate credentials
  * def rand = java.lang.System.currentTimeMillis()
  * def username = 'qa_user_' + rand
  * def password = 'testQa123!'
  * def creds = { username: '#(username)', password: '#(password)' }
