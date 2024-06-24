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
	private let searchController = UISearchController(searchResultsController: nil)
	
	// MARK: TableView
	private let tableView: UITableView = {
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
		setupTableView()
		parseJSON()
		
	}
	// MARK: TableView Setup
	private func setupTableView(){
		view.backgroundColor = .systemRed
		view.addSubview(tableView)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	private func setupSearchController(){
		self.searchController.searchResultsUpdater = self
		self.searchController.obscuresBackgroundDuringPresentation = false
		self.searchController.hidesNavigationBarDuringPresentation = false
		self.searchController.searchBar.placeholder = "Search Country"
		
		self.navigationItem.searchController = searchController
		self.definesPresentationContext = false
		self.navigationItem.hidesSearchBarWhenScrolling = false
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
				let filteredCountries = Set(countries.filter { $0.first.map { $0.isUppercase && $0.isLetter } ?? false })
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
		<#code#>
	}
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return uniqueCountries.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		cell.textLabel?.text = uniqueCountries[indexPath.row]
		return cell
	}
}
