//
// Copyright (c) 2025 Nightwind
//

import UIKit
import CydiaSubstrate

/* Private declarations */

@objc private protocol UIImageAssetPrivate {
	@objc var assetName: String? { get set }
}

@objc private protocol SymbolButton {
	@objc var isHidden: Bool {
		@objc(isHidden) get
		@objc(setHidden:) set
	}
	@objc var accessibilityImageView: UIImageView? { get }
}

@objc private protocol SongCell {
	@objc var contextMenuButton: SymbolButton? { get }
	@objc var libraryStatusControl: SymbolButton? { get }
}

/* Hooks */

private struct Hooks {
    static func hook() {
		guard let targetClass = objc_getClass("MusicApplication.SongCell") as? AnyClass else { return }

		var origIMP: IMP?
		let hook: @convention (block) (UICollectionViewCell, Selector) -> Void = { target, selector in
			let orig = unsafeBitCast(origIMP, to: (@convention (c) (UICollectionViewCell, Selector) -> Void).self)
			orig(target, selector)

			let songCell = unsafeBitCast(target, to: SongCell.self)

			// Get the asset name of libraryStatusControl
			guard
				let libraryStatusControl = songCell.libraryStatusControl,
				let imageView = libraryStatusControl.accessibilityImageView,
				let image = imageView.image,
				let imageAsset = image.imageAsset,
				let assetName = unsafeBitCast(imageAsset, to: UIImageAssetPrivate.self).assetName
			else { return }

			// If the asset name is "arrow.down.circle.fill", then we're dealing with a downloaded song
			guard assetName == "arrow.down.circle.fill" else { return }

			guard let contextMenuButton = songCell.contextMenuButton else { return }

			// Hide the download and context menu buttons
			libraryStatusControl.isHidden = true
			contextMenuButton.isHidden = true

			guard let textStackView = Ivars.getIvar(target: target, name: "textStackView", type: UIView.self) else { return }

			// Adjust the text stack frame to cover available space
			textStackView.frame = CGRect(
				x: textStackView.frame.origin.x,
				y: textStackView.frame.origin.y,
				width: target.frame.size.width - textStackView.frame.origin.x - 20,
				height: target.frame.size.height
			)
		}

		MSHookMessageEx(targetClass, sel_getUid("layoutSubviews"), imp_implementationWithBlock(hook), &origIMP)
	}
}

@_cdecl("swift_init")
func tweakInit() {
    Hooks.hook()
}