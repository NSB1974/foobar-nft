import "FooBar"
import "NonFungibleToken"

transaction {

    prepare(acct: AuthAccount) {
        acct.save(<- FooBar.createEmptyCollection(), to: /storage/FooBarCollection)
        acct.link<&FooBar.Collection{NonFungibleToken.CollectionPublic}>(/public/FooBarCollection, target: /storage/FooBarCollection)
    }

    execute {
        log("NFT collection created")
    }
}