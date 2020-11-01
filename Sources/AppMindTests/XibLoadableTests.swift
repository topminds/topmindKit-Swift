//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import XCTest
@testable import AppMind

#if os(iOS) || os(tvOS)

import UIKit
class DummyLoadable: UITableViewCell, XibLoadable {
    static let xibName = "XibLoadableFixture"
    @IBOutlet var label: UILabel?
}

class DummyCell: UITableViewCell, PrototypeCell {
    static let cellIdentifier = "DummyCellFixture"
    @IBOutlet var label: UILabel?
}

class DummyCVLoadable: UICollectionViewCell, XibLoadable {
    static let xibName = "CVXibLoadableFixture"
    @IBOutlet var label: UILabel?
}

class DummyCVCell: UICollectionViewCell, PrototypeCell {
    static let cellIdentifier = "DummyCellFixture"
    @IBOutlet var label: UILabel?
}

private let testBundle = Bundle(for: XibLoadableTests.self)

final class XibLoadableTests: XCTestCase {

    let indexPath = IndexPath(row: 0, section: 0)

    // TODO: add tests when SPM supports resources
//    func testLoading() {
//        let sut = DummyLoadable.loadXib(bundle: testBundle)
//        XCTAssertNotNil(sut)
//        XCTAssertNotNil(sut.label)
//    }
//
//    func testCellLoadingXib() {
//        let table = UITableView()
//        table.dataSource = self
//        table.register(xibLoadable: DummyLoadable.self, bundle: testBundle)
//        let cell: DummyLoadable? = table.dequeueCell(for: indexPath)
//
//        XCTAssertNotNil(cell)
//    }

    func testCellLoading() {
        let table = UITableView()
        table.dataSource = self
        table.register(cell: DummyCell.self)
        let cell: DummyCell? = table.dequeueCell(for: indexPath)

        XCTAssertNotNil(cell)
    }

    func testCellLoadingCv() {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.dataSource = self
        cv.register(cell: DummyCVCell.self)
        let cell: DummyCVCell? = cv.dequeueCell(for: indexPath)

        XCTAssertNotNil(cell)
    }

    // TODO: add tests when SPM supports resources
//    func testCellLoadingXibCv() {
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        cv.dataSource = self
//        cv.registerCell(xibLoadable: DummyCVLoadable.self, bundle: testBundle)
//        let cell: DummyCVLoadable? = cv.dequeueCell(for: indexPath)
//
//        XCTAssertNotNil(cell)
//    }

}

extension XibLoadableTests: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dummy: DummyCell = tableView.dequeueCell(for: indexPath) else {
            XCTFail()
            return UITableViewCell()
        }
        return dummy
    }
}

extension XibLoadableTests: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dummy: DummyCVCell = collectionView.dequeueCell(for: indexPath) else {
            XCTFail()
            return UICollectionViewCell()
        }
        return dummy
    }
}

#endif
