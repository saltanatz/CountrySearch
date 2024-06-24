//
//  Model.swift
//  CountrySearch
//
//  Created by Saltanat on 24.06.2024.
//

import Foundation

struct PopulationResponse: Codable {
	var error: Bool
	var msg: String
	var data: [CountryInfo]
}

struct CountryInfo: Codable {
	var country: String
	var city: String
	var populationCounts: [PopulationCount]
}

struct PopulationCount: Codable {
	var year: String
	var value: String?
	var sex: String?
	var reliability: String?
	enum CodingKeys: String, CodingKey {
			case year, value, sex, reliability
		}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		year = try container.decode(String.self, forKey: .year)
		value = try container.decodeIfPresent(String.self, forKey: .value) ?? "default_value" // Provide a default value
		sex = try container.decodeIfPresent(String.self, forKey: .sex)
		reliability = try container.decodeIfPresent(String.self, forKey: .reliability)
	}
}
