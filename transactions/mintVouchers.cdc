import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

/** Sample Metadata Struct 
Vouchers.Metadata(
    name: "The Best Vouchers",
    description: "All Vouchers of this Type share this metadata, and as such they are all the best.",
    mediaType: "image/png",
    mediaHash: "0x64EC88CA00B268E5BA1A35678A1B5316D212F4F366B2477232534A8AECA37F3C",
    mediaURI: "https://static.wikia.nocookie.net/meme/images/d/db/Rick-astley.png"
)
**/

// This is a batched transaction, and as such assumes it will update metadata for that type
// If you are minting additional of prior Vouchers, keep metadata consistent, as it
// will be set by this transaction
// transaction(count: Int, typeID: UInt64, updateMetadata: Bool, metadata: [String]) {
transaction(count: Int, typeID: UInt64, updateMetadata: Bool, name: String, description: String, mediaType: String, mediaHash: String, mediaURI: String) {
    prepare(signer: AuthAccount) {
        let proxy = signer
            .borrow<&Vouchers.AdminProxy>(from: Vouchers.AdminProxyStoragePath)
            ?? panic("Signer has no Admin Proxy")
        let minter = proxy.borrowSudo()

        let recipCollection = signer.borrow<&{NonFungibleToken.CollectionPublic}>
            (from: Vouchers.CollectionStoragePath)!
                
        minter.batchMintNFT(recipient: recipCollection, typeID: typeID, count: count)
        
        // this is hokey, but functional for the time being, but not tenable for long-term pattern
        if (updateMetadata == true) {
            // let voucherMetadata = Vouchers.Metadata(name: metadata![0], description: metadata![1], 
            //     mediaType: metadata![2], mediaHash: metadata![3], mediaURI: metadata![4])

            // minter.registerMetadata(typeID:typeID, metadata: voucherMetadata)
            let voucherMetadata = Vouchers.Metadata(name: name, description: description,
                mediaType: mediaType, mediaHash: mediaHash, mediaURI: mediaURI)

            minter.registerMetadata(typeID:typeID, metadata: voucherMetadata)
        }
    }
}
 