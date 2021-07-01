//
//  FavArticleListController.swift
//  ning
//
//  Created by JianjiaYu on 2020/9/7.
//  Copyright © 2020 tuicool. All rights reserved.
//

import UIKit

class FavArticleListController: NingArticleListController {
    
    static func build(catId: Int = 0) -> FavArticleListController {
        return FavArticleListController(catId, listType: .Fav)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的收藏"
        
        // 全部需要同步其他列表的取消收藏
        NotificationCenter.default.addObserver(self, selector: #selector(cancelMyFavoriteArticleNotice), name: NSNotification.Name(rawValue: "k_cancel_favorite_article_notice"), object: nil)
    }
    
    override func requestData(_ pn: Int,_ refresh: Bool = false) {
        var provider = ArticleApiLoadingProvider
        if items.count() > 0 || refresh{
            provider = ArticleApiProvider
        }
        provider.request(ArticleApi.fav(kanId: catId, pn: pn),
            model: ArticleList.self) { [weak self] (returnData) in
            self?.callbackResult(returnData,pn:pn)
        }
    }
    
    @objc func cancelMyFavoriteArticleNotice(_ note: NSNotification) {
        guard let articleId = note.object as? String else {
            return
        }
        if let findIdx = items.items.firstIndex(where: { (obj) -> Bool in
            return obj.id == articleId
        }) {
            items.remove(at: findIdx)
            tableView.deleteRows(at: [IndexPath(row: findIdx, section: 0)], with: .fade)
        }
    }
}
