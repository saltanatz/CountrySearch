//
//  Model.swift
//  CountrySearch
//
//  Created by Saltanat on 24.06.2024.
//

import Foundation

struct CountryInfo: Codable {
	var name: Name
	var capital: [String]?
	var population: Int
	var flags: Flags
}

struct Name: Codable {
	var common: String

}

struct Flags: Codable {
	var png: String?
	
	enum CodingKeys: String, CodingKey {
		case png = "png"
	}
}
