//
//  CountryPickerViewController.swift
//  CountryPickerView
//
//  Created by Kizito Nwose on 18/09/2017.
//  Copyright © 2017 Kizito Nwose. All rights reserved.
//

import UIKit

public class CountryPickerViewController: UITableViewController {

    public var searchController: UISearchController?
    fileprivate var searchResults = [Country]()
    fileprivate var isSearchMode = false
    fileprivate var sectionsTitles = [String]()
    fileprivate var countries = [String: [Country]]()
    fileprivate var hasPreferredSection: Bool {
        return dataSource.preferredCountriesSectionTitle != nil &&
            dataSource.preferredCountries.count > 0
    }
    fileprivate var showOnlyPreferredSection: Bool {
        return dataSource.showOnlyPreferredSection
    }
    
    internal weak var countryPickerView: CountryPickerView! {
        didSet {
            dataSource = CountryPickerViewDataSourceInternal(view: countryPickerView)
        }
    }
    
    fileprivate var dataSource: CountryPickerViewDataSourceInternal!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableItems()
        prepareNavItem()
        prepareSearchBar()
        
    }
   
}

// UI Setup
extension CountryPickerViewController {
    
    func prepareTableItems()  {
        if !showOnlyPreferredSection {
            let countriesArray = countryPickerView.countries
            
            var groupedData = Dictionary<String, [Country]>(grouping: countriesArray) {
                let name = $0.localizedName ?? $0.name
                return String(name.capitalized[name.startIndex])
            }
            groupedData.forEach{ key, value in
                groupedData[key] = value.sorted(by: { (lhs, rhs) -> Bool in
                    return lhs.name < rhs.name
                })
            }
            
            countries = groupedData
            sectionsTitles = groupedData.keys.sorted()
        }
        
        // Add preferred section if data is available
        if hasPreferredSection, let preferredTitle = dataSource.preferredCountriesSectionTitle {
            sectionsTitles.insert(preferredTitle, at: sectionsTitles.startIndex)
            countries[preferredTitle] = dataSource.preferredCountries
        }
        
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexTrackingBackgroundColor = .clear
        
        tableView.contentInsetAdjustmentBehavior = .never
        edgesForExtendedLayout = []
    }
    
    func prepareNavItem() {
        navigationItem.title = dataSource.navigationTitle
        
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                if #available(iOS 13.0, *) {
                   
                    UINavigationBar.appearance().barTintColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
                    navigationController?.navigationBar.standardAppearance.backgroundColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
                    navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
                    navigationController?.navigationBar.compactAppearance?.backgroundColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
                }
                tableView.backgroundView?.backgroundColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
                navigationController?.navigationBar.backgroundColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
                navigationController?.navigationBar.barTintColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
                view.backgroundColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
            } else {
                if #available(iOS 13.0, *) {
                    
                    UINavigationBar.appearance().barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                    navigationController?.navigationBar.standardAppearance.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                    navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                    navigationController?.navigationBar.compactAppearance?.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                }
                tableView.backgroundView?.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                navigationController?.navigationBar.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                navigationController?.navigationBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            }
        }

        // Add a close button if this is the root view controller
        if navigationController?.viewControllers.count == 1 {
            
            let closeButton = dataSource.closeButtonNavigationItem
            closeButton.target = self
            closeButton.action = #selector(close)
            navigationItem.leftBarButtonItem = closeButton
        }
    }
    
    func prepareSearchBar() {
        let searchBarPosition = dataSource.searchBarPosition
        if searchBarPosition == .hidden  {
            return
        }
        searchController = UISearchController(searchResultsController:  nil)
        searchController?.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.hidesNavigationBarDuringPresentation = searchBarPosition == .tableViewHeader
        searchController?.definesPresentationContext = true
        searchController?.searchBar.delegate = self
        searchController?.delegate = self
        let preferredTitle = dataSource.preferredSearchBarTitle
        searchController?.searchBar.placeholder = preferredTitle
        
        //searchController?.searchBar.setImage(UIImage(named: "search"), for: UISearchBar.Icon.search, state: .normal)
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                self.view.backgroundColor = UIColor.black
                searchController?.searchBar.barTintColor = .black
                tableView.backgroundColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
                tableView.tableHeaderView?.backgroundColor = .black
                tableView.sectionIndexColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            } else {
                self.view.backgroundColor = UIColor.white
                searchController?.searchBar.barTintColor = .white
                tableView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                tableView.tableHeaderView?.backgroundColor = .white
                tableView.sectionIndexColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
            }
        }
        
        switch searchBarPosition {
        case .tableViewHeader: tableView.tableHeaderView = searchController?.searchBar
        case .navigationBar: navigationItem.titleView = searchController?.searchBar
        default: break
        }
    }
    
    @objc private func close() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

