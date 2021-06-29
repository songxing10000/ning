//
//  ArticleDetailController.swift
//  ning
//
//  Created by JianjiaYu on 2020/9/5.
//  Copyright © 2020 tuicool. All rights reserved.
//

import UIKit
import WebKit
import DropDown
import SKPhotoBrowser
class NingArticleDetailController: BaseViewController {
    
    var article: Article?
    
    var dropDown: DropDown?
    
    var articleWrapper: ArticleWrapper?
    
    var handler: ArticleDetailOpHandler?
    private var imgUrlStrs = [String]()
    private var photos = [SKPhoto]()
    private var webView: WKWebView = {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = false
        webView.isMultipleTouchEnabled = false
        return webView
    }()
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.trackImage = UIColor.theme.image()
        progressView.progressTintColor = UIColor.white
        return progressView
    }()
    
    // 构造器
    convenience init(_ article: Article) {
        self.init()
        self.article = article
        handler = ArticleDetailOpHandler(self)
    }
    
    override func setupLayout() {
        view.addSubview(webView)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.snp.makeConstraints{ $0.edges.equalTo(self.view.usnp.edges) }
        
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(2)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "正文"
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        loadData()
        buildTopBarRightImageBtn("nav_more")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if favArticleDone {
            favArticleDone = false
            showToast("收藏成功")
        }
    }
    
    
    @objc override func onClickTopBarRightBtn() {
        var array = ["查看原文"]
        if let _ = articleWrapper?.site?.id {
             array.append("查看站点")
        }
        if article?.like == 1 {
            array.append("取消收藏")
        } else {
            array.append("收藏文章")
        }
        if article?.late == 1 {
            array.append("取消待读")
        } else {
            array.append("添加待读")
        }
        dropDown = buildRightDropDown(array)
    }
    
    override func handleRightDropDownItem(index: Int, item: String) {
        self.handler?.clickRightBtnOption(item)
    }
    
    func loadData() {
        ArticleApiProvider.request(ArticleApi.detail(id: article?.id ?? ""),
            model: ArticleWrapper.self) { [weak self] (returnData) in
            self?.handleResultData(returnData)
        }
    }
    
    func handleResultData(_ returnData: ArticleWrapper?) {
        if returnData == nil {
            return
        }
        if !returnData!.isSuccess() {
            return
        }
        self.articleWrapper = returnData
        self.article = returnData?.article
        self.showArticle()
        DAOFactory.articleReadDAO.save(article!.id)
    }
    
    func showArticle() {
        let html = ArticleDetailHelper.buildHtml(article!)
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
}

extension NingArticleDetailController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let requestString = navigationAction.request.url?.absoluteString
        print(requestString!)
        if  (requestString?.hasPrefix("image-preview"))!{
            let imgUrl = NSString.init(string: requestString!).substring(from: "image-preview:".count )
            let index = imgUrlStrs.indexes(of: imgUrl)
            let browser = SKPhotoBrowser(photos: photos)
            if let fObj = index.first {
                browser.initializePageIndex(fObj)
                present(browser, animated: true, completion: {})
            }
        }
        decisionHandler(.allow)  //一定要加上这句话
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            progressView.isHidden = webView.estimatedProgress >= 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        progressView.setProgress(0.0, animated: false)
        navigationItem.title = title ?? (webView.title ?? webView.url?.host)
        
        let jsGetImages =
            "function getImages(){" +
            "var objs = document.getElementsByTagName(\"img\");" +
            "var imgScr = '';" +
            "for(var i=0;i<objs.length;i++){" +
            "imgScr = imgScr + objs[i].src + '+';" +
            "};" +
            "return imgScr;" +
            "};"

        webView.evaluateJavaScript(jsGetImages, completionHandler: nil)
        webView.evaluateJavaScript("getImages()") { (data, err) in
            let imageUrl:String = data as! String
            var urlArry = imageUrl.components(separatedBy: "+")
            urlArry.removeLast()
            self.imgUrlStrs.append(contentsOf: urlArry)
            for urlStr in self.imgUrlStrs{
                let photo = SKPhoto.photoWithImageURL(urlStr)
                photo.shouldCachePhotoURLImage = true
                self.photos.append(photo)
            }
        }
        var jsClickImage:String
        jsClickImage =
            "function registerImageClickAction(){" +
            "var imgs=document.getElementsByTagName('img');" +
            "var length=imgs.length;" +
            "for(var i=0;i<length;i++){" +
            "img=imgs[i];" +
            "img.onclick=function(){" +
            "window.location.href='image-preview:'+this.src}" +
            "}" +
            "}"
        webView.evaluateJavaScript(jsClickImage, completionHandler: nil)
        webView.evaluateJavaScript("registerImageClickAction()", completionHandler: nil)
    }
}

