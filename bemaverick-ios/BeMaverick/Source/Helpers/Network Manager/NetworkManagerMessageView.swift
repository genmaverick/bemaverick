//
//  NetworkManagerMessageView.swift
//  Maverick
//
//  Created by Chris Garvey on 5/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import SwiftMessages

class NetworkManagerMessageView: MessageView {
    
    /// The network message to be displayed to the user
    @IBOutlet weak var messageLabel: UILabel!
    /// The button to dismiss the message if pressed by user
    @IBAction func dismissButton(_ sender: UIButton) {
        SwiftMessages.hide()
    }
    

    /**
     Set the message to be displayed
     - parameter message: The string to display
     */
    public func setMessage(_ message: String) {
        messageLabel.text = message
    }
            
}
