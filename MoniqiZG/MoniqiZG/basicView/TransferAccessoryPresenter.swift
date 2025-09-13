//
//  InputBoxView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/28.
//

import UIKit
import SnapKit

/// 弹框 view（包含内部 UITextView、占位、标签流式布局、取消/确定）
class TransferAccessoryView: UIView {

    // MARK: - Public callbacks
    var onConfirm: ((String) -> Void)?
    var onCancel: (() -> Void)?

    // MARK: - UI
    private(set) var textView: UITextView = UITextView()
    
    private let placeholderLabel: UILabel = {
        let l = creatLabel(CGRect.zero, "请填写转账附言，收款双方可见，若不填写默认为“转账”", fontRegular(16), fieldPlaceholderColor)
        l.numberOfLines = 0
        return l
    }()

    private var cancelBtn: UIButton?
    
    private var confirmBtn: UIButton?
    
    private var tagContainer = UIView()
    
    private var tags: [String] = []

    // 固定高度（可按需调整或改成动态高度）
    static let defaultHeight: CGFloat = 270

    // MARK: - Init
    init(tags: [String], initialText: String? = nil) {
        self.tags = tags
        super.init(frame: .zero)
        setupUI()
        textView.text = initialText
        updatePlaceholderVisibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white

        cancelBtn = creatButton(CGRect.zero, "取消", fontRegular(16), HXColor(0x808080), .white, self, #selector(cancelAction))
        
        confirmBtn = creatButton(CGRect.zero, "确定", fontRegular(16), HXColor(0x5995ef), .white, self, #selector(confirmAction))
        
        addSubview(cancelBtn!)
        addSubview(confirmBtn!)
        
        cancelBtn!.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(50)
            make.width.equalTo(70)
        }
        
        confirmBtn!.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(50)
            make.width.equalTo(70)
        }

        let bgView = UIView()
        bgView.backgroundColor = .white
        addSubview(bgView)
        
        bgView.snp.makeConstraints { make in
            make.top.equalTo(cancelBtn!.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(80)
        }
        
        // textView (内部可编辑区域)
        textView.font = fontRegular(14)
        textView.isScrollEnabled = true
        textView.delegate = self
        textView.backgroundColor = .white
        textView.textColor = Main_TextColor
        bgView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(15)
        }

        // placeholder inside textView
        bgView.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.left.right.equalToSuperview().inset(18)
        }

        // tag container (flow)
        addSubview(tagContainer)
        tagContainer.snp.makeConstraints { make in
            make.top.equalTo(bgView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(15)
        }
        //51  *  2 + 15
        // add tags as buttons
        let columns = 3
        let spacing: CGFloat = 15
        let tagHeight: CGFloat = 36
        
        let totalSpacing = spacing * CGFloat(columns - 1)
        let tagWidth = (SCREEN_WDITH - 30 - totalSpacing) / CGFloat(columns)
        
        for (index,tag) in tags.enumerated() {
            let btn = creatButton(CGRect.zero, tag, fontRegular(15), Main_TextColor, HXColor(0xf7f7f7), self, #selector(tagTapped(_:)))
            tagContainer.addSubview(btn)
            
            ViewRadius(btn, tagHeight/2.0)
            
            let row = index / columns
            let col = index % columns
            
            btn.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(CGFloat(row) * (tagHeight + spacing))
                make.left.equalToSuperview().offset(CGFloat(col) * (tagWidth + spacing))
                make.width.equalTo(tagWidth)
                make.height.equalTo(tagHeight)
            }
        }
        
        ViewBorderRadius(bgView, 4, 1, HXColor(0xeeeeee))

        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChangeNotification(_:)), name: UITextView.textDidChangeNotification, object: textView)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Actions
    @objc private func cancelAction() {
        onCancel?()
    }

    @objc private func confirmAction() {
        onConfirm?(textView.text ?? "")
    }

    @objc private func tagTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        insertTextAtCursor(title)
        updatePlaceholderVisibility()
    }

    // allow outside to set text programmatically
    func setText(_ text: String?) {
        textView.text = text
        updatePlaceholderVisibility()
    }

    private func insertTextAtCursor(_ str: String) {
        // insert at selectedRange
        if let selectedRange = textView.selectedTextRange {
            textView.replace(selectedRange, withText: str)
        } else {
            textView.text.append(str)
        }
        // move cursor to end of inserted text: already done by replace
        // ensure delegate methods run
        updatePlaceholderVisibility()
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !(textView.text ?? "").isEmpty
    }

    @objc private func textViewDidChangeNotification(_ n: Notification) {
        updatePlaceholderVisibility()
    }
}

