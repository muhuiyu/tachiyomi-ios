//
//  UIImageView+loadImageUsingURL.swift
//  Money Tracker
//
//  Created by Grace, Mu-Hui Yu on 7/31/23.
//

import Foundation
import UIKit

extension UIImageView {
    
    func loadImageUsingUrlString(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, respones, error) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
            
        }).resume()
    }
    
}
