//
//  SubTabController.swift
//  ning
//
//  Created by JianjiaYu on 2020/9/1.
//  Copyright © 2020 tuicool. All rights reserved.
//

import UIKit

class NingArticleListController: BaseListController {
    
    var items: ArticleList = ArticleList()
    var catId: Int = 0
    var listType: NingListType = .Hot
    private var _longGestureIndexPath: IndexPath?
    convenience init(_ catId: Int, listType: NingListType = .Hot) {
        self.init()
        self.catId = catId
        self.listType = listType
    }
    
    convenience init(listType: NingListType) {
        self.init(0,listType:listType)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (articleChanged) {
            articleChanged = false
            tableView.reloadData()
        }
    }
    
    override func buildTableView() -> UITableView {
        let tableView = super.buildTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: ArticleViewCell.self)
        return tableView
    }
    
    override func requestData(_ pn: Int,_ refresh: Bool = false) {
        var provider = ArticleApiLoadingProvider
        if items.count() > 0 || refresh{
            provider = ArticleApiProvider
        }
        if catId == 1 {
            provider.request(ArticleApi.rec(pn: pn),
                model: ArticleList.self) { [weak self] (returnData) in
                self?.callbackResult(returnData,pn:pn)
            }
        } else {
            provider.request(ArticleApi.hot(catId: catId, pn: pn),
                model: ArticleList.self) { [weak self] (returnData) in
                    self?.callbackResult(returnData,pn:pn)
            }
        }
    }
    
    open func callbackResult(_ returnData:ArticleList?, pn:Int) {
        self.tableView.uHead.endRefreshing()
        self.tableView.uFoot.endRefreshing()
        if !showErrorResultToast(returnData) {
            if self.items.count() == 0 {
                self.tableView.uempty?.allowShow = true
                logInfo("show empty tableview")
            }
            return
        }
        returnData?.rebuild()
        self.pn = pn
        if pn == 0 {
            self.items.items.removeAll()
        }
        self.items.items.append(contentsOf: returnData?.items ?? [])
        if self.items.count() == 0 {
            self.tableView.uempty?.allowShow = true
        } else {
            self.tableView.uempty?.allowShow = false
        }
        self.tableView.reloadData()
        self.items.has_next = returnData?.has_next ?? false
        if self.items.has_next {
            self.tableView.uFoot.isHidden = false
        } else {
            showNoMoreFooter(returnData?.next_tip)
        }
        self.postCallbackResult(returnData!)
    }
    
    open func postCallbackResult(_ items: ArticleList) {
        
    }


}

extension NingArticleListController : UITableViewDelegate, UITableViewDataSource {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ArticleViewCell.self)
        cell.model = items[indexPath.row]
        //添加长按手势
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(cellLongPress)))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = NingArticleDetailController(items[indexPath.row]!)
        pushViewController(vc)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    // MARK: - 长按取消待读
    @objc func cellLongPress(_ recognizer:UIGestureRecognizer) {
        guard self.title == "我的待读" else {
            return
        }
        guard recognizer.state == .began  else {
            return
        }
        let location = recognizer.location(in: self.tableView)
        _longGestureIndexPath = self.tableView.indexPathForRow(at: location)
        guard let cell = recognizer.view as? ArticleViewCell else {
            return
        }
        //这里把cell做为第一响应(cell默认是无法成为responder,需要重写canBecomeFirstResponder方法)
        cell.becomeFirstResponder()
        
        let menuController = UIMenuController.shared
        
        //控制箭头方向
        menuController.arrowDirection = .default;
        //自定义事件
        let cancel = UIMenuItem(title: "取消待读", action: #selector(test2))
        
        menuController.menuItems = [cancel]
        menuController.showMenu(from: self.tableView, rect: cell.frame)
    }
    @objc func test2() {
        
        guard let idx = _longGestureIndexPath?.row, let article = items[idx] else {
            return
        }
        
        ArticleApiLoadingProvider.request(ArticleApi.cancelLate(id: article.id),
                                          model: BaseObject.self) { [weak self] (result) in
            
            if let rst = result, !rst.isSuccess() {
                self?.makeToast(result?.error ?? "未知错误")
            }
            else if result == nil {
                self?.makeToast("系统错误")
            }
            else {
                self?.items.remove(at: idx)
                self?.tableView.deleteRows(at: [IndexPath(row: idx, section: 0)], with: .fade)
            }
            
        }
    }
}

