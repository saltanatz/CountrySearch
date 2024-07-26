//
//  CountryTableViewCell.swift
//  CountrySearch
//
//  Created by Saltanat on 26.06.2024.
//

import Foundation
import UIKit
class CountryTableViewCell: UITableViewCell {
	
	static let identifier = "CountryTableViewCell"
	
	private var countryLabel = UILabel()
	private var capitalLabel = UILabel()
	private var populationLabel = UILabel()
	private let flagImageView = UIImageView()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	private func configureUI(){
		[countryLabel, capitalLabel,populationLabel, flagImageView].forEach {
			contentView.addSubview($0)
		}
		flagImageView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(10)
			make.centerY.equalToSuperview()
			make.width.height.equalTo(40)
		}
		countryLabel.snp.makeConstraints { make in
			make.left.equalTo(flagImageView.snp.right).offset(10)
			make.top.equalToSuperview().offset(10)
			make.right.equalToSuperview().offset(-10)
		}
		capitalLabel.snp.makeConstraints { make in
			make.left.right.equalTo(countryLabel)
			make.top.equalTo(countryLabel.snp.bottom).offset(5)
		}
		populationLabel.snp.makeConstraints { make in
			make.left.right.equalTo(countryLabel)
			make.top.equalTo(capitalLabel.snp.bottom
			).offset(5)
			make.bottom.equalToSuperview().offset(-10)
		}
	}
	
	func configure(with country: CountryInfo){
		countryLabel.text = country.name.common
		capitalLabel.text = "Capital: \(country.capital?.first ?? "N/A")"
		populationLabel.text = "Population: \(country.population)"
		if let urlString = country.flags.png, let url = URL(string: urlString) {
			flagImageView.loadImage(from: url)
		} else {
			print("Invalid URL or no URL provided")
		}
	}
}
extension UIImageView {
	func loadImage(from url: URL) {
		URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			guard let self = self else { return }
			if let error = error {
				print("Failed to load image: \(error.localizedDescription)")
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
				  let data = data, let image = UIImage(data: data) else {
				print("Invalid response or unable to create image from data")
				return
			}
			
			DispatchQueue.main.async {
				self.image = image
			}
		}.resume()
	}
}
