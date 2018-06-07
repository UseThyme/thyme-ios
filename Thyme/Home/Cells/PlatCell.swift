import UIKit

open class PlateCell: UICollectionViewCell {
    open lazy var timerControl: TimerControl = { [unowned self] in
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let timerControl = TimerControl(frame: frame, completedMode: false)

        timerControl.isUserInteractionEnabled = false
        timerControl.backgroundColor = UIColor.clear

        return timerControl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(timerControl)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
