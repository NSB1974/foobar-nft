import "FooBar"

transaction {

    prepare(acct: AuthAccount) {
        acct.save(<- FooBar.createNFT(), to: /storage/FooBar)
    }

    execute {
        log("NFT created")
    }
}