//
//  SORubberView.swift
//  SORubberView
//
//  Created by ahmad alsofi on 5/9/20.
//

import Foundation
public protocol SORubberViewDelegate: NSObject{
    func animationStatus(_ rubberViewSection: SORubberViewSection,viewStatus: SORubberViewStatus)
    func didSelectSection(_ rubberViewSection: SORubberViewSection,at section: Int)
}
@available(iOS 9.0, *)
public protocol SORubberViewDataSource: NSObject {
    var  collapsedHeight     : CGFloat {set get }
    var  expandableHeight    : CGFloat {set get}
    var  backgroundColor     : UIColor {set get }
    var  animateDurationTime : TimeInterval {set get}
    func numberOfSections(_ rubberView: SORubberView) -> Int
    func viewForSection(_ rubberView: SORubberView, section: Int) -> SORubberViewSection
}
public enum SORubberViewStatus {
    case expandable
    case collapsed
}
@available(iOS 9.0, *)
public class SORubberView: UIView {
    // MARK: - Properties
    public var viewStatus: SORubberViewStatus = .expandable
    public weak var delegate  : SORubberViewDelegate?
    public var rubberViewHeightConstraint: NSLayoutConstraint?
    public weak var dataSource: SORubberViewDataSource? {
        didSet {
            updateView()
        }
    }
    private var stacksLevelOne = [SORubberStackView]()
    private var stacksLevelTwo = [SORubberStackView]()
    private var initializeHeight: CGFloat = 0.0
    private var rubberViews    = [SORubberViewSection]()
    private var numberOfSection: Int = 0
    private var collapsedHeight : CGFloat {
        return dataSource?.collapsedHeight ?? 0.0
    }
    private var expandableHeight: CGFloat {
        return dataSource?.expandableHeight ?? 0.0
    }
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.clipsToBounds = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addBackground(color: dataSource?.backgroundColor ?? .clear)
        return stackView
    }()
}
@available(iOS 9.0, *)
extension SORubberView {
    // MARK: - Public Functions
    public func reloadView() {
        DispatchQueue.main.async {
            self.addSubview(self.mainStackView)
            // Constraint
            self.mainStackView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.mainStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            self.loadStacks()
        }
    }
    public func animate(_ status: SORubberViewStatus) {
        if self.viewStatus == status {return}
        if numberOfSection < 4 {return}
        UIView.animate(withDuration: self.dataSource?.animateDurationTime ?? 0.0) {
            if self.viewStatus == .expandable {
                self.viewStatus = .collapsed
                self.rubberViewHeightConstraint?.constant = self.collapsedHeight
                self.rubberViews.forEach {
                    self.delegate?.animationStatus($0, viewStatus: .collapsed)
                }
                if self.numberOfSection == 5 {
                    self.activeStackLevelOneConstraint(active: false)
                    self.stacksLevelOne[0].widthNSLayoutConstraint?.constant = (self.frame.width / 5) * 3
                    self.stacksLevelOne[1].widthNSLayoutConstraint?.constant = (self.frame.width / 5) * 2
                    self.mainStackView.axis = .horizontal
                } else {
                    self.stacksLevelOne.forEach {
                        $0.axis = .horizontal
                    }
                }
            } else if self.viewStatus == .collapsed {
                self.viewStatus = .expandable
                self.rubberViews.forEach {
                    self.delegate?.animationStatus($0, viewStatus: .expandable)
                }
                self.rubberViewHeightConstraint?.constant = self.expandableHeight
                if self.numberOfSection == 5 {
                    self.activeStackLevelOneConstraint(active: true)
                    self.mainStackView.axis = .vertical
                } else {
                    self.stacksLevelOne.forEach {
                        $0.axis = .vertical
                    }
                }
            }
            self.layoutIfNeeded()
        }
    }
}

@available(iOS 9.0, *)
extension SORubberView {
    // MARK: - Private Functions
    private func updateView() {
        numberOfSection = dataSource?.numberOfSections(self) ?? 0
    }
    private func loadStacks() {
        switch numberOfSection {
        case 1:
            oneSection()
        case 2:
            twoSection()
        case 3:
            threeSection()
        case 4:
            fourSection()
        case 5:
            fiveSection()
        case 6:
            sixSection()
        default:
            break
        }
        setGesture()
    }
    private func rubberViewByIndex(index: Int) -> SORubberViewSection {
        guard let rubberView = dataSource?.viewForSection(self, section: index) else {return SORubberViewSection()}
        return rubberView
    }
    private func drawStackLevelOneConstraint(stack: SORubberStackView) {
        DispatchQueue.main.async {
            stack.trailingNSLayoutConstraint = stack.trailingAnchor.constraint(equalTo: self.mainStackView.trailingAnchor)
            stack.leadingNSLayoutConstraint = stack.leadingAnchor.constraint(equalTo: self.mainStackView.leadingAnchor)
            let widthAnchor = stack.widthAnchor.constraint(equalToConstant: 0)
            widthAnchor.isActive = true
            stack.widthNSLayoutConstraint = widthAnchor
            self.activeStackLevelOneConstraint(active: true)
        }
    }
    private func initStackLevelTwo(rubberView: SORubberViewSection,stackLevelOne: SORubberStackView) {
        let stackLevelTwo = SORubberStackView(axis: .vertical,distribution: .fillEqually)
        stacksLevelTwo.append(stackLevelTwo)
        rubberViews.append(rubberView)
        stackLevelTwo.addArrangedSubview(rubberView)
        stackLevelOne.addArrangedSubview(stackLevelTwo)
        rubberView.soDrawConstraint(from: stackLevelTwo)
    }
    private func activeStackLevelOneConstraint(active: Bool) {
        self.stacksLevelOne.forEach {
            $0.trailingNSLayoutConstraint?.isActive = active
            $0.leadingNSLayoutConstraint?.isActive = active
        }
    }
    private func setGesture() {
        for (index,rubberView) in rubberViews.enumerated() {
            DispatchQueue.main.async {
                rubberView.isUserInteractionEnabled = true
                let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSection(_:)))
                gesture.numberOfTouchesRequired = 1
                rubberView.tag = index
                rubberView.isUserInteractionEnabled = true
                rubberView.addGestureRecognizer(gesture)
            }
        }
    }
    @IBAction private func handleSection(_ gesture: UITapGestureRecognizer) {
        guard let gestureView = gesture.view else {return}
        let temoObject = self.rubberViews[gestureView.tag]
        delegate?.didSelectSection(temoObject, at: gestureView.tag)
    }
}

