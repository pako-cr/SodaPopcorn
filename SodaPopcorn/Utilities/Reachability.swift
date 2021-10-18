//
//  Reachability.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 18/10/21.
//

import Combine
import SystemConfiguration

public enum Reachability {
	case wifi
#if os(iOS)
	case wwan
#endif
	case none

	public static var current: Reachability {
		return reachabilityProperty.value
	}

	public static let signalProducer = reachabilityProperty.share()
}

private let queue = DispatchQueue(label: "com.automata.sodapopcorn", attributes: [])

private let reachabilityProperty: CurrentValueSubject<Reachability, Never> = {
	guard
		let networkReachability = networkReachability(),
		let reachabilityFlags = reachabilityFlags(forNetworkReachability: networkReachability)
	else { return CurrentValueSubject(.none) }

	guard SCNetworkReachabilitySetCallback(networkReachability, callback, nil)
			&& SCNetworkReachabilitySetDispatchQueue(networkReachability, queue)
	else { return CurrentValueSubject(.none) }

	return CurrentValueSubject(reachability(forFlags: reachabilityFlags))
}()

private func networkReachability() -> SCNetworkReachability? {
	var zeroAddress = sockaddr_in()
	zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
	zeroAddress.sin_family = sa_family_t(AF_INET)

	return withUnsafePointer(to: &zeroAddress, { pointr in
		pointr.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
			SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
		}
	})
}

private func reachabilityFlags(forNetworkReachability networkReachability: SCNetworkReachability) -> SCNetworkReachabilityFlags? {

	var reachabilityFlags = SCNetworkReachabilityFlags()

	guard withUnsafeMutablePointer(to: &reachabilityFlags, {
		SCNetworkReachabilityGetFlags(networkReachability, UnsafeMutablePointer($0))
	}) else { return nil }

	return reachabilityFlags
}

private func reachability(forFlags flags: SCNetworkReachabilityFlags) -> Reachability {
#if os(iOS)
	if flags.contains(.isWWAN) {
		return .wwan
	}
#endif
	if flags.contains(.reachable) {
		return .wifi
	}

	return .none
}

private func callback(networkReachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
	reachabilityProperty.send(reachability(forFlags: flags))
}
