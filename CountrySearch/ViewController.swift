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
	private var uniqueCountries: [String] = []
	
	private var filteredCountry: [String] = []
	
	private var searchController: UISearchController!
	
	// MARK: TableView
	private var tableView: UITableView = {
		let tableView = UITableView()
		tableView.backgroundColor = .systemBackground
		tableView.allowsSelection = true
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		
		return tableView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		setupSearchController()
		configureUI()
		parseJSON()
		
	}
	// MARK: TableView Setup
	private func configureUI(){
		view.addSubview(tableView)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	private func setupSearchController(){
		searchController = UISearchController(searchResultsController: nil)
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = false
		searchController.searchBar.placeholder = "Search Country"
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		definesPresentationContext = true
		tableView.tableHeaderView = searchController.searchBar
		
	}
	
	private func parseJSON(){
		guard let url = URL(string: "https://countriesnow.space/api/v0.1/countries/population/cities") else {
			print("Invalid URL")
			return
		}
		let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			guard let data = data, error == nil else {
				print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
				return
			}
			do {
				let response = try JSONDecoder().decode(PopulationResponse.self, from: data)
				let countries = response.data.map { $0.country }
				let filteredCountries = Set(countries.filter { $0.first.map { $0.isLetter } ?? false })
				self?.uniqueCountries = Array(Set(filteredCountries)).sorted()
				DispatchQueue.main.async {
					self?.tableView.reloadData()
				}
			} catch {
				print("Error decoding JSON: \(error)")
			}
		}
		task.resume()
	}
}

extension ViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
			filteredCountry = uniqueCountries
			tableView.reloadData()
			return
		}
		filteredCountry = uniqueCountries.filter{$0.lowercased().contains(searchText.lowercased())}
		tableView.reloadData()
	}
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchController.isActive ? filteredCountry.count : uniqueCountries.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let country = searchController.isActive ? filteredCountry[indexPath.row] : uniqueCountries[indexPath.row]
		cell.textLabel?.text = country
		return cell
	}
}
