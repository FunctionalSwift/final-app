// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

class TextView: UITextView, UITextViewDelegate {

    var placeHolder: String?

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

        delegate = self
    }

    func placeholder(text: String) {
        placeHolder = text
        self.text = text
        textColor = UIColor.lightGray
    }

    func text(_ text: String) {
        self.text = text
        textColor = UIColor.black
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        if textView.text == "" {
            textView.text = placeHolder
            textView.textColor = UIColor.lightGray
        }
    }
}
