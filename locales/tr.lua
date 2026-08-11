Locales = Locales or {}

Locales['tr'] = {
    -- ============================================================
    -- TARGET / ETKİLEŞİM ETİKETLERİ
    -- ============================================================
    target_start_reading = 'Fal Bakmayı Başlat',
    target_remove_table = 'Masayı Topla',
    target_toggle_ambient = 'Ortam Sesini Aç/Kapat',
    target_end_reading = 'Aktif Falı Sonlandır',
    target_sit_at_table = 'Masaya Otur',
    target_focus_reading = 'Fala Odaklan',
    target_stand_up = 'Masadan Kalk',
    interaction_prompt = '[E] Tarot masasıyla etkileşime geç',

    -- ============================================================
    -- MASA / EŞYA
    -- ============================================================
    table_placed = 'Tarot masasını kurdunuz.',
    table_removed = 'Tarot masasını topladınız.',
    table_no_item = 'Bunun için bir tarot masasına ihtiyacınız var.',
    table_too_many = 'Zaten kurulu bir tarot masanız var.',
    table_in_vehicle = 'Araçtayken tarot masası kuramazsınız.',
    table_bad_surface = 'Bu zemin masa için uygun değil.',
    table_not_owner = 'Bu masa size ait değil.',
    table_busy = 'Bu masa şu anda kullanımda.',
    table_not_found = 'Bu masa artık mevcut değil.',
    table_too_far = 'Tarot masasından çok uzaktasınız.',
    table_placement_pending = 'Masa kurulumu zaten bekliyor.',
    table_placement_invalid = 'Masa kurulumu doğrulanamadı.',
    table_placement_expired = 'Masa kurulumu zaman aşımına uğradı.',
    table_expired = 'Tarot masası uzun süre kullanılmadığı için kaldırıldı.',

    -- ============================================================
    -- DAVET / OTURUM
    -- ============================================================
    invite_received = '%s size tarot falı bakmak istiyor.',
    invite_prompt_title = 'Tarot Falı Daveti',
    invite_prompt_body = '%s size "%s" açılımını yapmak istiyor.',
    invite_accept = 'Kabul Et',
    invite_reject = 'Reddet',
    invite_sent = 'Davet gönderildi.',
    invite_expired = 'Tarot davetinin süresi doldu.',
    invite_rejected = 'Davet reddedildi.',
    invite_rejected_by_you = 'Tarot falını reddettiniz.',
    invite_too_far = 'Diğer oyuncu çok uzakta.',
    invite_no_target = 'Önce fal bakılacak bir kişi seçin.',
    invite_self = 'Kendinize davet gönderemezsiniz.',
    invite_already_busy = 'O oyuncu zaten bir falın içinde.',
    invite_you_are_busy = 'Zaten aktif bir falın içindesiniz.',

    session_cancelled = 'Tarot oturumu iptal edildi.',
    session_completed = 'Fal sona erdi.',
    session_too_far = 'Tarot masasından çok uzaklaştınız.',
    session_not_found = 'Bu oturum artık mevcut değil.',
    session_not_your_turn = 'Bunu yalnızca falcı yapabilir.',
    session_wrong_state = 'Bu işlem şu anda yapılamaz.',
    session_slot_taken = 'Bu kart zaten açılmış.',
    session_slot_invalid = 'Geçersiz kart slotu.',
    session_not_sequential = 'Önce bir önceki kartı açın.',
    session_reader_left = 'Falcı ayrıldı. Oturum sona erdi.',
    session_customer_left = 'Diğer katılımcı ayrıldı. Oturum sona erdi.',

    -- ============================================================
    -- AÇILIMLAR
    -- ============================================================
    spread_single_card = 'Günün Kartı',
    spread_three_card = 'Geçmiş — Şimdiki Zaman — Gelecek',
    spread_ten_card = 'On Kartlık Açılım',
    slot_single = 'Kart',
    slot_past = 'Geçmiş',
    slot_present = 'Şimdiki Zaman',
    slot_future = 'Gelecek',
    slot_1 = 'Kart 1',
    slot_2 = 'Kart 2',
    slot_3 = 'Kart 3',
    slot_4 = 'Kart 4',
    slot_5 = 'Kart 5',
    slot_6 = 'Kart 6',
    slot_7 = 'Kart 7',
    slot_8 = 'Kart 8',
    slot_9 = 'Kart 9',
    slot_10 = 'Kart 10',

    -- ============================================================
    -- YÖN
    -- ============================================================
    orientation_upright = 'Düz',
    orientation_reversed = 'Ters',

    -- ============================================================
    -- GENEL / HATALAR
    -- ============================================================
    action_too_fast = 'Bunu çok hızlı yapıyorsunuz.',
    generic_error = 'Bir şeyler ters gitti. Lütfen tekrar deneyin.',
    no_permission = 'Tarot falı bakmaya yetkiniz yok.',

    -- ============================================================
    -- NUI EKRAN ETİKETLERİ
    -- ============================================================
    nui_deal_cards = 'Kartları Dağıt',
    nui_deal_waiting = 'Falcının kartları dağıtması bekleniyor...',
    nui_dealing = 'Kartlar dağıtılıyor...',
    nui_reveal_first_card = 'Kart Aç',
    nui_reveal_next_card = 'Sıradaki Kartı Aç',
    nui_close_reading = 'Falı Sonlandır',
    nui_close_summary = 'Kapat',
    nui_waiting_for_reader = 'Falcı sıradaki kartı çeviriyor...',
    nui_your_turn_reveal = 'Hazır olduğunuzda sıradaki kartı çevirin.',
    nui_summary_title = 'Fal Sonucu',
    nui_closing_default = 'Fal sona erdi.',

    -- ============================================================
    -- MAJOR ARCANA ANLAMLARI
    -- Yalnızca RP hikâye ipucu amaçlıdır — kesin kehanet değildir,
    -- sağlık/stat/ekonomi ile hiçbir bağlantısı yoktur.
    -- ============================================================
    card_the_fool_upright = 'Yeni bir yolculuk başlıyor olabilir; bilinmeyene adım atmak biraz cesaret isteyebilir.',
    card_the_fool_reversed = 'Düşünmeden hareket etmek, ya da cesaret gibi görünen bir tereddüt.',

    card_the_magician_upright = 'Bir planın araçları çoktan elde olabilir; niyetle hareket etmek için uygun bir an olabilir.',
    card_the_magician_reversed = 'Yeteneğin ya da kaynakların yanlış bir amaç için kullanılması, ya da tam oturmamış bir plan.',

    card_the_high_priestess_upright = 'Söylenmeyen bir şey daha yakından dikkat edilmeyi hak ediyor olabilir.',
    card_the_high_priestess_reversed = 'Çok uzun süre saklı tutulan bir sır, ya da göz ardı edilen bir sezgi.',

    card_the_empress_upright = 'Bir büyüme, rahatlık ya da özenle ilgilenilen bir şey dönemi.',
    card_the_empress_reversed = 'İhmal edilen bir şey, ya da fazla ileri gitmiş bir koruyuculuk.',

    card_the_emperor_upright = 'Düzen, yapı ya da birinin otorite üstlenmesini gerektiren bir an.',
    card_the_emperor_reversed = 'Katı bir kontrol, ya da bir zamanlar sıkı tutulan bir durumun elden kaçması.',

    card_the_hierophant_upright = 'Gelenek, mentorluk ya da aktarılan bir ders burada önemli olabilir.',
    card_the_hierophant_reversed = 'Alışılmıştan kopmak, ya da artık işe yaramayan kurallar.',

    card_the_lovers_upright = 'Karakterinin önünde, belki başka biriyle bir bağı da ilgilendiren anlamlı bir seçim olabilir.',
    card_the_lovers_reversed = 'İki yol arasında uyumsuzluk, ya da zorlanan bir bağ.',

    card_the_chariot_upright = 'Çelişkili baskılara rağmen kararlılık ve ileriye doğru hareket.',
    card_the_chariot_reversed = 'Yön kaybı, ya da tutmayacak bir ilerlemeyi zorlamak.',

    card_strength_upright = 'Burada güçten çok sessiz bir kararlılık ya da sabır önemli olabilir.',
    card_strength_reversed = 'Kendinden şüphe duymak, ya da yanlış yöne harcanan bir güç.',

    card_the_hermit_upright = 'Düşünmek için bir an, ya da meseleyi anlamak için başkalarından geri çekilmek.',
    card_the_hermit_reversed = 'Fazla uzayan bir yalnızlık, ya da gerektiğinde paylaşılmayan bir bilgelik.',

    card_wheel_of_fortune_upright = 'Bir dönüm noktası — karakterinin tam kontrol edemediği bir değişim.',
    card_wheel_of_fortune_reversed = 'Bir dizi olayın tıkanmış hissi, ya da uygun olmayan bir zamanda gelen bir değişim.',

    card_justice_upright = 'Adalet, sonuç ya da dikkatle tartılması gereken bir karar meselesi.',
    card_justice_reversed = 'Bir dengesizlik, ya da yüzleşmek yerine ertelenen bir sonuç.',

    card_the_hanged_man_upright = 'Bir duraklama, ya da tanıdık bir durumu tamamen farklı bir açıdan görmek.',
    card_the_hanged_man_reversed = 'Sırf oyalanmak için gecikme, ya da işe yarayacak bir bakış açısına direnmek.',

    card_death_upright = 'Başka bir şeye yer açan bir bitiş — bu kart değişime işaret eder, gerçek bir zarara değil.',
    card_death_reversed = 'Zaten kaçınılmaz görünen bir değişime direnmek.',

    card_temperance_upright = 'Denge, sabır, ya da iki uç arasında bir orta yol bulmak.',
    card_temperance_reversed = 'Bir yöne kaçan aşırılık, ya da fazla bozulmuş bir denge.',

    card_the_devil_upright = 'Bir cazibeye, saplantıya ya da sağlıklı olmayabilecek bir bağa doğru çekilme.',
    card_the_devil_reversed = 'Karakterinin üzerinde etkisi olan bir şeyden kurtulmak.',

    card_the_tower_upright = 'Daha önce olduğu gibi kabul edilen bir şeyi sarsan ani bir sarsıntı ya da farkındalık.',
    card_the_tower_reversed = 'Kıl payı atlatılan bir çöküş, ya da artık kaçınılamayana kadar direnilen bir değişim.',

    card_the_star_upright = 'Sessiz bir umut, ya da zor bir dönemin ardından iyimserlik için bir sebep.',
    card_the_star_reversed = 'Şu an tutunması daha zor hissedilen bir inanç ya da umut.',

    card_the_moon_upright = 'Belirsizlik, yanılsama, ya da göründüğü gibi olmayan bir şey.',
    card_the_moon_reversed = 'Netleşmeye başlayan bir karışıklık, ya da sanıldığından küçük çıkan bir korku.',

    card_the_sun_upright = 'Netlik, sıcaklık, ya da hikâyede gerçek bir iyi şans anı.',
    card_the_sun_reversed = 'Gecikmiş hissedilen bir iyimserlik, ya da şüpheyle gölgelenmiş parlak bir an.',

    card_judgement_upright = 'Bir hesaplaşma, ya da geçmiş bir seçime dürüstçe bakma fırsatı.',
    card_judgement_reversed = 'Sürekli geri gelen bir gerçekten kaçmak, ya da kendine karşı fazla sert olmak.',

    card_the_world_upright = 'Bir tamamlanma hissi — hikâyenin bir bölümünün kapanması.',
    card_the_world_reversed = 'Bitmemiş bir mesele, ya da sürekli elden kaçan bir sonuç.'
}

Locales['tr'].spread_horseshoe_seven = 'Yedi Kartlı At Nalı'
Locales['tr'].spread_pentagram = 'Pentagram Dizilimi'
Locales['tr'].spread_celtic_cross = 'Kelt Haçı Dizilimi'
Locales['tr'].spread_gypsy_twenty_one = 'Çingene Dizilimi'
Locales['tr'].spread_selection_title = 'Dizilim Seçimi'
Locales['tr'].spread_selection_confirm = 'Dizilimi Onayla'
Locales['tr'].spread_selection_waiting = 'Falcı dizilim seçiyor...'
Locales['tr'].spread_dealing = 'Kartlar masaya dağıtılıyor...'
Locales['tr'].nui_reveal_all = 'Tüm Kartları Aç'
Locales['tr'].player_selection_title = 'Kimin İçin Fal Bakılacak?'
Locales['tr'].player_selection_confirm = 'Davet Gönder'
Locales['tr'].player_selection_empty = 'Yakınında oyuncu bulunamadı.'
Locales['tr'].player_selection_solo = 'Kendin İçin Aç'
