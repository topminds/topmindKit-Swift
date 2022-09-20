//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public final class DistanceFormatter: NumberFormatter {
	private static let metersPerMile = 1609.344
	private static let feetPerMile = 5280.0

	override public func string(from number: NSNumber) -> String? {
		if locale.usesMetricSystem {
			return super.string(from: configureMetric(for: number))
		} else {
			return super.string(from: configureImperial(for: number))
		}
	}

	private func configureMetric(for number: NSNumber) -> NSNumber {
		let value = abs(number.doubleValue)
		if value < 1000 {
			multiplier = 1
			positiveFormat = "###m"
		} else {
			multiplier = 0.001
			if value < 10000 { // < 10km -> kilometers roundet to 500m
				positiveFormat = "#.#km"
				roundingIncrement = 0.1
			} else { // >= 10km -> kilometers roundet to kilometers
				positiveFormat = "#,###km"
			}
		}

		considerNegativeDistance(for: number)

		return NSNumber(value: value)
	}

	private func configureImperial(for number: NSNumber) -> NSNumber {
		let value = abs(number.doubleValue) / DistanceFormatter.metersPerMile

		if value < 0.1 {
			multiplier = NSNumber(value: DistanceFormatter.feetPerMile)
			positiveFormat = "###ft"
		} else if value < 10 { // < 10mi
			multiplier = 1
			positiveFormat = "#.#mi"
			roundingIncrement = 0.1
		} else {
			multiplier = 1
			positiveFormat = "#,###mi" // > 10mi
		}

		considerNegativeDistance(for: number)

		return NSNumber(value: value)
	}

	private func considerNegativeDistance(for number: NSNumber) {
		if number.doubleValue < 0.0 {
			positivePrefix = negativePrefix
		} else {
			positivePrefix = ""
		}
	}
}
