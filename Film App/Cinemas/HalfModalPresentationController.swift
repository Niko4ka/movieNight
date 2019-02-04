import UIKit

enum ModalScaleState {
    case adjustedOnce
    case normal
}

class HalfModalPresentationController: UIPresentationController {
    
    var isMaximized: Bool = false
    var state: ModalScaleState = .normal
    var panGestureRecognizer: UIPanGestureRecognizer
    var direction: CGFloat = 0
    var _dimmingView: UIView?
    var dimmingView: UIView {
        return configurateDimmingView()
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.panGestureRecognizer = UIPanGestureRecognizer()
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        panGestureRecognizer.addTarget(self, action: #selector(onPan(pan:)))
        presentedViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) {
        let endPoint = pan.translation(in: pan.view?.superview)
        
        switch pan.state {
        case .began:
            presentedView!.frame.size.height = containerView!.frame.height
        case .changed:
            let velocity = pan.velocity(in: pan.view?.superview)
            switch state {
            case .adjustedOnce:
                presentedView!.frame.origin.y = endPoint.y
            case .normal:
                presentedView!.frame.origin.y = endPoint.y + containerView!.frame.height / 2
            }
            direction = velocity.y
        case .ended:
            if direction < 0 {
                changeScale(to: .adjustedOnce)
            } else {
                if state == .adjustedOnce {
                    changeScale(to: .normal)
                } else {
                    presentedViewController.dismiss(animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
    
    
    func changeScale(to state: ModalScaleState) {
        
        if let presentedView = presentedView,
            let containerView = containerView {
            
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                
                presentedView.frame = containerView.frame
                let containerFrame = containerView.frame
                let halfFrame = CGRect(x: 0,
                                       y: containerFrame.height / 2,
                                       width: containerFrame.width,
                                       height: containerFrame.height / 2)
                let frame = state == .adjustedOnce ? containerView.frame : halfFrame
                presentedView.frame = frame
                self.isMaximized = true
                
            }) { _ in
                self.state = state
            }
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0,
                      y: containerView!.bounds.height / 2,
                      width: containerView!.bounds.width,
                      height: containerView!.bounds.height / 2)
    }
    
    override func presentationTransitionWillBegin() {
        let dimmedView = dimmingView
        
        if let containerView = containerView,
            let coordinator = presentingViewController.transitionCoordinator {
            dimmedView.alpha = 0
            containerView.addSubview(dimmedView)
            dimmedView.addSubview(presentedViewController.view)
            
            coordinator.animate(alongsideTransition: { _ in
                dimmedView.alpha = 1
                self.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
                self.presentingViewController.view.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
            _dimmingView = nil
            isMaximized = false
        }
    }
    
    private func configurateDimmingView() -> UIView {
        if let view = _dimmingView {
            return view
        }
        
        let viewFrame = CGRect(x: 0,
                               y: 0,
                               width: containerView!.bounds.width,
                               height: containerView!.bounds.height)
        let view = UIView(frame: viewFrame)
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 0.3
        view.addSubview(blurEffectView)
        
        _dimmingView = view
        return view
    }
    
}

protocol HalfModalPresentable { }

extension HalfModalPresentable where Self: UIViewController {
    func maximizeToFullScreen() {
        if let presentationController = presentationController as? HalfModalPresentationController {
            presentationController.changeScale(to: .adjustedOnce)
        }
    }
    
    func isHalfModalMaximized() -> Bool {
        if let presentationController = presentationController as? HalfModalPresentationController {
            return presentationController.isMaximized
        }
        return false
    }
}
