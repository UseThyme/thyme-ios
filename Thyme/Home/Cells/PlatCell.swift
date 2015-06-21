import UIKit

public class PlateCell: UICollectionViewCell {

  public lazy var timerControl: TimerControl = {
    let frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
    let timerControl = TimerControl(frame: frame, completeMode: false)

    timerControl.userInteractionEnabled = false
    timerControl.backgroundColor = UIColor.clearColor()

    return timerControl
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.addSubview(self.timerControl)
  }

  public required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