@available(iOS 9.0, *)
extension SORubberView {
    // MARK: - Draw Section Functions
   private func oneSection() {
        self.rubberViewHeightConstraint?.constant = self.collapsedHeight
        let rubberView = self.rubberViewByIndex(index: 0)
        self.rubberViews.append(rubberView)
        self.mainStackView.addArrangedSubview(rubberView)
        self.mainStackView.alignment = .center
        self.mainStackView.distribution = .fill
        rubberView.translatesAutoresizingMaskIntoConstraints = false
        rubberView.centerXAnchor.constraint(equalTo: self.mainStackView.centerXAnchor).isActive = true
        rubberView.centerYAnchor.constraint(equalTo: self.mainStackView.centerYAnchor).isActive = true
    }
    private func twoSection() {
        self.rubberViewHeightConstraint?.constant = self.collapsedHeight
        let firstStack = SORubberStackView(axis: .horizontal, height: collapsedHeight, activeHeightConstraint: true, distribution: .fillEqually)
        stacksLevelOne.append(firstStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 0), stackLevelOne: firstStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 1), stackLevelOne: firstStack)
        self.mainStackView.addArrangedSubview(firstStack)
    }
    private func threeSection() {
        self.rubberViewHeightConstraint?.constant = self.collapsedHeight
        let firstStack = SORubberStackView(axis: .horizontal, height: collapsedHeight, activeHeightConstraint: true, distribution: .fillEqually)
        stacksLevelOne.append(firstStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 0), stackLevelOne: firstStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 1), stackLevelOne: firstStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 2), stackLevelOne: firstStack)
        self.mainStackView.addArrangedSubview(firstStack)
    }
    private func fourSection() {
        self.mainStackView.axis = .horizontal
        self.mainStackView.distribution = .fillEqually
        let firstStack = SORubberStackView(axis: .vertical, height: frame.height, activeHeightConstraint: true, distribution: .fillEqually)
        let secondStack = SORubberStackView(axis: .vertical, height: frame.height, activeHeightConstraint: true, distribution: .fillEqually)
        stacksLevelOne.append(firstStack)
        stacksLevelOne.append(secondStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 0), stackLevelOne: firstStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 1), stackLevelOne: firstStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 2), stackLevelOne: secondStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 3), stackLevelOne: secondStack)
        self.mainStackView.addArrangedSubview(firstStack)
        self.mainStackView.addArrangedSubview(secondStack)
    }
    private func fiveSection() {
        let firstStack = SORubberStackView(axis: .horizontal, height: frame.height / 2, activeHeightConstraint: true, distribution: .fillEqually)
        let secondStack = SORubberStackView(axis: .horizontal, height: frame.height / 2, activeHeightConstraint: true, distribution: .fillEqually)
        stacksLevelOne.append(firstStack)
        stacksLevelOne.append(secondStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 0), stackLevelOne: firstStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 1), stackLevelOne: firstStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 2), stackLevelOne: firstStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 3), stackLevelOne: secondStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 4), stackLevelOne: secondStack)
        self.mainStackView.addArrangedSubview(firstStack)
        self.mainStackView.addArrangedSubview(secondStack)
        drawStackLevelOneConstraint(stack: firstStack)
        drawStackLevelOneConstraint(stack: secondStack)
    }
    private func sixSection() {
        self.mainStackView.axis = .horizontal
        self.mainStackView.distribution = .fillEqually
        let firstStack = SORubberStackView(axis: .vertical, height: frame.height, activeHeightConstraint: true, distribution: .fillEqually)
        let secondStack = SORubberStackView(axis: .vertical, height: frame.height, activeHeightConstraint: true, distribution: .fillEqually)
        let thirdStack = SORubberStackView(axis: .vertical, height: frame.height, activeHeightConstraint: true, distribution: .fillEqually)
        stacksLevelOne.append(firstStack)
        stacksLevelOne.append(secondStack)
        stacksLevelOne.append(thirdStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 0), stackLevelOne: firstStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 1), stackLevelOne: firstStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 2), stackLevelOne: secondStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 3), stackLevelOne: secondStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 4), stackLevelOne: thirdStack)
        initStackLevelTwo(rubberView: rubberViewByIndex(index: 5), stackLevelOne: thirdStack)
        self.mainStackView.addArrangedSubview(firstStack)
        self.mainStackView.addArrangedSubview(secondStack)
        self.mainStackView.addArrangedSubview(thirdStack)
    }
}
