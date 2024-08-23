// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Filter
import protocol Catenoid.Fields
import protocol DewdropService.FilterFields

struct FilterListFields: FilterFields {
	let id: Filter.ID
	let sortIndex: Int
	let count: Int

	@Sendable private init(
		id: Filter.ID,
		sortIndex: Int,
		count: Int
	) {
		self.id = id
		self.sortIndex = sortIndex
		self.count = count
	}
}

// MARK
extension FilterListFields: Fields {
	// MARK: ModelProjection
	static let projection = Projection<Self.Model, Self>(
		Self.init,
		\.id,
		\.sortIndex,
		\.value.count
	)
}
