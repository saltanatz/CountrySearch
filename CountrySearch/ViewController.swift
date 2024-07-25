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
//	private var uniqueCountries: [String] = []
//
		
	// Segmented Control as a class-level property
	private lazy var segmentControl: UISegmentedControl = {
		let items = ["Light", "Dark"]
		let segmentControl = UISegmentedControl(items: items)
		segmentControl.selectedSegmentIndex = 0
		segmentControl.addTarget(self, action: #selector(themeChanged(_:)), for: .valueChanged)
		return segmentControl
	}()
	
	private var filteredCountry: [CountryInfo] = []
	private var countries: [CountryInfo] = []
	
	private var searchController = UISearchController(searchResultsController: nil)
	
	
	// MARK: TableView
	private var tableView: UITableView = {
		let tableView = UITableView()
		tableView.backgroundColor = .systemBackground
		tableView.allowsSelection = true
		tableView.register(CountryTableViewCell.self, forCellReuseIdentifier: CountryTableViewCell.identifier)
		
		return tableView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		
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
			make.left.right.equalTo(view)
			make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
		}
		
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
	
	
	private func parseJSON(){
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
					let countries = try JSONDecoder().decode([CountryInfo].self, from: data)
					DispatchQueue.main.async {
						self?.updateUI(with: countries.sorted { $0.name.common < $1.name.common })
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

	@objc func themeChanged(_ sender: UISegmentedControl){
		if sender.selectedSegmentIndex == 0 {
			view.overrideUserInterfaceStyle = .light
		} else {
			view.overrideUserInterfaceStyle = .dark
		}
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
			let matchesName = country.name.common.lowercased().contains(searchText)
			let matchesCapital = country.capital?.first?.lowercased().contains(searchText) ?? false
			let matchesPopulation = String(country.population).contains(searchText)
			return matchesName || matchesCapital || matchesPopulation
		
		}
		tableView.reloadData()
	}
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchController.isActive ? filteredCountry.count : countries.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: CountryTableViewCell.identifier, for: indexPath) as? CountryTableViewCell else { fatalError("Error")}
		
		let country = searchController.isActive ? filteredCountry[indexPath.row] : countries[indexPath.row]
		cell.configure(with: country)
		return cell
	}
}
