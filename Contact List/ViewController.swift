//
//  ViewController.swift
//  Contact List
//
//  Created by Winston Castillo on 26/5/21.
//

import UIKit
import Contacts

class ViewController: UIViewController {
    
    var contacts = [CNContact]()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {

        tableView.delegate = self
        tableView.dataSource = self
        requestContacts()
    }

    private func requestContacts() {
        let store = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        if authorizationStatus == .notDetermined {
            store.requestAccess(for: .contacts) {
                [weak self] didAuthorize, error in
                if didAuthorize {
                    self?.retrieveContacts(from: store)
                }
            }
        } else if authorizationStatus == .authorized {
            retrieveContacts(from: store)
        }
    }
    
    func retrieveContacts(from store: CNContactStore) {
        let containerId = store.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
        let keysToFech = [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor]
        
        contacts = try!
            store.unifiedContacts(matching: predicate, keysToFetch: keysToFech)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}

class ContactCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contactImageView = nil
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        let alertController = UIAlertController (title: "Contact Details", message: "Hey \(contact.givenName)!!", preferredStyle: .alert)
        let dissmissAction = UIAlertAction(title: "Done", style: .default, handler: {
            action in tableView.deselectRow(at: indexPath, animated: true)
        })
        alertController.addAction(dissmissAction);
        present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        //MARK: custom cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactCell else {
                return UITableViewCell()
        }
        
        cell.nameLabel.text = contact.givenName
        if let imageData = contact.imageData {
            cell.contactImageView?.image = UIImage(data: imageData)
        } else {
            cell.contactImageView?.image = UIImage(systemName: "person.circle")
        }
        return cell
    }
    
    
}
