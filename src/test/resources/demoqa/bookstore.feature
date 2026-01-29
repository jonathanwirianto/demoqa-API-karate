Feature: DemoQA BookStore API

Background:
  * url baseUrl
  * def auth = callonce read('classpath:demoqa/helpers/auth-create-user.feature')
  * def username = auth.result.username
  * def userId = auth.result.userId
  * def token = auth.result.token

  # Get a valid ISBN to use
  Given path 'BookStore/v1/Books'
  And retry until responseStatus == 200
  When method get
  Then status 200
  And match response.books == '#[]'
  * def isbn = response.books[0].isbn

Scenario: Get Books list -> 200 and contains books
  Given path 'BookStore/v1/Books'
  And retry until responseStatus == 200
  When method get
  Then status 200
  And match response.books == '#[]'
  And match response.books[0] contains { isbn: '#string', title: '#string', author: '#string' }

Scenario: Get single Book by ISBN -> 200 and matches ISBN
  Given path 'BookStore/v1/Book'
  And param ISBN = isbn
  And retry until responseStatus == 200
  When method get
  Then status 200
  And match response contains { isbn: '#(isbn)', title: '#string', author: '#string', publisher: '#string' }

Scenario: Add a book to user then verify with Get User -> 201 and book exist
  Given path 'BookStore/v1/Books'
  And header Authorization = 'Bearer ' + token
  And request
    """
    { userId: '#(userId)', collectionOfIsbns: [ { isbn: '#(isbn)' } ] }
    """
  And retry until responseStatus == 201
  When method post
  Then status 201

  Given path 'Account/v1/User', userId
  And header Authorization = 'Bearer ' + token
  And retry until responseStatus == 200
  When method get
  Then status 200
  And match response.username == username
  And match response.books contains deep { isbn: '#(isbn)' }

Scenario: Delete all books for user -> 204 book deleted
  Given path 'BookStore/v1/Books'
  And header Authorization = 'Bearer ' + token
  And param UserId = userId
  And retry until responseStatus == 204
  When method delete
  Then status 204

  Given path 'Account/v1/User', userId
  And header Authorization = 'Bearer ' + token
  And retry until responseStatus == 200
  When method get
  Then status 200
  And match response.books == '#[]'

Scenario: Get single Book with invalid ISBN -> 400
  Given path 'BookStore/v1/Book'
  And param ISBN = '0000000000000'
  When method get
  Then status 400
  And match response.message == '#string'

Scenario: Add book to user without token -> 401
  Given path 'BookStore/v1/Books'
  And request
    """
    { userId: '#(userId)', collectionOfIsbns: [ { isbn: '#(isbn)' } ] }
    """
  When method post
  Then status 401

Scenario: Add book to user with invalid token -> 401
  Given path 'BookStore/v1/Books'
  And header Authorization = 'Bearer invalid.token.value'
  And request
    """
    { userId: '#(userId)', collectionOfIsbns: [ { isbn: '#(isbn)' } ] }
    """
  When method post
  Then status 401

Scenario: Add same book twice -> Idempotency validation
  Given path 'BookStore/v1/Books'
  And header Authorization = 'Bearer ' + token
  And request
    """
    { userId: '#(userId)', collectionOfIsbns: [ { isbn: '#(isbn)' } ] }
    """
  And retry until responseStatus == 201
  When method post
  Then status 201

  # Add second time
  Given path 'BookStore/v1/Books'
  And header Authorization = 'Bearer ' + token
  And request
    """
    { userId: '#(userId)', collectionOfIsbns: [ { isbn: '#(isbn)' } ] }
    """
  When method post
  Then status 400
  And match response.message contains "ISBN already present"

  # Verify user still has the book
  Given path 'Account/v1/User', userId
  And header Authorization = 'Bearer ' + token
  And retry until responseStatus == 200
  When method get
  Then status 200
  And match response.books contains deep { isbn: '#(isbn)' }

