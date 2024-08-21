// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Collection
import protocol Catenoid.Fields
import protocol DewdropService.CollectionFields

public struct SystemCollectionListFields: CollectionFields {
	public let id: Collection.ID
	public let title: String
	public let count: Int
}

// MARK
extension SystemCollectionListFields: Fields {
	// MARK: ModelProjection
	public static let projection = Projection<Self.Model, Self>(
		Self.init,
		\.id,
		\.value.title,
		\.value.count
	)
}
