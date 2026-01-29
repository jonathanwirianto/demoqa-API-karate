Feature: Create user and token helper

Scenario: create user and token
  * def common = call read('classpath:demoqa/helpers/common.feature')
  * def username = common.creds.username
  * def password = common.creds.password

  Given url baseUrl
  And path 'Account/v1/User'
  And request { userName: '#(username)', password: '#(password)' }
  When method post
  Then status 201
  * def userId = response.userID

  Given url baseUrl
  And path 'Account/v1/GenerateToken'
  And request { userName: '#(username)', password: '#(password)' }
  When method post
  Then status 200
  And match response.status == 'Success'
  And match response.token == '#string'
  * def token = response.token

  * def result = { username: '#(username)', password: '#(password)', userId: '#(userId)', token: '#(token)' }