//MARK:- UITableViewDataSource
extension CountryPickerViewController {
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return isSearchMode ? 1 : sectionsTitles.count
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchMode ? searchResults.count : countries[sectionsTitles[section]]!.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: CountryTableViewCell.self)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? CountryTableViewCell
            ?? CountryTableViewCell(style: .default, reuseIdentifier: identifier)
        
        let country = isSearchMode ? searchResults[indexPath.row]
            : countries[sectionsTitles[indexPath.section]]![indexPath.row]

        var name = country.localizedName ?? country.name
        if dataSource.showCountryCodeInList {
            name = "\(name) (\(country.code))"
        }
        if dataSource.showPhoneCodeInList {
            name = "\(name) (\(country.phoneCode))"
        }
        cell.imageView?.image = country.flag
        
        cell.flgSize = dataSource.cellImageViewSize
        cell.imageView?.clipsToBounds = true

        cell.imageView?.layer.cornerRadius = dataSource.cellImageViewCornerRadius
        cell.imageView?.layer.masksToBounds = true
        
        cell.textLabel?.text = name
        cell.textLabel?.font = dataSource.cellLabelFont
        if let color = dataSource.cellLabelColor {
            cell.textLabel?.textColor = color
        }
        
        let imageView: UIImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 10, height: 8))
        let bundle = Bundle(for: CountryPickerViewController.self)
        let image = UIImage(named: "CountryPickerView.bundle/tick", in: bundle, compatibleWith: nil)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        if country == countryPickerView.selectedCountry &&
            dataSource.showCheckmarkInList {
            cell.accessoryView = imageView
        } else {
            cell.accessoryType = .none
        }
        
        cell.separatorInset = .zero
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isSearchMode ? nil : sectionsTitles[section]
    }
    
    override public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isSearchMode {
            return nil
        } else {
            if hasPreferredSection {
                return Array<String>(sectionsTitles.dropFirst())
            }
            return sectionsTitles
        }
    }
    
    override public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sectionsTitles.firstIndex(of: title)!
    }
}

//MARK:- UITableViewDelegate
extension CountryPickerViewController {

    override public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = dataSource.sectionTitleLabelFont
            if let color = dataSource.sectionTitleLabelColor {
                header.textLabel?.textColor = color
            }
            if #available(iOS 12.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    header.backgroundColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
                    header.backgroundView?.backgroundColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
                } else {
                    header.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                    header.backgroundView?.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                }
            }
        }
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let country = isSearchMode ? searchResults[indexPath.row]
            : countries[sectionsTitles[indexPath.section]]![indexPath.row]

        searchController?.dismiss(animated: false, completion: nil)
        
        let completion = {
            self.countryPickerView.selectedCountry = country
            self.countryPickerView.delegate?.countryPickerView(self.countryPickerView, didSelectCountry: country)
        }
        // If this is root, dismiss, else pop
        if navigationController?.viewControllers.count == 1 {
            navigationController?.dismiss(animated: true, completion: completion)
        } else {
            navigationController?.popViewController(animated: true, completion: completion)
        }
    }
}

// MARK:- UISearchResultsUpdating
extension CountryPickerViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        isSearchMode = false
        if let text = searchController.searchBar.text, text.count > 0 {
            isSearchMode = true
            searchResults.removeAll()
            
            var indexArray = [Country]()
            
            if showOnlyPreferredSection && hasPreferredSection,
                let array = countries[dataSource.preferredCountriesSectionTitle!] {
                indexArray = array
            } else if let array = countries[String(text.capitalized[text.startIndex])] {
                indexArray = array
            }

            searchResults.append(contentsOf: indexArray.filter({
                let name = ($0.localizedName ?? $0.name).lowercased()
                let code = $0.code.lowercased()
                let query = text.lowercased()
                return name.hasPrefix(query) || (dataSource.showCountryCodeInList && code.hasPrefix(query))
            }))
        }
        tableView.reloadData()
    }
}

// MARK:- UISearchBarDelegate
extension CountryPickerViewController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Hide the back/left navigationItem button
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Show the back/left navigationItem button
        prepareNavItem()
        navigationItem.hidesBackButton = false
    }
}

// MARK:- UISearchControllerDelegate
// Fixes an issue where the search bar goes off screen sometimes.
extension CountryPickerViewController: UISearchControllerDelegate {
    public func willPresentSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    public func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = false
    }
}

// MARK:- CountryTableViewCell.
class CountryTableViewCell: UITableViewCell {
    
    var flgSize: CGSize = .zero
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame.size = flgSize
        imageView?.center.y = contentView.center.y
    }
}


