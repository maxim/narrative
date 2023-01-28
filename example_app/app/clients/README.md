# Client objects

Every integration with APIs must consist of 2 client libraries.

1. **External client**: The generic client library for the API. Usually it's provided by the API company itself. (E.g. AWS SNS gem for AWS SNS)
2. **Internal client**: The API client that we must write for using in our app.

## External client

If external client already exists, we install it as a gem. If it doesn't, we write a simple one for our needs, and put it under `lib`. Think of it as an open source client library that we are writing in-house.

If we must write an external client, it would look something like this:

```ruby
class SuperAwesomeSms < HTTPClient
  def initialize(creds)
    @creds = creds
  end

  def create_notification(text)
    http(@creds).post("example.com/notifications", text: text)
  end

  def get_notification_status(id)
    http(@creds).get("example.com/#{id}/status")
  end
end
```

## Internal client

We must always write an internal client for our needs, and it should be placed here, under `app/clients`. It provides an interface for our application that we can mock. Our application should never use the external client directly.

An internal client would look something like this (based upon the external client above):

```ruby
class SmsClient
  def initialize(creds)
    @client = SuperAwesomeSms.new(creds)
  end

  def send_text(text)
    response = @client.create_notification(text)
    sleep 1 until get_notification_status(response.id) == "delivered"
    true
  end
end
```

## Rules for testing clients

1. Existing external clients don't need any additional tests from us.
2. In-house written external clients should have their own dedicated test suite (like any open source project would).
3. Internal clients must be tested against real API using something like [vcr](https://github.com/vcr/vcr).
4. Other application tests must mock internal clients.
```
