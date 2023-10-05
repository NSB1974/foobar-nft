import "NonFungibleToken"
import "MetadataViews"

pub contract FooBar: NonFungibleToken {

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    pub var totalSupply: UInt64

    pub resource interface ViewResolver {
        pub fun getViews() : [Type]
        pub fun resolveView(_ view:Type): AnyStruct?
    }

    pub resource NFT: NonFungibleToken.INFT, ViewResolver {
        pub let id: UInt64
        pub let name: String
        pub let description: String
        pub let thumbnail: String

        init(name: String, description: String, thumbnail: String) {
            self.id = FooBar.totalSupply
            self.name = name
            self.description = description
            self.thumbnail = thumbnail
            FooBar.totalSupply = FooBar.totalSupply + 1
        }

        pub fun getViews(): [Type] {
            return [Type<MetadataViews.Display>()]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            if (view == Type<MetadataViews.Display>()) {
                return MetadataViews.Display(
                    name: self.name,
                    description: self.description,
                    thumbnail: MetadataViews.HTTPFile(
                        url: self.thumbnail
                    )
                )
            }
            return nil
        }
    }

    // pub resource interface CollectionPublic {
    //     pub fun deposit(token: @NFT)
    //     pub fun getIDs(): [UInt64]
    // }

    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let tokenID = token.id
            self.ownedNFTs[token.id] <-! token
            emit Deposit(id: tokenID, to: self.owner?.address)
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("Token not in collection")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <- token
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        pub fun borrowFooBarNFT(id: UInt64): &FooBar.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &FooBar.NFT
            }

            return nil
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
        pub fun createNFT(name: String, description: String, thumbnail: String): @NFT {
            return <-create NFT(name: name, description: description, thumbnail: thumbnail)
        }

        init() {}
    }

    init() {
        self.totalSupply = 0
        emit ContractInitialized()
        self.account.save(<- create NFTMinter(), to: /storage/NFTMinter)
    }
}