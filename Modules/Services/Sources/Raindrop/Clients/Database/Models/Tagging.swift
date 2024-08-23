// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB
import DewdropDatabase

import struct Raindrop.Tagging
import struct DewdropService.Tagging
import protocol Catenoid.Model

extension Raindrop.Tagging {

}

// MARK: -
public extension Raindrop.Tagging {
	typealias ID = DewdropService.Tagging.ID

	var valueSet: ValueSet<DewdropService.Tagging> {
		[
			\.id == id,
			\.tagName == tagName,
			\.raindrop == raindropID
		]
	}
}

// MARK: -
#if compiler(>=6.0)
extension Raindrop.Tagging: @retroactive Model {}
#else
extension Raindrop.Tagging: Model {}
#endif
