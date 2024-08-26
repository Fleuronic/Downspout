// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB
import DewdropDatabase

import struct Raindrop.Tagging
import struct DewdropService.Tagging
import protocol Catenoid.Model

extension Raindrop.Tagging: Catenoid.Model {
	public typealias ID = DewdropService.Tagging.ID

	public var valueSet: ValueSet<DewdropService.Tagging> {
		[
			\.id == id,
			\.tagName == tagName,
			\.raindrop == raindropID
		]
	}
}
