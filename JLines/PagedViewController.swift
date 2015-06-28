//
//  PagedViewController.swift
//  JLinesV1
//
//  Created by Jozsef Romhanyi on 16.02.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit



class PagedViewController: UIViewController, UIScrollViewDelegate {

    
    var scrollView = MyScrollView()
    let delete = false
    var pageControl = UIPageControl()
    
    var backButton = UIButton()
    var packageName: String?
    //var package: Package?
    
    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []

    let multiplicator = 0.8
    
    var gameName: String?
    var Gap: CGFloat = 0
    var rectSize: CGFloat = 0
    var vOrigin: CGPoint = CGPoint(x: 0, y: 0)
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var goWhenEnd: ()->()
    
    init(packageName: String, callBack: ()->()) {
        goWhenEnd = callBack
        self.packageName = packageName
        
        super.init(nibName: nil, bundle: nil)
        
        
        //GV.language.callBackWhenNewLanguage(self.updateLanguage)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        GV.language.callBackWhenNewLanguage(self.updateLanguage)

        scrollView = MyScrollView(frame: self.view.bounds)
        scrollView.backgroundColor = UIColor.whiteColor()
        scrollView.parent = self
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.layer.name = GV.scrollViewName
        
        //GV.horNormWert = self.view.frame.width / 40
        //GV.vertNormWert = self.view.frame.height / 40
        
        view.addSubview(scrollView)
        
        
        //back.frame = CGRect(x: GV.horNormWert * 36, y: GV.vertNormWert * 1, width: GV.horNormWert * 2, height: GV.horNormWert * 2)
        backButton.setImage(GV.images.getBack(), forState: .Normal)
        //back.backgroundColor = UIColor.blackColor()
        backButton.addTarget(self, action: "backAction:", forControlEvents: UIControlEvents.TouchUpInside)

        view.addSubview(backButton)
        
        GV.package = Package(packageName: packageName!)
        
        
        //reloadView()
        
        removeLayers()
        //pageViews.removeAll(keepCapacity: true)
        let pageCount = GV.maxVolumeNr
        //if delete {GV.dataStore.deleteAllRecords()}
        GV.gameData = GV.dataStore.getDataArray()
        GV.appData = GV.dataStore.getAppVariablesData()
        GV.gameControll = GameControll(rawValue: Int(GV.appData.gameControll))!
        GV.colorSetIndex = Int(GV.appData.farbSchemaIndex)
        let myGame = GV.gameData
        GV.dataStore.printRecords()
        
        
        generateVolumePageImages(pageCount)
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount
        
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * CGFloat(pageImages.count), pagesScrollViewSize.height)
        
        
        
        loadVisiblePages()
        
