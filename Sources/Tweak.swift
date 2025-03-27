//
// Copyright (c) 2025 Nightwind
//

import UIKit
import CydiaSubstrate

private struct Hooks {
    static func hook() {
		guard let targetClass = objc_getClass("MusicApplication.SongCell") as? AnyClass else { return }
		guard let symbolButtonClass = objc_getClass("MusicCoreUI.SymbolButton") as? AnyClass else { return }

		var origIMP: IMP?
		let hook: @convention (block) (UICollectionViewCell, Selector) -> Void = { target, selector in
			let orig = unsafeBitCast(origIMP, to: (@convention (c) (UICollectionViewCell, Selector) -> Void).self)
			orig(target, selector)

			target.contentView.subviews.forEach { subview in
				if subview.isKind(of: symbolButtonClass) {
					subview.isHidden = true
				}
			}
		}

		MSHookMessageEx(targetClass, sel_getUid("layoutSubviews"), imp_implementationWithBlock(hook), &origIMP)
	}
}

@_cdecl("swift_init")
func tweakInit() {
    Hooks.hook()
}