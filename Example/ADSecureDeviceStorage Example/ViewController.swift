//
//  ViewController.swift
//  ADSecureDeviceStorage Example
//
//  Created by Johannes Steib on 08.03.17.
//  Copyright © 2017 adorsys GmbH & Co KG. All rights reserved.
//

import UIKit
import ADSecureDeviceStorage

class ViewController: UIViewController {

    private let secretKey = "keyForSecret"
    private let titleForSaveAlert = "Save Information Securely"
    private let titleForGetAlert = "Get Secured Information"
    private let messageForSaveAlert = "Your information is stored securely on the device and protected with the password you enter in the field below."
    private let messageForGetAlert = "To get the secure information you have to enter the passwort that you used to protect the data."
    private let saveActionTitle = "Save Information"
    private let getActionTitle = "Get Information"
    private let cancelActionTitle = "Cancel"
    private let authenticationPrompt = "Please use your fingerprint to get the secured information."

    private let user = "john.doe"

    @IBOutlet weak var protectionLabel: UILabel!
    @IBOutlet weak var textEntryField: UITextField!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var savedSuccessfullyLabel: UILabel!
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var storedInfoLabel: UILabel!

    var keychainStoreContainsValue = false
    var encryptedStoreContainsValue = false

    let hasPasscode = SecureDeviceStorage.deviceHasPasscode()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        if !hasPasscode {
            protectionLabel.text = "Device is not protected!"
            protectionLabel.textColor = UIColor.red
        }
        savedSuccessfullyLabel.isHidden = true
        getButton.isHidden = true
        storedInfoLabel.isHidden = true
    }

    func updateUI() {
        if keychainStoreContainsValue || encryptedStoreContainsValue {
            textEntryField.isHidden = true
            storeButton.isHidden = true
            getButton.isHidden = false
            savedSuccessfullyLabel.isHidden = false
            storedInfoLabel.isHidden = true
        } else {
            textEntryField.isHidden = false
            storeButton.isHidden = false
            getButton.isHidden = true
            savedSuccessfullyLabel.isHidden = true
        }
    }

    @IBAction func storeButtonTouched(_ sender: UIButton) {
        guard let text = textEntryField.text,
            !text.isEmpty else { return }

        if hasPasscode {
            storeInKeychain(secret: text)
        } else {
            storeEncrypted(secret: text)
        }
        textEntryField.resignFirstResponder()
        textEntryField.text = ""
    }

    @IBAction func getButtonTouched(_ sender: UIButton) {
        guard keychainStoreContainsValue || encryptedStoreContainsValue else {
            return
        }
        if hasPasscode {
            getFromKeychain()
        } else {
            getFromEncryptedStore()
        }
    }

    func storeInKeychain(secret: String) {
        do {
            try SecureDeviceStorage.keychainStore()?.save(secret, for: secretKey)
            keychainStoreContainsValue = true
            updateUI()
        } catch {
            // TODO: handle failure
        }
    }

    func getFromKeychain() {
        DispatchQueue.global().async {
            let value = try? SecureDeviceStorage
                .keychainStore(authenticationPrompt: self.authenticationPrompt)?
                .getString(for: self.secretKey)
            DispatchQueue.main.async {
                guard let unwrappedValue = value,
                    let info = unwrappedValue else {
                        return
                }
                self.storedInfoLabel.text = "Stored information: \(info)"
                self.storedInfoLabel.isHidden = false
                self.keychainStoreContainsValue = false
                self.updateUI()
            }
        }
    }

    func storeEncrypted(secret: String) {
        let alert = alertControllerWithTextField(title: titleForSaveAlert,
                                                 message: messageForSaveAlert,
                                                 confirmActionTitle: saveActionTitle) { (password) in
                                                    guard let pw = password else {
                                                        return
                                                    }
                                                    do {
                                                        try SecureDeviceStorage
                                                            .encryptedStore(password: pw, user: self.user)
                                                            .save(secret, for: self.secretKey)
                                                        self.encryptedStoreContainsValue = true
                                                        self.updateUI()
                                                    } catch {
                                                        // TODO: handle failure
                                                    }

        }
        present(alert, animated: true, completion: nil)
    }

    func getFromEncryptedStore() {
        let alert = alertControllerWithTextField(title: titleForGetAlert,
                                                 message: messageForGetAlert,
                                                 confirmActionTitle: getActionTitle) { (password) in
                                                    guard let pw = password,
                                                        let value = try? SecureDeviceStorage
                                                            .encryptedStore(password: pw, user: self.user)
                                                            .getString(for: self.secretKey)
                                                        else {
                                                            return
                                                    }
                                                    self.storedInfoLabel.text = "Stored information: \(value)"
                                                    self.storedInfoLabel.isHidden = false
                                                    self.encryptedStoreContainsValue = false
                                                    self.updateUI()
        }
        present(alert, animated: true, completion: nil)
    }

    func alertControllerWithTextField(title: String,
                                      message: String,
                                      confirmActionTitle: String,
                                      entryHandler: @escaping (String?) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .default) { (action) in
            let textField = alert.textFields?.first
            entryHandler(textField?.text)
        }
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)

        alert.addTextField { (textField) in
            textField.placeholder = "Enter password"
            textField.isSecureTextEntry = true
        }

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        return alert
    }
}
