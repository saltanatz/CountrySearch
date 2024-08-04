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
	
	private var FirstLabel = UILabel()
	private var SecondLabel = UILabel()
	private let flagImageView = UIImageView()
	let container = UIView()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	private func configureUI(){
		contentView.addSubview(container)
		
		container.addSubview(flagImageView)
		container.addSubview(FirstLabel)
		container.addSubview(SecondLabel)
		
		container.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(8)
			make.right.equalToSuperview().offset(-8)
			make.top.equalToSuperview().offset(8)
			make.bottom.equalToSuperview().offset(-8)
		}
		flagImageView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(10)
			make.centerY.equalToSuperview()
			make.width.height.equalTo(40)
		}
		FirstLabel.snp.makeConstraints { make in
			make.left.equalTo(flagImageView.snp.right).offset(10)
			make.top.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-10)
		}
		SecondLabel.snp.makeConstraints { make in
			make.left.right.equalTo(FirstLabel)
			make.top.equalTo(FirstLabel.snp.bottom).offset(5)
		}
		contentView.backgroundColor = UIColor(red: 222.0/255.0, green: 239.0/255.0, blue: 245/255.0, alpha: 1.0)
		container.layer.cornerRadius = 10
		container.backgroundColor = .white
	}
	
	func configure(with country: CountryInfo, display: Int){
		switch display {
		case 0:
			FirstLabel.text = "\(country.name.common)"
			SecondLabel.text = "Area: \(country.area ?? 0)"
		case 1:
			FirstLabel.text = "\(country.capital?.first ?? "")"
			SecondLabel.text = "Population: \(country.population)"
		default:
			break
		}
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
