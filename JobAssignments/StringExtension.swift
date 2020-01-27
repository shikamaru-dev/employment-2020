//
//  StringExtension.swift
//  JobAssignments
//
//  Created by 曹 一凡 on 2019/10/29.
//  Copyright © 2019 曹 一凡. All rights reserved.
//

import Foundation
extension String {
    var localized: String {
        let lang = "ja"
        // lang からリソースのパスを取得して bundle を取得
        guard let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
            let bundle = Bundle(path: path) else {
                // bundle が取得できなかった場合は端末の言語設定を元に切り替える
                return NSLocalizedString(self, comment: "")
        }
        // 取得した bundle でキーを参照して切り替える
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
