import "FooBar"
import "NonFungibleToken"

transaction(recipient: Address, id: UInt64) {

    prepare(acct: AuthAccount) {
        let collection = acct.borrow<&FooBar.Collection>(from: /storage/FooBarCollection)!

        let recipientReference = getAccount(recipient).getCapability(/public/FooBarCollection)
            .borrow<&FooBar.Collection{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the recipient's collection")

        recipientReference.deposit(token: <- collection.withdraw(withdrawID: id))
    }

    execute {
        log("New NFT deposited into collection")
    }
}