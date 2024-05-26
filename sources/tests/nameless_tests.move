#[test_only]
module nameless::nameless_tests {
    use std::ascii;
    use std::string::utf8;

    use sui::clock;
    use sui::url::new_unsafe_from_bytes;
    use sui::test_utils::{destroy, assert_eq};
    use sui::coin::{mint_for_testing, CoinMetadata};
    use sui::test_scenario::{Self as ts, take_shared, next_tx};

    use nameless::nameless::{Self, TreasuryCapWrapper, NAMELESS};

    const MIST: u64 = 1_000_000_000;
    const HOUR: u64 = 3600000;
    const DAY: u64 = 86400000;

    #[test]
    fun test_end_to_end() {
        let mut scenario = ts::begin(@dev);

        nameless::init_for_testing(scenario.ctx());

        scenario.next_tx(@dev);

        let mut clock = clock::create_for_testing(scenario.ctx());
        let mut wrapper = scenario.take_shared<TreasuryCapWrapper>();
        let mut metadata = scenario.take_shared<CoinMetadata<NAMELESS>>();

        let current_price = wrapper.current_price(&clock);

        // floor price because time is 10
        assert_eq(current_price, MIST * 10);

        clock.set_for_testing(1716718257020);

        let current_price = wrapper.current_price(&clock);

        // floor price because time is 10 because no one ever boght coin
        assert_eq(current_price, MIST * 10);

        wrapper.update(
            &mut metadata,
            &clock,
            mint_for_testing(10 * MIST, scenario.ctx()),
            utf8(b"BONK"),
            ascii::string(b"BONK"),
            utf8(b"Solano doggie"),
            ascii::string(b"www.")
        );

        wrapper.update(
            &mut metadata,
            &clock,
            mint_for_testing(20 * MIST, scenario.ctx()),
            utf8(b"BONK"),
            ascii::string(b"BONK!"),
            utf8(b"Solano doggie"),
            ascii::string(b"www.")
        );

        assert_eq(metadata.get_name(), utf8(b"BONK"));
        assert_eq(metadata.get_symbol(), ascii::string(b"BONK!"));
        assert_eq(metadata.get_description(), utf8(b"Solano doggie"));
        assert_eq(*metadata.get_icon_url().borrow(), new_unsafe_from_bytes(b"www."));

        assert_eq(wrapper.current_price(&clock), 40 * MIST);

        clock.increment_for_testing(HOUR + DAY);

        // 1% discount
        assert_eq(wrapper.current_price(&clock), 39600000000);

        clock.increment_for_testing(HOUR * 17);

        // 18 % discount
        assert_eq(wrapper.current_price(&clock), 32800000000);

        clock.increment_for_testing(HOUR * 1700000);

        // floor price
        assert_eq(wrapper.current_price(&clock), 10 * MIST);

        destroy(wrapper);
        destroy(metadata);
        destroy(clock);
        scenario.end();
    }
}


