//
//  main.swift
//  bulk-add-cert
//
//  Created by Nico Verbruggen on 13/01/2023.
//

import Foundation
import Security
import Cocoa

print("We will attempt to add a certificate to the keychain... let's go!")

// we will need to convert .key to .der
// e.g.
/**
 We will need to convert the .key to .der format:

 ```sh
 openssl x509 -in /Users/nicoverbruggen/.config/valet/CA/LaravelValetCASelfSigned.pem -out /Users/nicoverbruggen/.config/valet/CA/LaravelValetCASelfSigned.der -outform DER

 As per: https://developer.apple.com/forums/thread/68789
 ```
 */

func addCertificateWithPath(path: String) {
    let url = URL(fileURLWithPath: path)
    guard let data = NSData(contentsOf: url) else {
        print("certificate not found")
        exit(1)
    }

    let certificate = SecCertificateCreateWithData(nil, data)

    // TODO: Check if the certificate already exists

    let addQuery: [String: Any] = [kSecClass as String: kSecClassCertificate,
                                   kSecValueRef as String: certificate!,
                                   kSecAttrLabel as String: "Valet Certificate"]

    let status = SecItemAdd(addQuery as CFDictionary, nil)

    guard status == errSecSuccess else {
        print("Could not add the certificate. Maybe it was added before?")
        exit(1)
    }

    let outcome = SecTrustSettingsSetTrustSettings(certificate!, .admin, nil)

    guard outcome == errSecSuccess else {
        print("Could not add to admin trust.")
        print(SecCopyErrorMessageString(outcome, nil) ?? "No error provided.")
        exit(1)
    }

    print("Certificate for path \(path) has been added!")
}

addCertificateWithPath(path: "/Users/nicoverbruggen/.config/valet/CA/LaravelValetCASelfSigned.der")
