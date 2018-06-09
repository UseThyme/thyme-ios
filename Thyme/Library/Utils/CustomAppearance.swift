import UIKit

struct CustomAppearance {
    static func apply() {
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor(hex: "D0E8E8")
        pageControl.currentPageIndicatorTintColor = UIColor(hex: "FF5C5C")
        pageControl.backgroundColor = UIColor(hex: "EDFFFF")
    }
}