extension TransferAccessoryView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
}

// MARK: - 提醒输入框
/// 管理 TransferAccessoryView 的弹出（把 view 加到 window 上并根据键盘高度定位）
class TransferAccessoryPresenter {

    static let shared = TransferAccessoryPresenter()

    private init() {}

    private weak var accessory: TransferAccessoryView?
    private weak var hostResponder: UIResponder?
    private var bottomConstraint: Constraint?

    // 弹出 API：
    // - hostResponder: 被替换/回填的外部输入框（UITextField/UITextView），presenter 会在 confirm 时把文本回传给它。
    // - tags: 标签数组
    // - initialText: 初始文本（例如外部输入框当前的文本）
    func present(from hostResponder: UIResponder,
                 tags: [String],
                 initialText: String?,
                 onConfirm: ((String) -> Void)? = nil,
                 onCancel: (() -> Void)? = nil) {

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        // 如果已有 accessory 则先移除
        dismiss {}

        self.hostResponder = hostResponder

        let bg:UIView = UIView()
        bg.backgroundColor = .black.withAlphaComponent(0.2)
        window.addSubview(bg)
        
        bg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let v = TransferAccessoryView(tags: tags, initialText: initialText)
        setRadius(v, 10, [.layerMinXMinYCorner, .layerMaxXMinYCorner])

        v.onConfirm = { [weak self] text in
            onConfirm?(text)
            self?.dismiss()
        }
        v.onCancel = { [weak self] in
            onCancel?()
            self?.dismiss()
        }
        bg.addSubview(v)
        
        
        let h = TransferAccessoryView.defaultHeight
        v.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(h)
            // 初始放到屏幕下方（offset = h）
            self.bottomConstraint = make.bottom.equalTo(window.snp.bottom).offset(h).constraint
        }
        window.layoutIfNeeded()

        accessory = v

        // 监听键盘弹起以便把 accessory 顶到键盘上方
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        // 让 hostResponder 先失去第一响应者（如果它是 responder），然后让 accessory 内部的 textView 成为第一响应者，这样键盘的输入进入 accessory 的 textView
        if (hostResponder as? UIResponder) != nil {
            (hostResponder as? UIView)?.endEditing(true)
        }
        // give a tiny delay to ensure keyboard will come up correctly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            v.textView.becomeFirstResponder()
        }
    }

    @objc private func keyboardWillChangeFrame(_ n: Notification) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let userInfo = n.userInfo,
              let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        let keyboardHeight = window.bounds.height - endFrame.origin.y

        bottomConstraint?.update(offset: -keyboardHeight)

        UIView.animate(withDuration: duration) {
            window.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let duration = (n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) else { return }
        // move accessory off screen
        bottomConstraint?.update(offset: TransferAccessoryView.defaultHeight)
        UIView.animate(withDuration: duration, animations: {
            window.layoutIfNeeded()
        }, completion: { _ in
            self.cleanup()
        })
    }

    /// 直接收回 accessory（可传 completion）
    func dismiss(_ completion: (() -> Void)? = nil) {
        guard let acc = accessory else {
            completion?()
            return
        }
        // resign first responder of internal textView -> triggers keyboard hide notification -> cleanup will run there
        acc.textView.resignFirstResponder()
        // schedule completion after small delay to allow keyboard hide animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            completion?()
        }
    }

    private func cleanup() {
        accessory?.superview?.removeFromSuperview()
        accessory = nil
        hostResponder = nil
        bottomConstraint = nil
        NotificationCenter.default.removeObserver(self)
    }
}
