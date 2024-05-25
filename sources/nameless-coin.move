module nameless::nameless {
  // === Imports ===
  use std::string;
  use std::ascii;
  
  use sui::sui::SUI;
  use sui::clock::Clock;
  use sui::balance::{Self, Balance};
  use sui::url::new_unsafe_from_bytes;
  use sui::coin::{Self, TreasuryCap, Coin, CoinMetadata};

  // === Errors ===

  const EPriceIsTooLow: u64 = 0;

  // === Constants ===

  const MIST: u64 = 1_000_000_000;
  // 10 SUI
  const FLOOR_PRICE: u64 = 10;
  const DAY: u64 = 86400000;
  const HOUR: u64 = 3600000;

  // === Structs ===

  public struct NAMELESS has drop {}

  public struct TreasuryCapWrapper has key {
    id: UID,
    inner: TreasuryCap<NAMELESS>,
    price: u64,
    last_update: u64,
    treasury: Balance<SUI>
  }

  public struct Dev has key, store {
    id: UID
  }

  // === Method Aliases ===

  // === Public-Mutative Functions ===

  fun init(otw: NAMELESS, ctx: &mut TxContext) {
      let (mut treasury_cap, metadata) = coin::create_currency(
            otw, 
            9, 
            b"LESS",
            b"Nameless", 
            b"What is the ticker?!", 
            option::some(new_unsafe_from_bytes(b"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAADICAYAAACtWK6eAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAATrSURBVHgB7d2NURNbGMfhw51bgHagHWgFaAViBWgFagVCBWoFaAVoBdqBWAF2oB3s3Tc3Kx8T/hCy+cLnmdlRR4U4s7+cvHtidqfrNWCmfxpwJYFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgeDfxlb5/ft3+/z5c/vx40c7OTlpP3/+nByDBw8e/DmePHnSdnd3Jz/ndna6XiOqk/LDhw/t3r177dWrV20dvn371g4PDyc/zqtCefHiRdvf32/MqeNKv3796g4ODro+jHoSmRz161X6+vVr15/gf77/Ike/knQfP37suDmBzHB6etr1z7hXnmh7e3uTeJapvv7r169HCePyUf+2+jdyPYGcM8+zdT0bL+skq69bX38ZcZx//N+/f+/IBDJ1m5cxdZIdHx93Y1pFHOcPL7kygUwtcpKNNZesOo7hGDvyu0QgU4ueZDUvLGJdcdRRFyHMJLO5zDu1s7PTFlX7Df0cc6t9h5cvX7b+5U5bl3rM/UwyuZTNGTvpI6oNu6dPn0428OZRYawzjlKPvfZ6uMgKMjXGCnLe+/fvb7yp+PDhwwu74etSq0etInbez1hBlqSfSSY739eplWMT4ijDOwY4YwWZGnsFGdTbPI6Ojq58Vt6U1WNQq0g/sJtFpqwgS1bvnaq5ZFYE9XubFEepVeTTp0+N/wlkBSqCx48fT96Fe96XL1/aJrr8OP9mAlmRemZ+/vz5hbnkNu/MXYV5r8LdZWaQqWXNILPUW8/fvXvX7t+/3zZVXc169OhR+9tZQdagrlzVcL7J6j9kIZC1qZdcbD6BMNOmXV1bF4FAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQyBaoz/X1WbnrIZAtMNzcxm0JVk8gW2K4e5VPO1wtgWyRYSV5+/ZtYzUEsoUODg4mn+3L8glkS9UdrMwlyyeQLVbzyG3vqsvNCGTLDXNJrSiMTyB3QO2R1ExieB+fQO6QGt6Pj49tKo5IIHfM3t6e4X1EApna399vm2p3d3euPz9sKtYtqFlQxx99JHW/xo06+rmiW0T9/Xm/Zx9Y1wfW0XUCuWSTIlk0jkE/wN/o+/UrTnd0dNRxRiAzbEIkY8Ux6OeSycpwVRhWjNkEcoV1RjJ2HIPT09MLkQjjeu6THrx586adnJy0VXr27NnSN/0ODw8ng78h/noCgcBlXggEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQCAQCgUAgEAgEAoFAIBAIBAKBQCAQ/AcrIWN+a9NXVQAAAABJRU5ErkJggg==")), 
            ctx
        );

      treasury_cap.mint_and_transfer(1_000_000_000 * MIST, @dev, ctx);  

      let wrapper =  TreasuryCapWrapper { 
        id: object::new(ctx), 
        inner: treasury_cap,
        price: FLOOR_PRICE * MIST,
        last_update: 0,
        treasury: balance::zero()
      }; 

      let dev = Dev { id: object::new(ctx) };

      transfer::share_object(wrapper);
      transfer::public_share_object(metadata);
      transfer::transfer(dev, @dev);
  }

  public fun update(
    wrapper: &mut TreasuryCapWrapper, 
    coin_metadata: &mut CoinMetadata<NAMELESS>, 
    clock: &Clock,
    token: Coin<SUI>,
    name: string::String,
    symbol: ascii::String,
    description: string::String,
    url: ascii::String    
  ) {
    let current_ts = clock.timestamp_ms();
    // find current price

    // up price

    let current_price = current_price(wrapper, clock);
    assert!(token.value() >= current_price, EPriceIsTooLow);

    // update state
    wrapper.price = current_price * 2;
    wrapper.last_update = current_ts;
    wrapper.treasury.join(token.into_balance());

    // update
    update_metadata(wrapper, coin_metadata, name, symbol, description, url);
  }

  // === Public-View Functions ===

  public fun current_price(
    wrapper: &TreasuryCapWrapper,  
    clock: &Clock,    
  ): u64 {
    let current_ts = clock.timestamp_ms();
    if (wrapper.last_update + DAY > current_ts) return safe_price(wrapper.price);
    
    let diff = current_ts - wrapper.last_update + DAY;

    let hours = diff / HOUR;

    if (hours == 0) return safe_price(wrapper.price);

    let discount_rate = MIST / 100;

    let discount = hours * discount_rate;

    safe_price(mul_div(discount, wrapper.price))
  }

  // === Admin Functions ===

  public fun withdraw(_: &Dev, wrapper: &mut TreasuryCapWrapper, ctx: &mut TxContext): Coin<SUI> {
    wrapper.treasury.withdraw_all().into_coin(ctx)
  }

  // === Public-Package Functions ===

  // === Private Functions ===

  fun safe_price(x: u64): u64 {
    let floor_price = FLOOR_PRICE * MIST;
    if (x > floor_price) x else floor_price
  }

  fun mul_div(x: u64, y: u64): u64 {
    ((x as u128) * (y as u128) / (MIST as u128) as u64)
  }

  fun update_metadata(
    wrapper: &TreasuryCapWrapper,
    coin_metadata: &mut CoinMetadata<NAMELESS>, 
    name: string::String,
    symbol: ascii::String,
    description: string::String,
    url: ascii::String
    ) {
        wrapper.inner.update_name(coin_metadata, name);
        wrapper.inner.update_symbol(coin_metadata, symbol);
        wrapper.inner.update_description(coin_metadata, description);
        wrapper.inner.update_icon_url(coin_metadata, url);
    }

  // === Test Functions === 
}
