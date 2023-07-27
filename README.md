<img alt="logo image" src="https://s3.eu-west-1.amazonaws.com/it.zero12.common-libraries/zero12-common-networking.jpg" width="653"/>

# Zero12 Common Networking

Common Networking is a Swift library created by the [zero12](https://www.zero12.it/) Mobile Team to
make REST API calls in an easy way, trying to keep to minimum the amount of implementations
needed for the networking component.

# Overview

Every time a project start an amount of time must be spent to setup the networking layer,
creating the components needed to start/handle the requests and map the results and errors.
A possibility is to use big networking libraries that allow to handle every possible scenario,
but sometimes the need is only to do API calls (*get*/*post*/*put*/*delete*), receive the response and
map the returned data or error.
The purpose of this library is to speed up the bootstrap of a project, taking care of all the
procedure needed to create REST requests, waiting for the response from the server and mapping
the result.

## Quick start

To run network requests you need an instance of APIClient, the main class of this library. To do
it you need to define the error model that the client will use to map errors returned by the server.
This is an example of how it can be defined:
``` swift
struct NetworkErrorDataModel: Decodable {
    var message: String?
}
```

Once done the client can be initialized as follow:
```
let client: APIClient<NetworkErrorDataModel> = APIClient()
```

Remember to import `CommonNetworking` in the same file when initializing the client.

After doing so, you are free to run requests as follow:
``` swift
let request = APIRequestSettings(url: "https://my.api.com",
                                 urlPathComponent: "/path",
                                 httpMethod: .get,
                                 httpHeaderFields: [
                                    Headers.authorization.rawValue: "Bearer \(accessToken)"
                                 ]))
do {
    let response: ResponseDataModel = try await client.run(request)
    // use the response
} catch let networkError as NetworkError<NetworkErrorDataModel> {
    // handle error
}
```

Where `ResponseDataModel` will be the data model that you will define to map the response from
the API. Remember that that model will need to implement the `Decodable` protocol.

In case of APIs with an empty response body, like the `204 no content` response,
an `EmptyContent` object should be used as return type, like this:
```
let response: EmptyContent = try await client.run(request)
```

The APIClient instance is not unique, you can have as many client as you may need, for example one
in every remote repository. The only constraint is that a single APIClient have only one
error model to map.

## Installation

You can add Common Networking to an Xcode project by adding it to your project as a package.

> https://github.com/zero12srl/zero12-common-networking

You can add Common Networking in a [SwiftPM](https://swift.org/package-manager/) project by adding
it to the `Package.swift`:

``` swift
dependencies: [
  .package(url: "https://github.com/zero12srl/zero12-common-networking", .upToNextMajor(from: "1.0.0"))
]
```

And to the target:
``` swift
.product(name: "CommonNetworking", package: "CommonNetworking"),
```

Then just import it through:
```
import CommonNetworking
```

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.

## About

Made with ❤️ by zero12. 
The names and logo are trademarks of zero12 srl.
