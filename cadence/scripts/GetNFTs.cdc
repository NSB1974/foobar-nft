import "FooBar"
import "NonFungibleToken"

pub fun main(account: Address): [UInt64] {
    let publicReference = getAccount(account).getCapability(/public/FooBarCollection)
        .borrow<&FooBar.Collection{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow public reference to FooBar")

    return publicReference.getIDs()
}p