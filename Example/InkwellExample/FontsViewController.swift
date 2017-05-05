//
//  FontsViewController.swift
//  InkwellExample
//
// Copyright (c) 2017 Vinh Nguyen

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import UIKit
import Inkwell

final class FontsViewController: UITableViewController {
    let fonts = ["ABeeZee", "Abel", "Abhaya Libre", "Abril Fatface", "Aclonica", "Acme", "Actor", "Adamina", "Advent Pro", "Aguafina Script", "Akronim", "Aladin", "Aldrich", "Alef", "Alegreya", "Alegreya SC", "Alegreya Sans", "Alegreya Sans SC", "Alex Brush", "Alfa Slab One", "Alice", "Alike", "Alike Angular", "Allan", "Allerta", "Allerta Stencil", "Allura", "Almendra", "Almendra Display", "Almendra SC", "Amarante", "Amaranth", "Amatic SC", "Amatica SC", "Amethysta", "Amiko", "Amiri", "Amita", "Anaheim", "Andada", "Andika", "Angkor", "Annie Use Your Telescope", "Anonymous Pro", "Antic", "Antic Didone", "Antic Slab", "Anton", "Arapey", "Arbutus"]
    //                let fonts = ["ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee", "ABeeZee"]

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fonts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FontCell", for: indexPath) as! FontCell

        cell.display(Font(family: fonts[indexPath.row], variant: .regular))

        return cell
    }
}

class FontCell: UITableViewCell {
    let fontSize: CGFloat = 25
    var fontOperation: FontOperation?

    deinit {
        fontOperation?.cancel()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        fontOperation?.cancel()
        textLabel?.font = UIFont.systemFont(ofSize: fontSize)
        textLabel?.text = nil
    }

    func display(_ font: Font) {
        textLabel?.font = UIFont.systemFont(ofSize: fontSize)
        textLabel?.text = font.family
        fontOperation = Inkwell.shared.font(for: font, size: fontSize) { [weak self] uifont in
            self?.textLabel?.font = uifont
            self?.textLabel?.text = uifont?.fontName
        }
    }
}
