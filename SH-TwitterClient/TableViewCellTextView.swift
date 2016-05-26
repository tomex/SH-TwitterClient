//
//  TableViewCellTextView.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/20.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit

class TableViewCellTextView: UITextView {
    // http://qiita.com/fmtonakai/items/669fe461fd9673dc8e50
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var p = point
        p.y -= self.textContainerInset.top
        p.x -= self.textContainerInset.left
        
        let i = self.layoutManager.characterIndexForPoint(p, inTextContainer: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        var effectiveRange = NSRange()
        let attr = self.textStorage.attributesAtIndex(i, effectiveRange:  &effectiveRange)
        if (attr[NSLinkAttributeName] != nil) {
            var touchingLink = false
            let glyphIndex = self.layoutManager.glyphIndexForCharacterAtIndex(i)
            self.layoutManager.enumerateLineFragmentsForGlyphRange(NSMakeRange(glyphIndex, 1), usingBlock: {
                rect,usedRect,textContainer,glyphRange,stop in
                if CGRectContainsPoint(usedRect, p){
                    touchingLink = true
                }
            })
            return (touchingLink) ? self : nil
        }
        return nil
    }
}
