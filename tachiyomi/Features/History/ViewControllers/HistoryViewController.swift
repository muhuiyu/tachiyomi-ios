//
//  HistoryViewController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit

class HistoryViewController: Base.MVVMViewController<HistoryViewModel> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

// mangaURL, chapterURL, date, mangatitle, manga delete
// Date (relative)
// ---------------
//       | title
// image |                      | deleteButton
//       | chapterName time
