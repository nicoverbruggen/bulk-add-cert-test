//
//  main.swift
//  bulk-add-cert
//
//  Created by Nico Verbruggen on 13/01/2023.
//

import Foundation
import Security
import Cocoa

/**
 Before this will work, we will need to convert the .key to .der format.
 For now, you have to do this manually, but the program could do this.
 Just testing right now so no need to do this with this program.

 ```sh
 openssl x509 -in /Users/$(whoami)/.config/valet/CA/LaravelValetCASelfSigned.pem -out /Users/$(whoami)/.config/valet/CA/LaravelValetCASelfSigned.der -outform DER

 As per: https://developer.apple.com/forums/thread/68789
 ```
 */

func addCertificateWithPath(path: String) {
    print("We will attempt to add a certificate to the keychain... let's go!")

    let url = URL(fileURLWithPath: path)
    guard let data = NSData(contentsOf: url) else {
        print("Certificate file not found.")
        exit(1)
    }

    let certificate = SecCertificateCreateWithData(nil, data)

    let addQuery: [String: Any] = [kSecClass as String: kSecClassCertificate,
                                   kSecValueRef as String: certificate!]

    // TODO: Check if the certificate already exists?

    let status = SecItemAdd(addQuery as CFDictionary, nil)

    guard status == errSecSuccess else {
        print("Could not add the certificate. Maybe it was added before?")
        exit(1)
    }

    // As far as I can tell, this invocation is responsible for the alert.
    // So even if we loop over multiple certificates, I think we will get multiple popups.
    // Currently, I cannot seem to run this successfully on a non-CA cert, and this is why (as per documentation):
    // > If you pass NULL for the trustSettingsDictOrArray parameter, then the trust settings for this certificate are stored as an empty trust settings array, indicating "always trust this root certificate regardless of use." This setting is valid only for a self-signed (root) certificate.
    // Not sure what I need to actually pas in `trustSettingsDictOrArray` to make normal certs work, but if they pop up multiple modals then this is useless after all.
    let outcome = SecTrustSettingsSetTrustSettings(certificate!, .admin, nil)

    guard outcome == errSecSuccess else {
        print("Could not add to admin trust.")
        print(SecCopyErrorMessageString(outcome, nil) ?? "No error provided.")
        exit(1)
    }

    print("Certificate for path \(path) has been added!")
}

addCertificateWithPath(path: "/Users/nicoverbruggen/.config/valet/CA/LaravelValetCASelfSigned.der")
