// Copyright © Fleuronic LLC. All rights reserved.

import struct DewdropService.Tagging
import struct Identity.Identifier
import struct Foundation.UUID

public struct Tagging: Equatable, Sendable {
	public let id: ID
	public let raindropID: Raindrop.ID
	public let tagName: String

	public init(
		raindropID: Raindrop.ID,
		tagName: String
	) {
		self.raindropID = raindropID
		self.tagName = tagName

		id = .init(rawValue: UUID().uuidString)
	}
}

// MARK: -
public extension Tagging {
	typealias ID = DewdropService.Tagging.ID
}
