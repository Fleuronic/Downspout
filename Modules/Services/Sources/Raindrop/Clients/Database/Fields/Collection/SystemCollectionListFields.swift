// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Collection
import struct Dewdrop.Group
import struct Catena.IDFields
import protocol Catenoid.Fields
import protocol DewdropService.CollectionFields

public struct SystemCollectionListFields: Fields {
	public let id: Collection.ID
	public let title: String
	public let count: Int

	// MARK: ModelProjection
	public static let projection = Projection<Model, Self>(
		Self.init,
		\.id,
		\.value.title,
		\.value.count
	)
}

// MARK
extension SystemCollectionListFields: CollectionFields {
	// MARK: Fields
	public typealias Model = Collection.Identified
}
