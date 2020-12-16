//
//  Meme.swift
//  MemeMe
//
//  Created by Lucas Mahe on 16/12/2020.
//

import Foundation
import UIKit

struct Meme {
    
    let topText: String
    let bottomText: String
    let originalImage: UIImage
    let memedImage: UIImage
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}
