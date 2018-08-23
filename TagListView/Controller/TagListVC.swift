//
//  TagListVC.swift
//  TagListView
//
//  Created by Rahul Chopra on 21/08/18.
//  Copyright © 2018 AppSmall. All rights reserved.
//

import UIKit
import SearchTextField

class TagListVC: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: SearchTextField!
    @IBOutlet weak var searchTextFieldLeadingConstraint: NSLayoutConstraint!
    
    var selectedCategoriesArray = [String]()
    var tagViews = [TagView]()
    
    //Dummy Data
    var categoryNames = ["Attorney Lawyers", "Intellectual Property Lawyer", "Employement Lawyer", "Personal Injury Lawyer", "Immigration Lawyer"]
    
    //MARK:- VIEW CONTROLLER METHODS
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    //MARK:- CORE FUNCTIONS
    func showSearchView() {
        searchTextField.filterStrings(categoryNames)
        searchTextField.startVisibleWithoutInteraction = true
        searchTextField.comparisonOptions = .caseInsensitive
        searchTextField.theme = .darkTheme()
        searchTextField.theme.font = UIFont.systemFont(ofSize: 15)
        searchTextField.theme.bgColor = UIColor(red: 88/255, green: 83/255, blue: 83/255, alpha: 1)
        
        searchTextField.itemSelectionHandler = { [unowned self] filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            
            self.selectedCategoriesArray.append(item.title)
            self.createTagView(name: item.title)
        }
    }
    
    func createTagView(name: String) {
        self.searchTextField.text = ""
        self.searchTextField.resignFirstResponder()
        if let constraint = searchTextFieldLeadingConstraint {
            constraint.isActive = false
        }
        
        let tagView = TagView(frame: CGRect.zero)
        tagView.label.sizeToFit()
        tagView.delegate = self
        tagView.label.text = name
        tagViews.append(tagView)
        tagView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(tagView)
        self.view.layoutIfNeeded()
        
        let labelWidth = tagView.label.frame.width
        let increasedWidth = (labelWidth + 40).rounded()
        contentViewWidthConstraint.constant += increasedWidth + 5  //Adding 5 in ContentViewWidthConstraint and this 5 is comes from TagView Leading Constraint size.
        
        if selectedCategoriesArray.count == 1 {
            tagView.tagViewleadingConstraint = tagView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5)
            tagView.tagViewleadingConstraint?.isActive = true
        }
        else {
            if let lastTagView = tagViews.last {
                if let index = tagViews.index(of: lastTagView) {
                    let secondLastTagView = tagViews[index - 1]
                    
                    tagView.tagViewleadingConstraint = tagView.leadingAnchor.constraint(equalTo: secondLastTagView.trailingAnchor, constant: 5)
                    tagView.tagViewleadingConstraint?.isActive = true
                }
            }
        }
        
        tagView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        tagView.heightAnchor.constraint(equalToConstant: self.searchTextField.frame.size.height - 5).isActive = true
        tagView.widthAnchor.constraint(equalToConstant: increasedWidth).isActive = true
        
        if let lastTagView = tagViews.last {
            searchTextFieldLeadingConstraint = self.searchTextField.leadingAnchor.constraint(equalTo: lastTagView.trailingAnchor, constant: 5)
            searchTextFieldLeadingConstraint.isActive = true
        }
        
    }

}

extension TagListVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == searchTextField {
            showSearchView()
        }
    }
    
}

extension TagListVC: DeleteTagView {
    
    func deleteTagView(tagView: TagView) {
        guard let deletedTagIndex = tagViews.index(of: tagView) else {
            return
        }
        guard let deletedCategory = tagView.label.text else {
            return
        }
        
        print("Deleted View : \(deletedCategory)")
        
        if tagView == tagViews.first {
            print("First Element Deleted")
            if deletedTagIndex < tagViews.count - 1 {
                let nextTagView = tagViews[deletedTagIndex + 1]
                nextTagView.tagViewleadingConstraint?.isActive = false
                nextTagView.tagViewleadingConstraint = nextTagView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5)
                nextTagView.tagViewleadingConstraint?.isActive = true
            }
            else {
                //If there is only one element in TagViews array
                searchTextFieldLeadingConstraint?.isActive = false
                searchTextFieldLeadingConstraint = self.searchTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5)
                searchTextFieldLeadingConstraint?.isActive = true
            }
        }
        else if tagView == tagViews.last {
            print("Last Element Deleted")
            let prevTagView = tagViews[deletedTagIndex - 1]
            searchTextFieldLeadingConstraint.isActive = false
            searchTextFieldLeadingConstraint = self.searchTextField.leadingAnchor.constraint(equalTo: prevTagView.trailingAnchor, constant: 5)
            searchTextFieldLeadingConstraint.isActive = true
        }
        else {
            print("Other than First and Last Element Deleted")
            let nextTagView = tagViews[deletedTagIndex + 1]
            let prevTagView = tagViews[deletedTagIndex - 1]
            nextTagView.tagViewleadingConstraint?.isActive = false
            nextTagView.tagViewleadingConstraint = nextTagView.leadingAnchor.constraint(equalTo: prevTagView.trailingAnchor, constant: 5)
            nextTagView.tagViewleadingConstraint?.isActive = true
        }
        
        if let deletedCategoryIndex = selectedCategoriesArray.index(of: deletedCategory) {
            selectedCategoriesArray.remove(at: deletedCategoryIndex)
        }
        
        let labelWidth = tagView.label.frame.size.width
        let decreasedWidth = labelWidth.rounded() + 40 + 5  //Adding 5 from ContentViewWidthConstraint and this 5 comes from TagView Leading Constraint size.
        contentViewWidthConstraint.constant -= decreasedWidth
        
        tagView.removeFromSuperview()
        tagViews.remove(at: deletedTagIndex)
        
    }
    
}
