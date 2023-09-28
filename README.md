## How does ERC721A save gas?
721A reduces the number of writes by assuming tokens are minted sequentially.

## Where does it add cost?
Gas costs are significantly higher for reading data, because there is some iteration involved in finding the owner address as a result of reduces writes at the time of minting.

## Why shouldn't ERC721A Enumerable be used on chain?
The read costs would be prohibitively expensive.

## When would the wrapped NFT pattern be used?
The wrapped NFT pattern seems to be very useful for extending functionality or altering the interface to a token.
This could apply in situations where token standards have evolved and wrapping the NFT allows it expose a newly defined interface.
It could also be useful to wrap the NFT if the token uri scheme is no longer valid (because of an externally hosted webserver going under) and a new uri is necessary.

## How do NFT marketplaces determine what tokens an address owns?
NFT marketplaces can filter for "Transfer" events emitted by NFT contracts, and 'rebuild' the current ownership of tokens from the sequence of transfers. These events are easier to access than retrieving data from contract storage.