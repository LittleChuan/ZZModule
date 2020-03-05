// https://github.com/Quick/Quick

import Quick
import Nimble
import ZZModule

class ModuleSpec: QuickSpec {
    override func spec() {
        describe("scheme convertable") {
            it("without params") {
                expect("zz://test/a".asScheme()?.0) == "zz://test/a"
            }
            
            it("with params") {
                expect("zz://test/a?a=A".asScheme()?.0) == "zz://test/a"
            }
            
            it("with params and get right param") {
                expect("zz://test/a?a=A".asScheme()?.1?["a"] as? String) == "A"
            }
        }
        
        describe("register and load") {

            it("can load AViewController") {
                expect(ZZModule.object("zz://test/a")).notTo(beNil())
            }
            
            it("can load BViewController") {
                expect(ZZModule.object("zz://test/b")).notTo(beNil())
            }
        }
    }
}