// MARK:- An internal implementation of the CountryPickerViewDataSource.
// Returns default options where necessary if the data source is not set.
class CountryPickerViewDataSourceInternal: CountryPickerViewDataSource {
    
    private unowned var view: CountryPickerView
    
    init(view: CountryPickerView) {
        self.view = view
    }
    
    var preferredCountries: [Country] {
        return view.dataSource?.preferredCountries(in: view) ?? preferredCountries(in: view)
    }
    
    var preferredCountriesSectionTitle: String? {
        return view.dataSource?.sectionTitleForPreferredCountries(in: view)
    }
    
    var preferredSearchBarTitle: String? {
        return view.dataSource?.titleForSearchBar(in: view)
    }
    
    var showOnlyPreferredSection: Bool {
        return view.dataSource?.showOnlyPreferredSection(in: view) ?? showOnlyPreferredSection(in: view)
    }
    
    var sectionTitleLabelFont: UIFont {
        return view.dataSource?.sectionTitleLabelFont(in: view) ?? sectionTitleLabelFont(in: view)
    }

    var sectionTitleLabelColor: UIColor? {
        return view.dataSource?.sectionTitleLabelColor(in: view)
    }
    
    var cellLabelFont: UIFont {
        return view.dataSource?.cellLabelFont(in: view) ?? cellLabelFont(in: view)
    }
    
    var cellLabelColor: UIColor? {
        return view.dataSource?.cellLabelColor(in: view)
    }
    
    var cellImageViewSize: CGSize {
        return view.dataSource?.cellImageViewSize(in: view) ?? cellImageViewSize(in: view)
    }
    
    var cellImageViewCornerRadius: CGFloat {
        return view.dataSource?.cellImageViewCornerRadius(in: view) ?? cellImageViewCornerRadius(in: view)
    }
    
    var navigationTitle: String? {
        return view.dataSource?.navigationTitle(in: view)
    }
    
    var closeButtonNavigationItem: UIBarButtonItem {
        guard let button = view.dataSource?.closeButtonNavigationItem(in: view) else {
            let bundle = Bundle(for: CountryPickerViewController.self)
            let image = UIImage(named: "CountryPickerView.bundle/close", in: bundle, compatibleWith: nil)
            let barImage = UIBarButtonItem(image: image, style: .done, target: nil, action: nil)
            barImage.tintColor = .black
            
            return barImage
            //return UIBarButtonItem(title: "Close", style: .done, target: nil, action: nil)
        }
        return button
    }
    
    var searchBarPosition: SearchBarPosition {
        return view.dataSource?.searchBarPosition(in: view) ?? searchBarPosition(in: view)
    }
    
    var showPhoneCodeInList: Bool {
        return view.dataSource?.showPhoneCodeInList(in: view) ?? showPhoneCodeInList(in: view)
    }
    
    var showCountryCodeInList: Bool {
        return view.dataSource?.showCountryCodeInList(in: view) ?? showCountryCodeInList(in: view)
    }
    
    var showCheckmarkInList: Bool {
        return view.dataSource?.showCheckmarkInList(in: view) ?? showCheckmarkInList(in: view)
    }
}

class CustomSearchView: UIView {

    var searchBar : UISearchBar!

    override func awakeFromNib()
    {
        // the actual search barw
        self.searchBar = UISearchBar(frame: self.frame)

        self.searchBar.clipsToBounds = true

        // the smaller the number in relation to the view, the more subtle
        // the rounding -- https://www.hackingwithswift.com/example-code/calayer/how-to-round-the-corners-of-a-uiview
        self.searchBar.layer.cornerRadius = 5

        self.addSubview(self.searchBar)

        self.searchBar.translatesAutoresizingMaskIntoConstraints = false

        let leadingConstraint = NSLayoutConstraint(item: self.searchBar, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20)
        let trailingConstraint = NSLayoutConstraint(item: self.searchBar, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -20)
        let yConstraint = NSLayoutConstraint(item: self.searchBar, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)

        self.addConstraints([yConstraint, leadingConstraint, trailingConstraint])

        self.searchBar.backgroundColor = UIColor.clear
        self.searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        self.searchBar.tintColor = UIColor.clear
        self.searchBar.isTranslucent = true

        // https://stackoverflow.com/questions/21191801/how-to-add-a-1-pixel-gray-border-around-a-uisearchbar-textfield/21192270
        for s in self.searchBar.subviews[0].subviews {
            if s is UITextField {
                s.layer.borderWidth = 1.0
                s.layer.cornerRadius = 10
                s.layer.borderColor = UIColor.green.cgColor
            }
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // the half height green background you wanted...
        let topRect = CGRect(origin: .zero, size: CGSize(width: self.frame.size.width, height: (self.frame.height / 2)))
        UIColor.green.set()
        UIRectFill(topRect)
    }

}
