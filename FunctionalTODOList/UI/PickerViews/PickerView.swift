// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

protocol PickerViewDelegate {

    func updateElementSelected(element: String)
}

class PickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

    var pickerDataSource: Array<String>?
    var pickerDelegate: PickerViewDelegate?

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func numberOfComponentsInPickerView(pickerView _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return pickerDataSource.flatMap { $0.count } ?? 0
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {

        return pickerDataSource?[row]
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {

        pickerDelegate.flatMap { picker in
            pickerDataSource.flatMap {
                picker.updateElementSelected(element: $0[row])
            }
        }
    }

    func set(dataSource: Array<String>) {

        delegate = self
        self.dataSource = self

        pickerDataSource = dataSource

        reloadAllComponents()
    }
}