        setupLayout()
        setLayers()
        
    }
    
    
    func backAction(sender:UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func loadPage(page: Int) {
        
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // 1
        if let pageView = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            // 2
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            // 3
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
            scrollView.page = page
            
            // 4
            pageViews[page] = newPageView
        }
    }
    
    func purgePage(page: Int) {
        
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
        
    }
    
    func loadVisiblePages() {
        
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for var index = firstPage; index <= lastPage; ++index {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
        
        
    }
    
    func generateVolumePageImages(pageCount: Int) {

        let multiplicator: CGFloat = 0.99
        
        let size = self.view.bounds.size
        let origin = self.view.bounds.origin
        let vSizeWidth:CGFloat = size.width * multiplicator
        let Gap: CGFloat = vSizeWidth / CGFloat(30)
        
        GV.rectSize = (vSizeWidth - (CGFloat(GV.TableNumColumns) + 1) * Gap) / CGFloat(GV.TableNumColumns)
        
        let vSize = CGSizeMake( (GV.rectSize + Gap) * CGFloat(GV.TableNumColumns) + Gap,
            (GV.rectSize + Gap) * CGFloat(GV.TableNumRows) + Gap)
        let vOrigin = CGPointMake((size.width - vSize.width) / 2, (size.height - vSize.height) / 3)
        
        GV.vBounds = CGRectMake(vOrigin.x, vOrigin.y, vSize.width, vSize.height)
        
        let image = drawCustomImage()
        
        for pageNr in 0..<pageCount {
            //gameName = (GV.package?.getVolumeName(pageNr) as! String)
            GV.maxGameNr = GV.package!.getMaxNumber(pageNr)

            let nameLabel = UILabel()
            nameLabel.text = GV.language.getText(GV.package?.getVolumeName(pageNr) as! String)
            nameLabel.textColor = UIColor.blueColor()
            nameLabel.layer.name = GV.volumeName[pageNr]
            nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 0.4 * rectSize)
            //nameLabel.text = (GV.package?.getVolumeName(pageNr) as! String)
            nameLabel.frame = CGRect(x: vOrigin.x + GV.rectSize * 0.25 + CGFloat(pageNr) *  size.width, y: vOrigin.y - 0.4 * rectSize, width: 500, height: GV.rectSize * 1.2)
            scrollView.addSubview(nameLabel)
            pageImages.append(image)
            makeLayers(pageNr)
        }
    }
    
    func makeLayers(pageNr: Int) {
        for column in 0..<GV.TableNumColumns {
            for row in 0..<GV.TableNumRows {
                
                let x = vOrigin.x + Gap + CGFloat(column) * (rectSize + Gap)
                let y = vOrigin.y + Gap + CGFloat(row) * (rectSize + Gap)
                let gameNr = row * GV.TableNumColumns + column
                
                let adder = self.view.frame.size.width * CGFloat(pageNr)
                
                let layerRect = CGRect(x: x + adder, y: y, width: rectSize, height: rectSize)
                
                if gameNr < GV.maxGameNr {
                                        
                    let lineCount = GV.package?.getLineCount(pageNr, numberIn: gameNr)
                    let countMoves = GV.gameData.volumes[pageNr].games[gameNr].countMoves
                    let countLines = GV.gameData.volumes[pageNr].games[gameNr].countLines
                    
                    //println("layerRect: \(layerRect), pageNr: \(pageNr), gameNr: \(gameNr)")
                    GV.gameData.volumes[pageNr].games[gameNr].layer.frame = layerRect
                    
                    var color: CGColor
                    switch countMoves {
                        case 0:             color = UIColor.clearColor().CGColor
                        case countLines:    color = UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 0.1).CGColor
                        case countLines + 1 ... countLines + 1000:
                                            color = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.1).CGColor
                        default:            color = UIColor.clearColor().CGColor
                    }
                    
                    GV.gameData.volumes[pageNr].games[gameNr].layer.backgroundColor = color
                    
                }
            }
        }
    }

    func drawCustomImage() -> UIImage {
        // Setup our context
        let maxNumber = GV.package!.getMaxNumber(0)
        let opaque = false
        let scale: CGFloat = 0
        let multiplicator: CGFloat = 0.9
        
        let size = self.view.bounds.size
        let origin = self.view.bounds.origin
        let vSizeWidth:CGFloat = size.width * multiplicator
        Gap = vSizeWidth / CGFloat(30)
        rectSize = (vSizeWidth - (CGFloat(GV.TableNumColumns) + 1) * Gap) / CGFloat(GV.TableNumColumns)
        let vSize = CGSizeMake( (rectSize + Gap) * CGFloat(GV.TableNumColumns) + Gap,
                                (rectSize + Gap) * CGFloat(GV.TableNumRows) + Gap)
        vOrigin = CGPointMake((size.width - vSize.width) / 2, (size.height - vSize.height) / 2)
        
        let vBounds = CGRectMake(vOrigin.x, vOrigin.y, vSize.width, vSize.height)
        
        GV.vBounds = vBounds
        
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Center
        let fontSize = rectSize / 2
        let font = UIFont.boldSystemFontOfSize(fontSize) //   preferredFontForTextStyle(UIFontTextStyleHeadline)
        let textColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1)
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup complete, do drawing here
        CGContextSetLineWidth(context, 2.0)

        
        CGContextSetStrokeColorWithColor(context, UIColor.blueColor().CGColor)
        CGContextStrokeRect(context, vBounds)

        CGContextBeginPath(context)
        
        for column in 0..<GV.TableNumColumns {
            for row in 0..<GV.TableNumRows {
                
                let x = vOrigin.x + Gap + CGFloat(column) * (rectSize + Gap)
                let y = vOrigin.y + Gap + CGFloat(row) * (rectSize + Gap)
                let gameNr = row * GV.TableNumColumns + column
                
                let Nr = row * GV.TableNumColumns + column + 1
                
                let rectText = CGRect(x: x, y: y + rectSize / 5, width: rectSize, height: rectSize)
                let rect = CGRect(x: x, y: y, width:  rectSize, height: rectSize)

                CGContextStrokeRect(context, rect)
                let stringNr = Nr.description
                stringNr.drawInRect(rectText, withAttributes: textFontAttributes)
            }
        }
       
        CGContextStrokePath(context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return (image)
    }

    func callSegue(game:Game) {
        self.view.addSubview(game)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLayers () {
        let myGame = GV.gameData
        GV.sublayer = CALayer()
        GV.sublayer.frame = scrollView.layer.frame
        scrollView.layer.addSublayer(GV.sublayer)
        for pageIndex in 0..<GV.maxVolumeNr {
            for gameIndex in 0..<GV.package!.getMaxNumber(pageIndex) {
                GV.sublayer.addSublayer(GV.gameData.volumes[pageIndex].games[gameIndex].layer)
            }
        }

    }
    
    func removeLayers() {
        GV.sublayer.removeFromSuperlayer()
        //GV.sublayer = CALayer()
    }
    
    func updateLayers () {
        removeLayers()
        setLayers()
        //scrollView.setNeedsDisplay()
        
    }
    
    func printGameArray() {
        
    }
    func updateLanguage() {
        for (ind, subview) in enumerate(scrollView.subviews) {
            if subview.layer.name != nil {
                let name = subview.layer.name
                //println("subViewName: \(name)")
                (subview as! UILabel).text = GV.language.getText(name)
            }
        }
        //languageButton.setTitle(GV.language.getText("language"), forState: .Normal)
    }

    
    func setupLayout() {
        var constraintsArray = Array<NSObject>()
        backButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // backButton
        constraintsArray.append(NSLayoutConstraint(item: backButton, attribute: NSLayoutAttribute.Right, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -10.0))
        
        constraintsArray.append(NSLayoutConstraint(item: backButton, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 20.0))
        
        constraintsArray.append(NSLayoutConstraint(item: backButton, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.05, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: backButton, attribute: .Height , relatedBy: .Equal, toItem: backButton, attribute: .Width, multiplier: 1.0, constant: 0.0))
        
        
        self.view.addConstraints(constraintsArray)
    }


}
