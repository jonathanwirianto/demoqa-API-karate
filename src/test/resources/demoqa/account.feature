Feature: DemoQA Account API tests

Background:
  * url baseUrl

Scenario: Create user (valid) -> 201 and userID returned
  * def common = call read('classpath:demoqa/helpers/common.feature')
  * def username = common.creds.username
  * def password = common.creds.password

  Given path 'Account/v1/User'
  And request { userName: '#(username)', password: '#(password)' }
  When method post
  Then status 201
  And match response == { userID: '#string', username: '#(username)', books: [] }

  * def userId = response.userID
  Given path 'Account/v1/GenerateToken'
  And request { userName: '#(username)', password: '#(password)' }
  When method post
  Then status 200
  And match response.status == 'Success'
  * def token = response.token

Scenario: Create user (duplicate username) -> 406
  * def common = call read('classpath:demoqa/helpers/common.feature')
  * def username = common.creds.username
  * def password = common.creds.password

  # create first time
  Given path 'Account/v1/User'
  And request { userName: '#(username)', password: '#(password)' }
  When method post
  Then status 201
  * def userId = response.userID

  # create second time with same username should fail
  Given path 'Account/v1/User'
  And request { userName: '#(username)', password: '#(password)' }
  When method post
  Then status 406
  And match response.message == 'User exists!'

Scenario: GenerateToken (invalid password) -> Failed (or no token)
  * def auth = call read('classpath:demoqa/helpers/auth-create-user.feature')
  * def username = auth.result.username
  * def userId = auth.result.userId
  * def token = auth.result.token

  Given path 'Account/v1/GenerateToken'
  And request { userName: '#(username)', password: 'WrongPass@123' }
  When method post
  Then status 200
  And match response.status == 'Failed'
  And match response.result == 'User authorization failed.'

Scenario: Authorized (valid credentials) -> true
  * def auth = call read('classpath:demoqa/helpers/auth-create-user.feature')
  * def username = auth.result.username
  * def password = auth.result.password
  * def userId = auth.result.userId
  * def token = auth.result.token

  Given path 'Account/v1/Authorized'
  And request { userName: '#(username)', password: '#(password)' }
  When method post
  Then status 200
  And match response == 'true'

Scenario: Authorized (invalid credentials) -> false
  * def auth = call read('classpath:demoqa/helpers/auth-create-user.feature')
  * def username = auth.result.username
  * def userId = auth.result.userId
  * def token = auth.result.token

  Given path 'Account/v1/Authorized'
  And request { userName: '#(username)', password: 'WrongPass@123' }
  When method post
  Then status 404
  And match response.message == 'User not found!'

Scenario: Get User (authorized) -> 200 and username matches
  * def auth = call read('classpath:demoqa/helpers/auth-create-user.feature')
  * def username = auth.result.username
  * def userId = auth.result.userId
  * def token = auth.result.token

  Given path 'Account/v1/User', userId
  And header Authorization = 'Bearer ' + token
  When method get
  Then status 200
  And match response.username == username
  And match response.userId == userId
  And match response.books == '#[]'

Scenario: Get User (missing token) -> 401
  * def auth = call read('classpath:demoqa/helpers/auth-create-user.feature')
  * def userId = auth.result.userId
  * def token = auth.result.token

  Given path 'Account/v1/User', userId
  When method get
  Then status 401

Scenario: Get User (invalid userId) -> 401
  * def auth = call read('classpath:demoqa/helpers/auth-create-user.feature')
  * def token = auth.result.token
  * def userId = auth.result.userId

  * def fakeUserId = '00000000-0000-0000-0000-000000000000'

  Given path 'Account/v1/User', fakeUserId
  And header Authorization = 'Bearer ' + token
  When method get
  Then status 401

Scenario: Delete User -> 401
  * def auth = call read('classpath:demoqa/helpers/auth-create-user.feature')
  * def userId = auth.result.userId
  * def token = auth.result.token

  Given path 'Account/v1/User', userId
  And header Authorization = 'Bearer ' + token
  When method delete
  Then status 204

Scenario: Create user (weak password) -> 400 and message returned
  * def common = call read('classpath:demoqa/helpers/common.feature')
  * def username = common.creds.username
  * def weakPassword = '12345'

  Given path 'Account/v1/User'
  And request { userName: '#(username)', password: '#(weakPassword)' }
  When method post
  Then status 400
  And match response.message == 'Passwords must have at least one non alphanumeric character, one digit (\'0\'-\'9\'), one uppercase (\'A\'-\'Z\'), one lowercase (\'a\'-\'z\'), one special character and Password must be eight characters or longer.'
