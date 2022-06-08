//
//  File.swift
//  
//
//  Created by Mads Westi on 08/06/2022.
//

import Foundation

let networkClient = NetworkClient()

struct RequestData: Codable {
	let content: String
}

struct ResponseData: Codable {
	let content: String
}

let data = JSONEncoder().encode(RequestData(content: "stuff"))

let endpoint: Endpoint<ResponseData> = Endpoint(url: URL(string: "")!,
										  httpMethod: .post(data),
										  contentType: .json)

networkClient =

URLSession.
