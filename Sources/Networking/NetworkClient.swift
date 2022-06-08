import Foundation
import Combine

public typealias HTTPHeaders = [AnyHashable: Any]

/// Small wrapper around `URLSession`. Handles `Endpoint` types.
final public class NetworkClient {
	
	private let session: URLSession
	
	private let jsonDecoder = JSONDecoder()
	
	private let unauthorized: (() -> Void)?
	
	public init(
		configuration: URLSessionConfiguration = URLSessionConfiguration.default,
		defaultHeaders: HTTPHeaders = [:],
		onUnauthorized: (() -> Void)? = nil
	) {
		configuration.httpAdditionalHeaders = defaultHeaders
		configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 100 * 1024 * 1024)
		configuration.requestCachePolicy = .useProtocolCachePolicy
		self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
		self.unauthorized = onUnauthorized
	}
}

public extension NetworkClient {
	
	func request<ReturnType: Decodable>(_ endpoint: Endpoint<ReturnType>) async throws -> ReturnType  {
		let data = try await data(for: endpoint)
		return try self.jsonDecoder.decode(ReturnType.self, from: data)
	}
	
	func request(_ endpoint: Endpoint<Void>) async throws {
		let _ = try await data(for: endpoint)
	}
}

private extension NetworkClient {
	func data<ReturnType>(for endpoint: Endpoint<ReturnType>) async throws -> Data {
		guard let urlRequest = endpoint.urlRequest else {
			fatalError("Unable to create request from endpoint.")
		}

		let (data, response) = try await self.session.data(for: urlRequest)
		if let response = response as? HTTPURLResponse, response.statusCode >= 400 {
			throw HttpError(rawValue: response.statusCode) ?? Error.unknownStatusCode(response.statusCode)
		}
		
		return data
	}
}

private extension Endpoint {
	var urlRequest: URLRequest? {
		guard var components = URLComponents(url: self.url, resolvingAgainstBaseURL: true) else { return nil }
		components.queryItems = self.parameters?.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
		guard let url = components.url?.absoluteURL else { return nil }
		
		var request = URLRequest(url: url)
		request.httpMethod = self.httpMethod.value
		
		self.customHeaders?.forEach { field, value in
			request.setValue(value, forHTTPHeaderField: field)
		}
		
		switch httpMethod {
		case .patch(let payload),
			 .post(let payload),
			 .put(let payload):
			request.setValue(self.contentType.rawValue, forHTTPHeaderField: "Content-Type")
			request.httpBody = payload
			
		default:
			break
		}
		
		if let size = request.httpBody?.count {
			request.setValue(String(size), forHTTPHeaderField: "Content-Length")
		}
		
		return request
	}
}

extension NetworkClient {
	public enum Error: LocalizedError {
		case unknownResponse
		case unknownStatusCode(Int)
		
		public var errorDescription: String? {
			switch self {
			case .unknownResponse: return "Response is not a `HTTPURLResponse`"
			case .unknownStatusCode(let statusCode): return "Unknown statusCode: \(statusCode)"
			}
		}
	}
}
