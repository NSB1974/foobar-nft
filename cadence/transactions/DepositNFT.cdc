import "FooBar"
import "NonFungibleToken"

transaction(recipient: Address) {

    prepare(acct: AuthAccount) {
        let nftMinter = acct.borrow<&FooBar.NFTMinter>(from: /storage/NFTMinter)
            ?? panic("Could not borrow a reference to the NFTMinter")

        let recipientReference = getAccount(recipient).getCapability(/public/FooBarCollection)
            .borrow<&FooBar.Collection{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the recipient's collection")

        recipientReference.deposit(token: <- nftMinter.createNFT(name: "test", description: "something", thumbnail: "thumbnail"))
    }

    execute {
        log("New NFT deposited into collection")
    }
}