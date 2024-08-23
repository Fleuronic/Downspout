// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Tag
import struct Catena.IDFields
import protocol Catenoid.Fields
import protocol DewdropService.TagFields

struct TagListFields: TagFields {
	let name: String
	let count: Int
}

// MARK
extension TagListFields: Fields {
	// MARK: ModelProjection
	var id: Tag.ID { .init(rawValue: name) }

	// MARK: ModelProjection
	static let projection = Projection<Self.Model, Self>(
		Self.init,
		\.id,
		\.value.count
	)
}

// MARK: -
private extension TagListFields {
	@Sendable private init(
		id: Tag.ID,
		count: Int
	) {
		self.count = count

		name = id.rawValue
	}
}
