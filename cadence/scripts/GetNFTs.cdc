import "FooBar"
import "NonFungibleToken"

access(all) fun main(account: Address): [UInt64] {
    let publicReference = getAccount(account).getCapability(/public/FooBarCollection)
        .borrow<&FooBar.Collection{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow public reference to FooBar")

    return publicReference.getIDs()
}