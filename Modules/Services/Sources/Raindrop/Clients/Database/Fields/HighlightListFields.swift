// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import DewdropDatabase

import struct Dewdrop.Highlight
import struct Dewdrop.Raindrop
import protocol Catenoid.Fields
import protocol DewdropService.HighlightFields

public struct HighlightListFields: HighlightFields {
	public let id: Highlight.ID
	public let raindropID: Raindrop.ID
}

// MARK
extension HighlightListFields: Fields {
	// MARK: Fields
	public typealias Model = Highlight.Identified

	// MARK: Fields
	public static func merge(lhs: Self, rhs: Self) -> Self { lhs }

	// MARK: ModelProjection
	public static let projection = Projection<Model, Self>(
		Self.init,
		\.id,
		\.raindrop.id
	)
}
