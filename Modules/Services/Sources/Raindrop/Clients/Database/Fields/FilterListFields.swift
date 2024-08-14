// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Filter
import struct Catena.IDFields
import protocol Catenoid.Fields
import protocol DewdropService.FilterFields

public struct FilterListFields: FilterFields {
	public let id: Filter.ID
	public let sortIndex: Int
	public let count: Int
}

// MARK
extension FilterListFields: Fields {
	// MARK: Fields
	public typealias Model = Filter.Identified

	// MARK: Fields
	public static func merge(lhs: Self, rhs: Self) -> Self { lhs }

	// MARK: ModelProjection
	public static let projection = Projection<Model, Self>(
		Self.init,
		\.id,
		\.sortIndex,
		\.value.count
	)
}
