//
//  TypingLabel.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/2.
//
import UIKit

//多文本-逐字播放
class TypingCarouselLabel: UILabel {

    private var texts: [String] = []
    private var currentTextIndex = 0
    private var currentCharIndex = 0

    private var typingTimer: Timer?
    private var switchTimer: Timer?

    var typingInterval: TimeInterval = 0.06     // 每个字间隔
    var switchInterval: TimeInterval = 1.5      // 完成一段文本后停留时间
    var isLoop: Bool = true                     // 是否循环播放

    /// 开始轮播展示
    func startTyping(texts: [String]) {
        guard !texts.isEmpty else { return }
        self.texts = texts
        currentTextIndex = 0
        showCurrentText()
    }

    /// 停止所有动画
    func stopTyping() {
        typingTimer?.invalidate()
        switchTimer?.invalidate()
        typingTimer = nil
        switchTimer = nil
    }

    private func showCurrentText() {
        self.text = ""
        currentCharIndex = 0
        typingTimer?.invalidate()

        let currentText = texts[currentTextIndex]

        typingTimer = Timer.scheduledTimer(withTimeInterval: typingInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            if currentCharIndex < currentText.count {
                let index = currentText.index(currentText.startIndex, offsetBy: currentCharIndex + 1)
                self.text = String(currentText[..<index])
                currentCharIndex += 1
            } else {
                timer.invalidate()
                self.startSwitchTimer()
            }
        }
        RunLoop.current.add(typingTimer!, forMode: .common)
    }

    private func startSwitchTimer() {
        switchTimer?.invalidate()
        switchTimer = Timer.scheduledTimer(withTimeInterval: switchInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.currentTextIndex += 1
            if self.currentTextIndex >= self.texts.count {
                if isLoop {
                    self.currentTextIndex = 0
                } else {
                    return
                }
            }
            self.showCurrentText()
        }
        RunLoop.current.add(switchTimer!, forMode: .common)
    }

    deinit {
        stopTyping()
    }
}
