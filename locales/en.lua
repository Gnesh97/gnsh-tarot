Locales = Locales or {}

Locales['en'] = {
    -- ============================================================
    -- TARGET / INTERACTION LABELS
    -- ============================================================
    target_start_reading = 'Start a Tarot Reading',
    target_remove_table = 'Pack Up the Table',
    target_toggle_ambient = 'Toggle Ambient Sound',
    target_end_reading = 'End the Active Reading',
    target_sit_at_table = 'Sit at the Table',
    target_focus_reading = 'Focus on the Reading',
    target_stand_up = 'Stand Up',
    interaction_prompt = '[E] Interact with the tarot table',

    -- ============================================================
    -- TABLE / ITEM
    -- ============================================================
    table_placed = 'You set up the tarot table.',
    table_removed = 'You packed up the tarot table.',
    table_no_item = 'You need a tarot table to do this.',
    table_too_many = 'You already have a tarot table placed.',
    table_in_vehicle = 'You cannot set up a tarot table while in a vehicle.',
    table_bad_surface = 'This surface is not suitable for a table.',
    table_not_owner = 'This is not your table.',
    table_busy = 'This table is already in use.',
    table_not_found = 'That table no longer exists.',
    table_too_far = 'You are too far from the tarot table.',
    table_placement_pending = 'A table placement is already pending.',
    table_placement_invalid = 'The table placement could not be validated.',
    table_placement_expired = 'The table placement expired.',
    table_expired = 'The tarot table was removed after being unused for too long.',

    -- ============================================================
    -- INVITES / SESSIONS
    -- ============================================================
    invite_received = '%s wants to give you a tarot reading.',
    invite_prompt_title = 'Tarot Reading Invitation',
    invite_prompt_body = '%s wants to perform the "%s" spread for you.',
    invite_accept = 'Accept',
    invite_reject = 'Decline',
    invite_sent = 'Invitation sent.',
    invite_expired = 'The tarot invitation has expired.',
    invite_rejected = 'The invitation was declined.',
    invite_rejected_by_you = 'You declined the tarot reading.',
    invite_too_far = 'The other player is too far away.',
    invite_no_target = 'Choose someone to read for first.',
    invite_self = 'You cannot invite yourself.',
    invite_already_busy = 'That player is already in a reading.',
    invite_you_are_busy = 'You are already in a reading.',

    session_cancelled = 'The tarot session was cancelled.',
    session_completed = 'The reading has concluded.',
    session_too_far = 'You moved too far from the tarot table.',
    session_not_found = 'That session no longer exists.',
    session_not_your_turn = 'Only the reader can do that.',
    session_wrong_state = 'That cannot be done right now.',
    session_slot_taken = 'That card has already been revealed.',
    session_slot_invalid = 'Invalid card slot.',
    session_not_sequential = 'Reveal the previous card first.',
    session_reader_left = 'The reader left. The session has ended.',
    session_customer_left = 'The other participant left. The session has ended.',

    -- ============================================================
    -- SPREADS
    -- ============================================================
    spread_single_card = 'Card of the Day',
    spread_three_card = 'Past — Present — Future',
    spread_ten_card = 'Ten-Card Spread',
    slot_single = 'The Card',
    slot_past = 'Past',
    slot_present = 'Present',
    slot_future = 'Future',
    slot_1 = 'Card 1',
    slot_2 = 'Card 2',
    slot_3 = 'Card 3',
    slot_4 = 'Card 4',
    slot_5 = 'Card 5',
    slot_6 = 'Card 6',
    slot_7 = 'Card 7',
    slot_8 = 'Card 8',
    slot_9 = 'Card 9',
    slot_10 = 'Card 10',

    -- ============================================================
    -- ORIENTATION
    -- ============================================================
    orientation_upright = 'Upright',
    orientation_reversed = 'Reversed',

    -- ============================================================
    -- GENERIC / ERRORS
    -- ============================================================
    action_too_fast = 'You are doing that too quickly.',
    generic_error = 'Something went wrong. Please try again.',
    no_permission = 'You are not allowed to give tarot readings.',

    -- ============================================================
    -- NUI SCREEN LABELS
    -- ============================================================
    nui_deal_cards = 'Deal Cards',
    nui_deal_waiting = 'Waiting for the reader to deal the cards...',
    nui_dealing = 'Dealing the cards...',
    nui_reveal_first_card = 'Reveal Card',
    nui_reveal_next_card = 'Reveal Next Card',
    nui_close_reading = 'End the Reading',
    nui_close_summary = 'Close',
    nui_waiting_for_reader = 'The reader is turning the next card...',
    nui_your_turn_reveal = 'Turn the next card when you are ready.',
    nui_summary_title = 'The Reading',
    nui_closing_default = 'The reading has ended.',

    -- ============================================================
    -- MAJOR ARCANA MEANINGS
    -- Written as suggestive roleplay flavor only — never a certain
    -- prediction, never tied to health/stats/economy.
    -- ============================================================
    card_the_fool_upright = 'A new journey may be beginning — a leap into the unknown that calls for a little courage.',
    card_the_fool_reversed = 'Acting without thinking things through, or hesitation dressed up as boldness.',

    card_the_magician_upright = 'The tools for a plan may already be at hand; it could be a good moment to act with intent.',
    card_the_magician_reversed = 'Talent or resources being used toward a questionable end, or a plan that has not quite come together.',

    card_the_high_priestess_upright = 'Something unspoken may be worth paying closer attention to.',
    card_the_high_priestess_reversed = 'A secret withheld too long, or intuition being ignored.',

    card_the_empress_upright = 'A period of growth, comfort, or care for something being nurtured.',
    card_the_empress_reversed = 'Neglect of something that needed attention, or smothering care that has become too much.',

    card_the_emperor_upright = 'A moment that calls for structure, order, or someone stepping into authority.',
    card_the_emperor_reversed = 'Rigid control, or a loss of grip on a situation once firmly held.',

    card_the_hierophant_upright = 'Tradition, mentorship, or a lesson passed down may be relevant here.',
    card_the_hierophant_reversed = 'Breaking from convention, or rules that no longer serve the moment.',

    card_the_lovers_upright = 'A meaningful choice may lie ahead for your character, perhaps involving a bond with someone else.',
    card_the_lovers_reversed = 'Disharmony between two paths, or a bond under strain.',

    card_the_chariot_upright = 'Determination and forward motion, even through conflicting pressures.',
    card_the_chariot_reversed = 'A loss of direction, or forcing progress that will not hold.',

    card_strength_upright = 'Quiet resolve or patience may matter more here than force.',
    card_strength_reversed = 'Self-doubt, or strength spent the wrong way.',

    card_the_hermit_upright = 'A time for reflection, or stepping back from others to think things through.',
    card_the_hermit_reversed = 'Isolation that has gone on too long, or wisdom kept to oneself when it was needed.',

    card_wheel_of_fortune_upright = 'A turning point — circumstances shifting in a way your character does not fully control.',
    card_wheel_of_fortune_reversed = 'A run of events feeling stuck, or a shift arriving at an inconvenient time.',

    card_justice_upright = 'A matter of fairness, consequence, or a decision that may need to be weighed carefully.',
    card_justice_reversed = 'An imbalance, or a consequence that has been avoided rather than faced.',

    card_the_hanged_man_upright = 'A pause, or seeing a familiar situation from an entirely different angle.',
    card_the_hanged_man_reversed = 'Delay for its own sake, or resisting a perspective that would actually help.',

    card_death_upright = 'An ending that clears the way for something else — this card speaks to change, not literal harm.',
    card_death_reversed = 'Resistance to a change that already feels inevitable.',

    card_temperance_upright = 'Balance, patience, or finding a middle path between two extremes.',
    card_temperance_reversed = 'Excess in one direction, or a balance that has tipped too far.',

    card_the_devil_upright = 'A pull toward temptation, obsession, or a bond that may not be healthy.',
    card_the_devil_reversed = 'Breaking free of a hold something has had over your character.',

    card_the_tower_upright = 'A sudden upheaval or revelation that shakes something previously taken for granted.',
    card_the_tower_reversed = 'A collapse narrowly avoided, or change resisted until it can no longer be.',

    card_the_star_upright = 'A quiet hope, or a reason for optimism after a difficult stretch.',
    card_the_star_reversed = 'Faith or hope that feels harder to hold onto right now.',

    card_the_moon_upright = 'Uncertainty, illusion, or something that is not quite what it seems.',
    card_the_moon_reversed = 'Confusion beginning to clear, or a fear that turns out to be smaller than it seemed.',

    card_the_sun_upright = 'Clarity, warmth, or a moment of genuine good fortune in the story.',
    card_the_sun_reversed = 'Optimism that feels delayed, or a bright moment clouded by doubt.',

    card_judgement_upright = 'A reckoning, or a chance to look honestly at a past choice.',
    card_judgement_reversed = 'Avoiding a truth that keeps resurfacing, or being too harsh in self-judgment.',

    card_the_world_upright = 'A sense of completion — a chapter of the story reaching its close.',
    card_the_world_reversed = 'Unfinished business, or a conclusion that keeps slipping out of reach.'
}

Locales['en'].spread_horseshoe_seven = 'Seven-Card Horseshoe'
Locales['en'].spread_pentagram = 'Pentagram Spread'
Locales['en'].spread_celtic_cross = 'Celtic Cross'
Locales['en'].spread_gypsy_twenty_one = 'Gypsy Twenty-One'
Locales['en'].spread_selection_title = 'Choose a Spread'
Locales['en'].spread_selection_confirm = 'Confirm Spread'
Locales['en'].spread_selection_waiting = 'The reader is choosing a spread...'
Locales['en'].spread_dealing = 'Dealing cards onto the table...'
Locales['en'].nui_reveal_all = 'Reveal All Cards'
Locales['en'].player_selection_title = 'Who Is This Reading For?'
Locales['en'].player_selection_confirm = 'Send Invite'
Locales['en'].player_selection_empty = 'No nearby players found.'
Locales['en'].player_selection_solo = 'Read For Yourself'
