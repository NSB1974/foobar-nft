pub contract FooBar {

    pub var totalSupply: UInt64

    pub resource NFT {
        pub let id: UInt64

        init() {
            self.id = FooBar.totalSupply
            FooBar.totalSupply = FooBar.totalSupply + 1
        }
    }

    pub fun createNFT(): @NFT {
        return <-create NFT()
    }

    init() {
        self.totalSupply = 0
    }
}