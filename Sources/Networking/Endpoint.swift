import Foundation

public enum HTTPMethod {
	case delete
	case get
	case head
	case option
	case patch(Data?)
	case post(Data?)
	case put(Data?)
	
	var value: String {
		switch self {
		case .delete: return  "DELETE"
		case .get: return "GET"
		case .head: return "HEAD"
		case .option: return "OPTION"
		case .patch: return "PATCH"
		case .post: return "POST"
		case .put: return "PUT"
		}
	}
}

public typealias QueryParameter = (key: String, value: String)

public typealias HttpHeader = (field: String, value: String)

public enum ContentType: String {
	case json = "application/json"
	// Add more content types if needed.
}

/// Type that encapsulates a backend endpoint.
public struct Endpoint<Decoding> {
	/// The endpoint URL.
	public let url: URL
	
	/// The HTTP request method for the endpoint.
	public let httpMethod: HTTPMethod
	
	/// The parameters of the http requests query string.
	public let parameters: [QueryParameter]?
	
	/// The parameters of the http requests query string.
	public let customHeaders: [HttpHeader]?
	
	/// The content type of the http requests body.
	public let contentType: ContentType

	public init(
		url: URL,
		httpMethod: HTTPMethod,
		parameters: [QueryParameter]? = nil,
		customHeaders: [HttpHeader]?,
		contentType: ContentType = .json
	) {
		self.url = url
		self.httpMethod = httpMethod
		self.parameters = parameters
		self.customHeaders = customHeaders
		self.contentType = contentType
	}
}
