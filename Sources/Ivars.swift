//
// Copyright (c) 2025 Nightwind
//

import Foundation

internal struct Ivars {
	static func getIvar<T>(target: AnyObject, name: String, type: T.Type) -> T? {
		guard let cls = object_getClass(target) else { return nil }
		guard let ivar = class_getInstanceVariable(cls, name) else { return nil }

		let offset = ivar_getOffset(ivar)

		let instancePtr = Unmanaged.passUnretained(target).toOpaque()
		let ivarPtr = instancePtr.advanced(by: offset)

		return ivarPtr.assumingMemoryBound(to: type).pointee
	}
}