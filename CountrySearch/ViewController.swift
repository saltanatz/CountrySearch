//
//  ViewController.swift
//  CountrySearchApp
//
//  Created by Saltanat on 24.06.2024.
//
import SnapKit
import UIKit

class ViewController: UIViewController {
	// MARK: Variables
	let cellSpacingHeight: CGFloat = 200
		
	// Segmented Control as a class-level property
	private lazy var segmentControl: UISegmentedControl = {
		let items = ["Countries", "Capitals"]
		let segmentControl = UISegmentedControl(items: items)
		segmentControl.selectedSegmentIndex = 0
		segmentControl.addTarget(self, action: #selector(segmentControlChanged(_:)), for: .valueChanged)
		return segmentControl
	}()
	
	private var filteredCountry: [CountryInfo] = []
	private var countries: [CountryInfo] = []
	
	private var searchController = UISearchController(searchResultsController: nil)
	
	
	// MARK: TableView
	private var tableView: UITableView = {
		let tableView = UITableView()
		tableView.backgroundColor = UIColor(red: 222.0/255.0, green: 239.0/255.0, blue: 245/255.0, alpha: 1.0)
		tableView.allowsSelection = true
		tableView.register(CountryTableViewCell.self, forCellReuseIdentifier: CountryTableViewCell.identifier)
		return tableView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(red: 222.0/255.0, green: 239.0/255.0, blue: 245/255.0, alpha: 1.0)
		tableView.separatorStyle = .none
		setupSearchController()
		configureUI()
		parseJSON()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(false, animated: false)
	}
	// MARK: TableView Setup
	private func configureUI(){
		view.addSubview(segmentControl)
		
		segmentControl.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
			make.centerX.equalTo(view.snp.centerX)
		}
		
		
		view.addSubview(tableView)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.snp.makeConstraints { make in
			make.top.equalTo(segmentControl.snp.bottom).offset(10)
			make.left.equalTo(view).offset(10)
			make.right.equalTo(view).offset(-10)
			make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
		}
		
	}
	private func sortCountriesBasedOnSegment() {
		switch segmentControl.selectedSegmentIndex {
		case 0:
			countries.sort { $0.name.common < $1.name.common }
		case 1:
			countries.sort { ($0.capital?.first ?? "") < ($1.capital?.first ?? "") }
		default:
			break
		}
		tableView.reloadData()
	}
	private func setupSearchController(){
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = false
		searchController.searchBar.placeholder = "Search Country"
		
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		definesPresentationContext = false
		title = "Country Search"
	}
	
	private func parseJSON() {
		guard let url = URL(string: "https://restcountries.com/v3.1/all") else {
			print("Invalid URL")
			return
		}
		URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			guard let data = data, error == nil else {
				print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
				return
			}
			do {
				let allCountries = try JSONDecoder().decode([CountryInfo].self, from: data)
				let validCountries = allCountries.filter { !($0.capital?.isEmpty ?? true)  }
				DispatchQueue.main.async {
					self?.countries = validCountries
					self?.sortCountriesBasedOnSegment()
				}
			} catch {
				print("Error decoding JSON: \(error)")
			}
		}.resume()
	}

	private func updateUI(with countries: [CountryInfo]){
		self.countries = countries
		self.tableView.reloadData()
	}
	

	@objc func segmentControlChanged(_ sender: UISegmentedControl){
		sortCountriesBasedOnSegment()
	}
}


extension ViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
			filteredCountry = countries
			tableView.reloadData()
			return
		}
		filteredCountry = countries.filter { country in
				let hasValidCapital = !(country.capital?.isEmpty ?? true)
				if !hasValidCapital {
					return false
				}
				if segmentControl.selectedSegmentIndex == 0 {
					return country.name.common.lowercased().contains(searchText)
				} else {
					return country.capital?.first?.lowercased().contains(searchText) ?? false
				}
		}
		tableView.reloadData()
	}
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchController.isActive ? filteredCountry.count : countries.count
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 120 // Adjust this value based on your cell content size
	}
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: CountryTableViewCell.identifier, for: indexPath) as? CountryTableViewCell else { fatalError("Error")}
		
		let country = searchController.isActive ? filteredCountry[indexPath.row] : countries[indexPath.row]
		cell.configure(with: country, display: segmentControl.selectedSegmentIndex)
		
		return cell
		
	}
	

}
