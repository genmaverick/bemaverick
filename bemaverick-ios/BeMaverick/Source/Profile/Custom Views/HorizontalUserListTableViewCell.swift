//
//  ContentTableViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 2/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol HorizontalUserListTableViewCellDelegate : class {
    
    func itemTapped(userId: String?)
    
    func searchEntryStarted()
    
    
    func searchString(cell: HorizontalUserListTableViewCell, search : String?)
    
}

class HorizontalUserListTableViewCell : UITableViewCell {
    @IBOutlet weak var userHeaderContainer: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    /// component title
    @IBOutlet weak var label: UILabel!
    /// component title
    @IBOutlet weak var collectionView: UICollectionView!
    /// users list
    var users : [User] = [] {
      
        didSet {
            
            collectionView.reloadData()
            
        }
   
    }
    
    func dismissKeyboard() {
        
        searchBar.endEditing(true)
        
    }
    /// tap delegate
    weak var delegate: HorizontalUserListTableViewCellDelegate?
    
    override func awakeFromNib() {
        
        super .awakeFromNib()
        configureView()
        
    }
    
    private func configureView() {
        
       
        label.textColor = UIColor.MaverickDarkTextColor
        label.text = R.string.maverickStrings.myStreamUsers()
        collectionView.register(R.nib.horizontalUserView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            flowLayout.scrollDirection = .horizontal
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            
        }
        
        searchBar.setImage(R.image.search(), for: .search, state: .normal)
        searchBar.tintColor = UIColor.MaverickBadgePrimaryColor
        searchBar.setImage(R.image.close_purple(), for: .clear, state: .normal)
        
    }
    /**
     Setup view with given users
     */
    func configureView(with users : [User]  ) {
        
        self.users = users
        
        if self.users.count == 0 {
        
            userHeaderContainer.isHidden = true
            collectionView.isHidden = true
            
        } else {
            
            userHeaderContainer.isHidden = false
            collectionView.isHidden = false
        
        }
        
    }
    
}

extension HorizontalUserListTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return users.count + 1
    
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.horizontalUserViewId,
                                                      for: indexPath)!
    
        if let user = users[safe : indexPath.row] {
            
            cell.configureView(with: user)
        
        } else {
            
            cell.configureView(with: nil)
            
        }
        return cell
    
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        return CGSize(width: 90, height: 110)

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       
            
            delegate?.itemTapped(userId: users[safe : indexPath.row]?.userId)
        
        
        
    }

}


extension HorizontalUserListTableViewCell : UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        delegate?.searchString(cell: self, search: nil)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        delegate?.searchString(cell: self, search: searchBar.text)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
        if searchText.isEmpty {
            
            delegate?.searchString(cell: self, search: nil)
        
        }
        delegate?.searchString(cell: self, search: searchText)
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        delegate?.searchEntryStarted()
        return false
    }
    
    
}


