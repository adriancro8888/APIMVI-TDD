// MARK: - Mocks generated from file: APIMVI/Blogs/NetworkManager.swift at 2018-10-30 06:40:29 +0000

//
//  NetworkManager.swift
//  APIMVI
//
//  Created by Dinesh IIINC on 29/10/18.
//  Copyright © 2018 kite.work. All rights reserved.
//

import Cuckoo
@testable import APIMVI

import Alamofire
import Foundation
import RxAlamofire
import RxSwift

class MockNetworkManager: NetworkManager, Cuckoo.ClassMock {
    typealias MocksType = NetworkManager
    typealias Stubbing = __StubbingProxy_NetworkManager
    typealias Verification = __VerificationProxy_NetworkManager
    let cuckoo_manager = Cuckoo.MockManager(hasParent: true)

    

    

    
    // ["name": "fetchBlogs", "returnSignature": " -> Observable<[Blog]>", "fullyQualifiedName": "fetchBlogs() -> Observable<[Blog]>", "parameterSignature": "", "parameterSignatureWithoutNames": "", "inputTypes": "", "isThrowing": false, "isInit": false, "isOverriding": true, "hasClosureParams": false, "@type": "ClassMethod", "accessibility": "", "parameterNames": "", "call": "", "parameters": [], "returnType": "Observable<[Blog]>", "isOptional": false, "stubFunction": "Cuckoo.ClassStubFunction"]
     override func fetchBlogs()  -> Observable<[Blog]> {
        
            return cuckoo_manager.call("fetchBlogs() -> Observable<[Blog]>",
                parameters: (),
                superclassCall:
                    
                    super.fetchBlogs()
                    )
        
    }
    

	struct __StubbingProxy_NetworkManager: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	    init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func fetchBlogs() -> Cuckoo.ClassStubFunction<(), Observable<[Blog]>> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockNetworkManager.self, method: "fetchBlogs() -> Observable<[Blog]>", parameterMatchers: matchers))
	    }
	    
	}

	struct __VerificationProxy_NetworkManager: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	    init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func fetchBlogs() -> Cuckoo.__DoNotUse<Observable<[Blog]>> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("fetchBlogs() -> Observable<[Blog]>", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}

}

 class NetworkManagerStub: NetworkManager {
    

    

    
     override func fetchBlogs()  -> Observable<[Blog]> {
        return DefaultValueRegistry.defaultValue(for: Observable<[Blog]>.self)
    }
    
}

