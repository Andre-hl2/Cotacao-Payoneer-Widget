//
//  TodayViewController.swift
//  Cotacao Payoneer Widget
//
//  Created by Andre Ferreira dos Santos on 13/06/17.
//  Copyright © 2017 SukafuSoftworks. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding, NCWidgetListViewDelegate, NCWidgetSearchViewDelegate {

    @IBOutlet var listViewController: NCWidgetListViewController!
    var searchController: NCWidgetSearchViewController?
    
    // Only mock data to test the UI
    var quotations : [Quotation] = [
        Quotation(name: "Cotação", value: "3,14"),
        Quotation(name: "Transferência", value: "3,15"),
        Quotation(name: "Pagamento", value: "3,16"),
        Quotation(name: "Saque", value: "3,17"),
        Quotation(name: "Ult. Att. Json", value: "13-07-2017"),
        Quotation(name: "Ult. Req.", value: "now")
    ]
    
    // MARK: - NSViewController
    
    override var nibName: String? {
        return "TodayViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the widget list view controller.
        // The contents property should contain an object for each row in the list.
        self.listViewController.contents = ["Cotação", "Transferência", "Pagamento", "Saque", "Última Atualização", "Ultima Requisicao"]
        
        //TODO: make the request and update the 'quotations' array
//        let json = parseJSON(inputData: getJSON(urlToRequest: "https://scrooge-mcduck-b.firebaseio.com/.json"))
        
    }
    
    func getJSON(urlToRequest: String) -> NSData{
        var data : NSData
        do {
            try data = NSData(contentsOf: NSURL(string: urlToRequest)! as URL)
        } catch _ {
            data = NSData()
        }
        
        return data
    }
    
    func parseJSON(inputData: NSData) -> NSDictionary{
        var boardsDictionary : NSDictionary
        do
        {
            try boardsDictionary = JSONSerialization.jsonObject(with: inputData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        } catch _ {
            boardsDictionary = NSDictionary()
        }
        
        return boardsDictionary
    }
    
    override func dismissViewController(_ viewController: NSViewController) {
        super.dismissViewController(viewController)
        
        // The search controller has been dismissed and is no longer needed.
        if viewController == self.searchController {
            self.searchController = nil
        }
    }
    
    // MARK: - NCWidgetProviding
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Refresh the widget's contents in preparation for a snapshot.
        // Call the completion handler block after the widget's contents have been
        // refreshed. Pass NCUpdateResultNoData to indicate that nothing has changed
        // or NCUpdateResultNewData to indicate that there is new data since the
        // last invocation of this method.
        let json = parseJSON(inputData: getJSON(urlToRequest: "https://scrooge-mcduck-b.firebaseio.com/currency.json/"))
        
        let currencyValue = json.value(forKey: "currency") as! Double
        quotations[0].value = "R$ " + String(format: "%.2f", currencyValue)
        
        let transferValue = currencyValue * 0.98
        let withdrawValue = currencyValue * 0.965
        let paymentValue = currencyValue * 0.97
        
        quotations[1].value = "R$ " + String(format: "%.2f", transferValue)
        quotations[2].value = "R$ " + String(format: "%.2f", withdrawValue)
        quotations[3].value = "R$ " + String(format: "%.2f", paymentValue)
        
        let updateValue = json.value(forKey: "timestamp") as! Int64
        let updateDate = Date(timeIntervalSince1970: TimeInterval(updateValue))
        
        let dateFor : DateFormatter = DateFormatter()
        
        dateFor.dateFormat = "HH:mm:ss"
        quotations[4].value  = dateFor.string(from: updateDate)

        let actualDate = Date()
        quotations[5].value = dateFor.string(from: actualDate)
        
        completionHandler(.newData)
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInset: EdgeInsets) -> EdgeInsets {
        // Override the left margin so that the list view is flush with the edge.
        var newInsets = defaultMarginInset
        newInsets.left = 0
        return newInsets
    }
    
    var widgetAllowsEditing: Bool {
        // Return true to indicate that the widget supports editing of content and
        // that the list view should be allowed to enter an edit mode.
        return false
    }
    
    // MARK: - NCWidgetListViewDelegate
    
    func widgetList(_ list: NCWidgetListViewController, viewControllerForRow row: Int) -> NSViewController {
        // Return a new view controller subclass for displaying an item of widget
        // content. The NCWidgetListViewController will set the representedObject
        // of this view controller to one of the objects in its contents array.
        let list = ListRowViewController()
        list.setFields(quotation: quotations[row])
        return list
    }
    
    func widgetListPerformAddAction(_ list: NCWidgetListViewController) {
        // The user has clicked the add button in the list view.
        // Display a search controller for adding new content to the widget.
        let searchController = NCWidgetSearchViewController()
        self.searchController = searchController
        searchController.delegate = self
        
        // Present the search view controller with an animation.
        // Implement dismissViewController to observe when the view controller
        // has been dismissed and is no longer needed.
        self.present(inWidget: searchController)
    }
    
    func widgetList(_ list: NCWidgetListViewController, shouldReorderRow row: Int) -> Bool {
        // Return true to allow the item to be reordered in the list by the user.
        return true
    }
    
    func widgetList(_ list: NCWidgetListViewController, didReorderRow row: Int, toRow newIndex: Int) {
        // The user has reordered an item in the list.
    }
    
    func widgetList(_ list: NCWidgetListViewController, shouldRemoveRow row: Int) -> Bool {
        // Return true to allow the item to be removed from the list by the user.
        return true
    }
    
    func widgetList(_ list: NCWidgetListViewController, didRemoveRow row: Int) {
        // The user has removed an item from the list.
    }
    
    // MARK: - NCWidgetSearchViewDelegate
    
    func widgetSearch(_ searchController: NCWidgetSearchViewController, searchForTerm searchTerm: String, maxResults max: Int) {
        // The user has entered a search term. Set the controller's searchResults property to the matching items.
        searchController.searchResults = []
    }
    
    func widgetSearchTermCleared(_ searchController: NCWidgetSearchViewController) {
        // The user has cleared the search field. Remove the search results.
        searchController.searchResults = nil
    }
    
    func widgetSearch(_ searchController: NCWidgetSearchViewController, resultSelected object: Any) {
        // The user has selected a search result from the list.
    }
}

class Quotation {
    var name : String?
    var value : String?
    
    init(name : String, value: String) {
        self.name = name
        self.value = value
    }
}
