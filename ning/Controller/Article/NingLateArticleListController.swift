//
//  LateArticleListController.swift
//  ning
//
//  Created by JianjiaYu on 2020/9/7.
//  Copyright © 2020 tuicool. All rights reserved.
//

import UIKit

class NingLateArticleListController: NingArticleListController {

    static func build() -> NingLateArticleListController {
        return NingLateArticleListController(listType: .Late)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的待读"
    }
    
    override open func requestData(_ pn: Int,_ refresh: Bool = false) {
        ArticleApiProvider.request(ArticleApi.late(pn: pn),
            model: ArticleList.self) { [weak self] (returnData) in
            self?.callbackResult(returnData,pn:pn)
        }
    }
    // MARK: - 添加左滑取消待读，这样就不用再进去文章详情进行取消待读操作了
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let article = self.items[indexPath.row] else {
            return nil
        }
        let opAction = UIContextualAction(style: .normal, title: "取消待读"){ (action, view, headler) in
            ArticleApiLoadingProvider.request(ArticleApi.cancelLate(id: article.id),
                                              model: BaseObject.self) { [weak self] (result) in
                
                if let rst = result, !rst.isSuccess() {
                    self?.makeToast(result?.error ?? "未知错误")
                    headler(false)
                }
                else if result == nil {
                    self?.makeToast("系统错误")
                    headler(false)
                }
                else {
                    self?.items.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                
            }
            headler(true)
        }
        opAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [opAction])
    }
}
