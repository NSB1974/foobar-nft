import "NonFungibleToken"

pub contract FooBar: NonFungibleToken {

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    pub var totalSupply: UInt64

    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64

        init() {
            self.id = FooBar.totalSupply
            FooBar.totalSupply = FooBar.totalSupply + 1
        }
    }

    pub resource interface CollectionPublic {
        pub fun deposit(token: @NFT)
        pub fun getIDs(): [UInt64]
    }

    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        pub fun deposit(token: @NFT) {
            self.ownedNFTs[token.id] <-! token
            emit Deposit(id: id, to: self.owner?.address)
        }

        pub fun withdraw(withdrawID: UInt64): @NFT? {
            let token <- self.ownedNFTs.remove(key: id) ?? panic("Token not in collection")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <- token
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        init() {
            self.ownedNFTs <- {}
        }

        destroy () {
            destroy self.ownedNFTs
        }
    }
    
    pub fun createEmptyCollection(): @Collection {
        return <-create Collection()
    }

    pub resource NFTMinter {
        pub fun createNFT(): @NFT {
            return <-create NFT()
        }

        init() {}
    }

    init() {
        self.totalSupply = 0
        emit ContractInitialized()
        self.account.save(<- create NFTMinter(), to: /storage/NFTMinter)
    }
}