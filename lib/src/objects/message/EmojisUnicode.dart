part of nyxx;

/// List of all Unicode Emojis (not really) :D
/// Class contains 1200+ emojis which has unicode hex value and shortcode.
class EmojisUnicode {
  /// Returns [Emoji] based on shortcode (eg. ":smile:")
  /// This method can be slow(extremely slow), because it uses mirrors to lookup for matching property in class.
  /// In future it will be rewritten to map.
  Future<UnicodeEmoji> fromShortCode(String shortCode) {
    return new Future(() {
      String normalize(String s) {
        if (s.startsWith(":") && s.endsWith(":")) return s;
        return ":$s:";
      }
      
      shortCode = normalize(shortCode);
      var mirror = reflectClass(EmojisUnicode);
      for (var v in mirror.declarations.values) {
        if (v is UnicodeEmoji) {
          var emoji = v as UnicodeEmoji;
          if (emoji.code == shortCode) return emoji;
        }
      }

      return null;
    });
  }

  static final UnicodeEmoji joy = new UnicodeEmoji._new("1f602", ":joy:");
  static final UnicodeEmoji heart = new UnicodeEmoji._new("2764", ":heart:");
  static final UnicodeEmoji heart_eyes =
      new UnicodeEmoji._new("1f60d", ":heart_eyes:");
  static final UnicodeEmoji sob = new UnicodeEmoji._new("1f62d", ":sob:");
  static final UnicodeEmoji blush = new UnicodeEmoji._new("1f60a", ":blush:");
  static final UnicodeEmoji unamused =
      new UnicodeEmoji._new("1f612", ":unamused:");
  static final UnicodeEmoji kissing_heart =
      new UnicodeEmoji._new("1f618", ":kissing_heart:");
  static final UnicodeEmoji two_hearts =
      new UnicodeEmoji._new("1f495", ":two_hearts:");
  static final UnicodeEmoji weary = new UnicodeEmoji._new("1f629", ":weary:");
  static final UnicodeEmoji ok_hand =
      new UnicodeEmoji._new("1f44c", ":ok_hand:");
  static final UnicodeEmoji pensive =
      new UnicodeEmoji._new("1f614", ":pensive:");
  static final UnicodeEmoji smirk = new UnicodeEmoji._new("1f60f", ":smirk:");
  static final UnicodeEmoji grin = new UnicodeEmoji._new("1f601", ":grin:");
  static final UnicodeEmoji recycle =
      new UnicodeEmoji._new("267b", ":recycle:");
  static final UnicodeEmoji wink = new UnicodeEmoji._new("1f609", ":wink:");
  static final UnicodeEmoji thumbsup =
      new UnicodeEmoji._new("1f44d", ":thumbsup:");
  static final UnicodeEmoji pray = new UnicodeEmoji._new("1f64f", ":pray:");
  static final UnicodeEmoji relieved =
      new UnicodeEmoji._new("1f60c", ":relieved:");
  static final UnicodeEmoji notes = new UnicodeEmoji._new("1f3b6", ":notes:");
  static final UnicodeEmoji flushed =
      new UnicodeEmoji._new("1f633", ":flushed:");
  static final UnicodeEmoji raised_hands =
      new UnicodeEmoji._new("1f64c", ":raised_hands:");
  static final UnicodeEmoji see_no_evil =
      new UnicodeEmoji._new("1f648", ":see_no_evil:");
  static final UnicodeEmoji cry = new UnicodeEmoji._new("1f622", ":cry:");
  static final UnicodeEmoji sunglasses =
      new UnicodeEmoji._new("1f60e", ":sunglasses:");
  static final UnicodeEmoji v = new UnicodeEmoji._new("270c", ":v:");
  static final UnicodeEmoji eyes = new UnicodeEmoji._new("1f440", ":eyes:");
  static final UnicodeEmoji sweat_smile =
      new UnicodeEmoji._new("1f605", ":sweat_smile:");
  static final UnicodeEmoji sparkles =
      new UnicodeEmoji._new("2728", ":sparkles:");
  static final UnicodeEmoji sleeping =
      new UnicodeEmoji._new("1f634", ":sleeping:");
  static final UnicodeEmoji smile = new UnicodeEmoji._new("1f604", ":smile:");
  static final UnicodeEmoji purple_heart =
      new UnicodeEmoji._new("1f49c", ":purple_heart:");
  static final UnicodeEmoji broken_heart =
      new UnicodeEmoji._new("1f494", ":broken_heart:");
  static final UnicodeEmoji expressionless =
      new UnicodeEmoji._new("1f611", ":expressionless:");
  static final UnicodeEmoji sparkling_heart =
      new UnicodeEmoji._new("1f496", ":sparkling_heart:");
  static final UnicodeEmoji blue_heart =
      new UnicodeEmoji._new("1f499", ":blue_heart:");
  static final UnicodeEmoji confused =
      new UnicodeEmoji._new("1f615", ":confused:");
  static final UnicodeEmoji information_desk_person =
      new UnicodeEmoji._new("1f481", ":information_desk_person:");
  static final UnicodeEmoji stuck_out_tongue_winking_eye =
      new UnicodeEmoji._new("1f61c", ":stuck_out_tongue_winking_eye:");
  static final UnicodeEmoji disappointed =
      new UnicodeEmoji._new("1f61e", ":disappointed:");
  static final UnicodeEmoji yum = new UnicodeEmoji._new("1f60b", ":yum:");
  static final UnicodeEmoji neutral_face =
      new UnicodeEmoji._new("1f610", ":neutral_face:");
  static final UnicodeEmoji sleepy = new UnicodeEmoji._new("1f62a", ":sleepy:");
  static final UnicodeEmoji clap = new UnicodeEmoji._new("1f44f", ":clap:");
  static final UnicodeEmoji cupid = new UnicodeEmoji._new("1f498", ":cupid:");
  static final UnicodeEmoji heartpulse =
      new UnicodeEmoji._new("1f497", ":heartpulse:");
  static final UnicodeEmoji revolving_hearts =
      new UnicodeEmoji._new("1f49e", ":revolving_hearts:");
  static final UnicodeEmoji arrow_left =
      new UnicodeEmoji._new("2b05", ":arrow_left:");
  static final UnicodeEmoji speak_no_evil =
      new UnicodeEmoji._new("1f64a", ":speak_no_evil:");
  static final UnicodeEmoji kiss = new UnicodeEmoji._new("1f48b", ":kiss:");
  static final UnicodeEmoji point_right =
      new UnicodeEmoji._new("1f449", ":point_right:");
  static final UnicodeEmoji cherry_blossom =
      new UnicodeEmoji._new("1f338", ":cherry_blossom:");
  static final UnicodeEmoji scream = new UnicodeEmoji._new("1f631", ":scream:");
  static final UnicodeEmoji fire = new UnicodeEmoji._new("1f525", ":fire:");
  static final UnicodeEmoji rage = new UnicodeEmoji._new("1f621", ":rage:");
  static final UnicodeEmoji smiley = new UnicodeEmoji._new("1f603", ":smiley:");
  static final UnicodeEmoji tada = new UnicodeEmoji._new("1f389", ":tada:");
  static final UnicodeEmoji tired_face =
      new UnicodeEmoji._new("1f62b", ":tired_face:");
  static final UnicodeEmoji camera = new UnicodeEmoji._new("1f4f7", ":camera:");
  static final UnicodeEmoji rose = new UnicodeEmoji._new("1f339", ":rose:");
  static final UnicodeEmoji stuck_out_tongue_closed_eyes =
      new UnicodeEmoji._new("1f61d", ":stuck_out_tongue_closed_eyes:");
  static final UnicodeEmoji muscle = new UnicodeEmoji._new("1f4aa", ":muscle:");
  static final UnicodeEmoji skull = new UnicodeEmoji._new("1f480", ":skull:");
  static final UnicodeEmoji sunny = new UnicodeEmoji._new("2600", ":sunny:");
  static final UnicodeEmoji yellow_heart =
      new UnicodeEmoji._new("1f49b", ":yellow_heart:");
  static final UnicodeEmoji triumph =
      new UnicodeEmoji._new("1f624", ":triumph:");
  static final UnicodeEmoji new_moon_with_face =
      new UnicodeEmoji._new("1f31a", ":new_moon_with_face:");
  static final UnicodeEmoji laughing =
      new UnicodeEmoji._new("1f606", ":laughing:");
  static final UnicodeEmoji sweat = new UnicodeEmoji._new("1f613", ":sweat:");
  static final UnicodeEmoji point_left =
      new UnicodeEmoji._new("1f448", ":point_left:");
  static final UnicodeEmoji heavy_check_mark =
      new UnicodeEmoji._new("2714", ":heavy_check_mark:");
  static final UnicodeEmoji heart_eyes_cat =
      new UnicodeEmoji._new("1f63b", ":heart_eyes_cat:");
  static final UnicodeEmoji grinning =
      new UnicodeEmoji._new("1f600", ":grinning:");
  static final UnicodeEmoji mask = new UnicodeEmoji._new("1f637", ":mask:");
  static final UnicodeEmoji green_heart =
      new UnicodeEmoji._new("1f49a", ":green_heart:");
  static final UnicodeEmoji wave = new UnicodeEmoji._new("1f44b", ":wave:");
  static final UnicodeEmoji persevere =
      new UnicodeEmoji._new("1f623", ":persevere:");
  static final UnicodeEmoji heartbeat =
      new UnicodeEmoji._new("1f493", ":heartbeat:");
  static final UnicodeEmoji arrow_forward =
      new UnicodeEmoji._new("25b6", ":arrow_forward:");
  static final UnicodeEmoji arrow_backward =
      new UnicodeEmoji._new("25c0", ":arrow_backward:");
  static final UnicodeEmoji arrow_right_hook =
      new UnicodeEmoji._new("21aa", ":arrow_right_hook:");
  static final UnicodeEmoji leftwards_arrow_with_hook =
      new UnicodeEmoji._new("21a9", ":leftwards_arrow_with_hook:");
  static final UnicodeEmoji crown = new UnicodeEmoji._new("1f451", ":crown:");
  static final UnicodeEmoji kissing_closed_eyes =
      new UnicodeEmoji._new("1f61a", ":kissing_closed_eyes:");
  static final UnicodeEmoji stuck_out_tongue =
      new UnicodeEmoji._new("1f61b", ":stuck_out_tongue:");
  static final UnicodeEmoji disappointed_relieved =
      new UnicodeEmoji._new("1f625", ":disappointed_relieved:");
  static final UnicodeEmoji innocent =
      new UnicodeEmoji._new("1f607", ":innocent:");
  static final UnicodeEmoji headphones =
      new UnicodeEmoji._new("1f3a7", ":headphones:");
  static final UnicodeEmoji white_check_mark =
      new UnicodeEmoji._new("2705", ":white_check_mark:");
  static final UnicodeEmoji confounded =
      new UnicodeEmoji._new("1f616", ":confounded:");
  static final UnicodeEmoji arrow_right =
      new UnicodeEmoji._new("27a1", ":arrow_right:");
  static final UnicodeEmoji angry = new UnicodeEmoji._new("1f620", ":angry:");
  static final UnicodeEmoji grimacing =
      new UnicodeEmoji._new("1f62c", ":grimacing:");
  static final UnicodeEmoji star2 = new UnicodeEmoji._new("1f31f", ":star2:");
  static final UnicodeEmoji gun = new UnicodeEmoji._new("1f52b", ":gun:");
  static final UnicodeEmoji raising_hand =
      new UnicodeEmoji._new("1f64b", ":raising_hand:");
  static final UnicodeEmoji thumbsdown =
      new UnicodeEmoji._new("1f44e", ":thumbsdown:");
  static final UnicodeEmoji dancer = new UnicodeEmoji._new("1f483", ":dancer:");
  static final UnicodeEmoji musical_note =
      new UnicodeEmoji._new("1f3b5", ":musical_note:");
  static final UnicodeEmoji no_mouth =
      new UnicodeEmoji._new("1f636", ":no_mouth:");
  static final UnicodeEmoji dizzy = new UnicodeEmoji._new("1f4ab", ":dizzy:");
  static final UnicodeEmoji fist = new UnicodeEmoji._new("270a", ":fist:");
  static final UnicodeEmoji point_down =
      new UnicodeEmoji._new("1f447", ":point_down:");
  static final UnicodeEmoji red_circle =
      new UnicodeEmoji._new("1f534", ":red_circle:");
  static final UnicodeEmoji no_good =
      new UnicodeEmoji._new("1f645", ":no_good:");
  static final UnicodeEmoji boom = new UnicodeEmoji._new("1f4a5", ":boom:");
  static final UnicodeEmoji thought_balloon =
      new UnicodeEmoji._new("1f4ad", ":thought_balloon:");
  static final UnicodeEmoji tongue = new UnicodeEmoji._new("1f445", ":tongue:");
  static final UnicodeEmoji cold_sweat =
      new UnicodeEmoji._new("1f630", ":cold_sweat:");
  static final UnicodeEmoji gem = new UnicodeEmoji._new("1f48e", ":gem:");
  static final UnicodeEmoji ok_woman =
      new UnicodeEmoji._new("1f646", ":ok_woman:");
  static final UnicodeEmoji pizza = new UnicodeEmoji._new("1f355", ":pizza:");
  static final UnicodeEmoji joy_cat =
      new UnicodeEmoji._new("1f639", ":joy_cat:");
  static final UnicodeEmoji sun_with_face =
      new UnicodeEmoji._new("1f31e", ":sun_with_face:");
  static final UnicodeEmoji leaves = new UnicodeEmoji._new("1f343", ":leaves:");
  static final UnicodeEmoji sweat_drops =
      new UnicodeEmoji._new("1f4a6", ":sweat_drops:");
  static final UnicodeEmoji penguin =
      new UnicodeEmoji._new("1f427", ":penguin:");
  static final UnicodeEmoji zzz = new UnicodeEmoji._new("1f4a4", ":zzz:");
  static final UnicodeEmoji walking =
      new UnicodeEmoji._new("1f6b6", ":walking:");
  static final UnicodeEmoji airplane =
      new UnicodeEmoji._new("2708", ":airplane:");
  static final UnicodeEmoji balloon =
      new UnicodeEmoji._new("1f388", ":balloon:");
  static final UnicodeEmoji star = new UnicodeEmoji._new("2b50", ":star:");
  static final UnicodeEmoji ribbon = new UnicodeEmoji._new("1f380", ":ribbon:");
  static final UnicodeEmoji ballot_box_with_check =
      new UnicodeEmoji._new("2611", ":ballot_box_with_check:");
  static final UnicodeEmoji worried =
      new UnicodeEmoji._new("1f61f", ":worried:");
  static final UnicodeEmoji underage =
      new UnicodeEmoji._new("1f51e", ":underage:");
  static final UnicodeEmoji fearful =
      new UnicodeEmoji._new("1f628", ":fearful:");
  static final UnicodeEmoji four_leaf_clover =
      new UnicodeEmoji._new("1f340", ":four_leaf_clover:");
  static final UnicodeEmoji hibiscus =
      new UnicodeEmoji._new("1f33a", ":hibiscus:");
  static final UnicodeEmoji microphone =
      new UnicodeEmoji._new("1f3a4", ":microphone:");
  static final UnicodeEmoji open_hands =
      new UnicodeEmoji._new("1f450", ":open_hands:");
  static final UnicodeEmoji ghost = new UnicodeEmoji._new("1f47b", ":ghost:");
  static final UnicodeEmoji palm_tree =
      new UnicodeEmoji._new("1f334", ":palm_tree:");
  static final UnicodeEmoji bangbang =
      new UnicodeEmoji._new("203c", ":bangbang:");
  static final UnicodeEmoji nail_care =
      new UnicodeEmoji._new("1f485", ":nail_care:");
  static final UnicodeEmoji x = new UnicodeEmoji._new("274c", ":x:");
  static final UnicodeEmoji alien = new UnicodeEmoji._new("1f47d", ":alien:");
  static final UnicodeEmoji bow = new UnicodeEmoji._new("1f647", ":bow:");
  static final UnicodeEmoji cloud = new UnicodeEmoji._new("2601", ":cloud:");
  static final UnicodeEmoji soccer = new UnicodeEmoji._new("26bd", ":soccer:");
  static final UnicodeEmoji angel = new UnicodeEmoji._new("1f47c", ":angel:");
  static final UnicodeEmoji dancers =
      new UnicodeEmoji._new("1f46f", ":dancers:");
  static final UnicodeEmoji exclamation =
      new UnicodeEmoji._new("2757", ":exclamation:");
  static final UnicodeEmoji snowflake =
      new UnicodeEmoji._new("2744", ":snowflake:");
  static final UnicodeEmoji point_up =
      new UnicodeEmoji._new("261d", ":point_up:");
  static final UnicodeEmoji kissing_smiling_eyes =
      new UnicodeEmoji._new("1f619", ":kissing_smiling_eyes:");
  static final UnicodeEmoji rainbow =
      new UnicodeEmoji._new("1f308", ":rainbow:");
  static final UnicodeEmoji crescent_moon =
      new UnicodeEmoji._new("1f319", ":crescent_moon:");
  static final UnicodeEmoji heart_decoration =
      new UnicodeEmoji._new("1f49f", ":heart_decoration:");
  static final UnicodeEmoji gift_heart =
      new UnicodeEmoji._new("1f49d", ":gift_heart:");
  static final UnicodeEmoji gift = new UnicodeEmoji._new("1f381", ":gift:");
  static final UnicodeEmoji beers = new UnicodeEmoji._new("1f37b", ":beers:");
  static final UnicodeEmoji anguished =
      new UnicodeEmoji._new("1f627", ":anguished:");
  static final UnicodeEmoji earth_africa =
      new UnicodeEmoji._new("1f30d", ":earth_africa:");
  static final UnicodeEmoji movie_camera =
      new UnicodeEmoji._new("1f3a5", ":movie_camera:");
  static final UnicodeEmoji anchor = new UnicodeEmoji._new("2693", ":anchor:");
  static final UnicodeEmoji zap = new UnicodeEmoji._new("26a1", ":zap:");
  static final UnicodeEmoji heavy_multiplication_x =
      new UnicodeEmoji._new("2716", ":heavy_multiplication_x:");
  static final UnicodeEmoji runner = new UnicodeEmoji._new("1f3c3", ":runner:");
  static final UnicodeEmoji sunflower =
      new UnicodeEmoji._new("1f33b", ":sunflower:");
  static final UnicodeEmoji earth_americas =
      new UnicodeEmoji._new("1f30e", ":earth_americas:");
  static final UnicodeEmoji bouquet =
      new UnicodeEmoji._new("1f490", ":bouquet:");
  static final UnicodeEmoji dog = new UnicodeEmoji._new("1f436", ":dog:");
  static final UnicodeEmoji moneybag =
      new UnicodeEmoji._new("1f4b0", ":moneybag:");
  static final UnicodeEmoji herb = new UnicodeEmoji._new("1f33f", ":herb:");
  static final UnicodeEmoji couple = new UnicodeEmoji._new("1f46b", ":couple:");
  static final UnicodeEmoji fallen_leaf =
      new UnicodeEmoji._new("1f342", ":fallen_leaf:");
  static final UnicodeEmoji tulip = new UnicodeEmoji._new("1f337", ":tulip:");
  static final UnicodeEmoji birthday =
      new UnicodeEmoji._new("1f382", ":birthday:");
  static final UnicodeEmoji cat = new UnicodeEmoji._new("1f431", ":cat:");
  static final UnicodeEmoji coffee = new UnicodeEmoji._new("2615", ":coffee:");
  static final UnicodeEmoji dizzy_face =
      new UnicodeEmoji._new("1f635", ":dizzy_face:");
  static final UnicodeEmoji point_up_2 =
      new UnicodeEmoji._new("1f446", ":point_up_2:");
  static final UnicodeEmoji open_mouth =
      new UnicodeEmoji._new("1f62e", ":open_mouth:");
  static final UnicodeEmoji hushed = new UnicodeEmoji._new("1f62f", ":hushed:");
  static final UnicodeEmoji basketball =
      new UnicodeEmoji._new("1f3c0", ":basketball:");
  static final UnicodeEmoji christmas_tree =
      new UnicodeEmoji._new("1f384", ":christmas_tree:");
  static final UnicodeEmoji ring = new UnicodeEmoji._new("1f48d", ":ring:");
  static final UnicodeEmoji full_moon_with_face =
      new UnicodeEmoji._new("1f31d", ":full_moon_with_face:");
  static final UnicodeEmoji astonished =
      new UnicodeEmoji._new("1f632", ":astonished:");
  static final UnicodeEmoji two_women_holding_hands =
      new UnicodeEmoji._new("1f46d", ":two_women_holding_hands:");
  static final UnicodeEmoji money_with_wings =
      new UnicodeEmoji._new("1f4b8", ":money_with_wings:");
  static final UnicodeEmoji crying_cat_face =
      new UnicodeEmoji._new("1f63f", ":crying_cat_face:");
  static final UnicodeEmoji hear_no_evil =
      new UnicodeEmoji._new("1f649", ":hear_no_evil:");
  static final UnicodeEmoji dash = new UnicodeEmoji._new("1f4a8", ":dash:");
  static final UnicodeEmoji cactus = new UnicodeEmoji._new("1f335", ":cactus:");
  static final UnicodeEmoji hotsprings =
      new UnicodeEmoji._new("2668", ":hotsprings:");
  static final UnicodeEmoji telephone =
      new UnicodeEmoji._new("260e", ":telephone:");
  static final UnicodeEmoji maple_leaf =
      new UnicodeEmoji._new("1f341", ":maple_leaf:");
  static final UnicodeEmoji princess =
      new UnicodeEmoji._new("1f478", ":princess:");
  static final UnicodeEmoji massage =
      new UnicodeEmoji._new("1f486", ":massage:");
  static final UnicodeEmoji love_letter =
      new UnicodeEmoji._new("1f48c", ":love_letter:");
  static final UnicodeEmoji trophy = new UnicodeEmoji._new("1f3c6", ":trophy:");
  static final UnicodeEmoji person_frowning =
      new UnicodeEmoji._new("1f64d", ":person_frowning:");
  static final UnicodeEmoji confetti_ball =
      new UnicodeEmoji._new("1f38a", ":confetti_ball:");
  static final UnicodeEmoji blossom =
      new UnicodeEmoji._new("1f33c", ":blossom:");
  static final UnicodeEmoji lips = new UnicodeEmoji._new("1f444", ":lips:");
  static final UnicodeEmoji fries = new UnicodeEmoji._new("1f35f", ":fries:");
  static final UnicodeEmoji doughnut =
      new UnicodeEmoji._new("1f369", ":doughnut:");
  static final UnicodeEmoji frowning =
      new UnicodeEmoji._new("1f626", ":frowning:");
  static final UnicodeEmoji ocean = new UnicodeEmoji._new("1f30a", ":ocean:");
  static final UnicodeEmoji bomb = new UnicodeEmoji._new("1f4a3", ":bomb:");
  static final UnicodeEmoji ok = new UnicodeEmoji._new("1f197", ":ok:");
  static final UnicodeEmoji cyclone =
      new UnicodeEmoji._new("1f300", ":cyclone:");
  static final UnicodeEmoji rocket = new UnicodeEmoji._new("1f680", ":rocket:");
  static final UnicodeEmoji umbrella =
      new UnicodeEmoji._new("2614", ":umbrella:");
  static final UnicodeEmoji couplekiss =
      new UnicodeEmoji._new("1f48f", ":couplekiss:");
  static final UnicodeEmoji couple_with_heart =
      new UnicodeEmoji._new("1f491", ":couple_with_heart:");
  static final UnicodeEmoji lollipop =
      new UnicodeEmoji._new("1f36d", ":lollipop:");
  static final UnicodeEmoji clapper =
      new UnicodeEmoji._new("1f3ac", ":clapper:");
  static final UnicodeEmoji pig = new UnicodeEmoji._new("1f437", ":pig:");
  static final UnicodeEmoji smiling_imp =
      new UnicodeEmoji._new("1f608", ":smiling_imp:");
  static final UnicodeEmoji imp = new UnicodeEmoji._new("1f47f", ":imp:");
  static final UnicodeEmoji bee = new UnicodeEmoji._new("1f41d", ":bee:");
  static final UnicodeEmoji kissing_cat =
      new UnicodeEmoji._new("1f63d", ":kissing_cat:");
  static final UnicodeEmoji anger = new UnicodeEmoji._new("1f4a2", ":anger:");
  static final UnicodeEmoji musical_score =
      new UnicodeEmoji._new("1f3bc", ":musical_score:");
  static final UnicodeEmoji santa = new UnicodeEmoji._new("1f385", ":santa:");
  static final UnicodeEmoji earth_asia =
      new UnicodeEmoji._new("1f30f", ":earth_asia:");
  static final UnicodeEmoji football =
      new UnicodeEmoji._new("1f3c8", ":football:");
  static final UnicodeEmoji guitar = new UnicodeEmoji._new("1f3b8", ":guitar:");
  static final UnicodeEmoji panda_face =
      new UnicodeEmoji._new("1f43c", ":panda_face:");
  static final UnicodeEmoji speech_balloon =
      new UnicodeEmoji._new("1f4ac", ":speech_balloon:");
  static final UnicodeEmoji strawberry =
      new UnicodeEmoji._new("1f353", ":strawberry:");
  static final UnicodeEmoji smirk_cat =
      new UnicodeEmoji._new("1f63c", ":smirk_cat:");
  static final UnicodeEmoji banana = new UnicodeEmoji._new("1f34c", ":banana:");
  static final UnicodeEmoji watermelon =
      new UnicodeEmoji._new("1f349", ":watermelon:");
  static final UnicodeEmoji snowman =
      new UnicodeEmoji._new("26c4", ":snowman:");
  static final UnicodeEmoji smile_cat =
      new UnicodeEmoji._new("1f638", ":smile_cat:");
  static final UnicodeEmoji top = new UnicodeEmoji._new("1f51d", ":top:");
  static final UnicodeEmoji eggplant =
      new UnicodeEmoji._new("1f346", ":eggplant:");
  static final UnicodeEmoji crystal_ball =
      new UnicodeEmoji._new("1f52e", ":crystal_ball:");
  static final UnicodeEmoji fork_and_knife =
      new UnicodeEmoji._new("1f374", ":fork_and_knife:");
  static final UnicodeEmoji calling =
      new UnicodeEmoji._new("1f4f2", ":calling:");
  static final UnicodeEmoji iphone = new UnicodeEmoji._new("1f4f1", ":iphone:");
  static final UnicodeEmoji partly_sunny =
      new UnicodeEmoji._new("26c5", ":partly_sunny:");
  static final UnicodeEmoji warning =
      new UnicodeEmoji._new("26a0", ":warning:");
  static final UnicodeEmoji scream_cat =
      new UnicodeEmoji._new("1f640", ":scream_cat:");
  static final UnicodeEmoji small_orange_diamond =
      new UnicodeEmoji._new("1f538", ":small_orange_diamond:");
  static final UnicodeEmoji baby = new UnicodeEmoji._new("1f476", ":baby:");
  static final UnicodeEmoji feet = new UnicodeEmoji._new("1f43e", ":feet:");
  static final UnicodeEmoji footprints =
      new UnicodeEmoji._new("1f463", ":footprints:");
  static final UnicodeEmoji beer = new UnicodeEmoji._new("1f37a", ":beer:");
  static final UnicodeEmoji wine_glass =
      new UnicodeEmoji._new("1f377", ":wine_glass:");
  static final UnicodeEmoji o = new UnicodeEmoji._new("2b55", ":o:");
  static final UnicodeEmoji video_camera =
      new UnicodeEmoji._new("1f4f9", ":video_camera:");
  static final UnicodeEmoji rabbit = new UnicodeEmoji._new("1f430", ":rabbit:");
  static final UnicodeEmoji tropical_drink =
      new UnicodeEmoji._new("1f379", ":tropical_drink:");
  static final UnicodeEmoji smoking =
      new UnicodeEmoji._new("1f6ac", ":smoking:");
  static final UnicodeEmoji space_invader =
      new UnicodeEmoji._new("1f47e", ":space_invader:");
  static final UnicodeEmoji peach = new UnicodeEmoji._new("1f351", ":peach:");
  static final UnicodeEmoji snake = new UnicodeEmoji._new("1f40d", ":snake:");
  static final UnicodeEmoji turtle = new UnicodeEmoji._new("1f422", ":turtle:");
  static final UnicodeEmoji cherries =
      new UnicodeEmoji._new("1f352", ":cherries:");
  static final UnicodeEmoji kissing =
      new UnicodeEmoji._new("1f617", ":kissing:");
  static final UnicodeEmoji frog = new UnicodeEmoji._new("1f438", ":frog:");
  static final UnicodeEmoji milky_way =
      new UnicodeEmoji._new("1f30c", ":milky_way:");
  static final UnicodeEmoji rotating_light =
      new UnicodeEmoji._new("1f6a8", ":rotating_light:");
  static final UnicodeEmoji hatching_chick =
      new UnicodeEmoji._new("1f423", ":hatching_chick:");
  static final UnicodeEmoji closed_book =
      new UnicodeEmoji._new("1f4d5", ":closed_book:");
  static final UnicodeEmoji candy = new UnicodeEmoji._new("1f36c", ":candy:");
  static final UnicodeEmoji hamburger =
      new UnicodeEmoji._new("1f354", ":hamburger:");
  static final UnicodeEmoji bear = new UnicodeEmoji._new("1f43b", ":bear:");
  static final UnicodeEmoji tiger = new UnicodeEmoji._new("1f42f", ":tiger:");
  static final UnicodeEmoji fast_forward =
      new UnicodeEmoji._new("2.3E+10", ":fast_forward:");
  static final UnicodeEmoji icecream =
      new UnicodeEmoji._new("1f366", ":icecream:");
  static final UnicodeEmoji pineapple =
      new UnicodeEmoji._new("1f34d", ":pineapple:");
  static final UnicodeEmoji ear_of_rice =
      new UnicodeEmoji._new("1f33e", ":ear_of_rice:");
  static final UnicodeEmoji syringe =
      new UnicodeEmoji._new("1f489", ":syringe:");
  static final UnicodeEmoji put_litter_in_its_place =
      new UnicodeEmoji._new("1f6ae", ":put_litter_in_its_place:");
  static final UnicodeEmoji chocolate_bar =
      new UnicodeEmoji._new("1f36b", ":chocolate_bar:");
  static final UnicodeEmoji black_small_square =
      new UnicodeEmoji._new("25aa", ":black_small_square:");
  static final UnicodeEmoji tv = new UnicodeEmoji._new("1f4fa", ":tv:");
  static final UnicodeEmoji pill = new UnicodeEmoji._new("1f48a", ":pill:");
  static final UnicodeEmoji octopus =
      new UnicodeEmoji._new("1f419", ":octopus:");
  static final UnicodeEmoji jack_o_lantern =
      new UnicodeEmoji._new("1f383", ":jack_o_lantern:");
  static final UnicodeEmoji grapes = new UnicodeEmoji._new("1f347", ":grapes:");
  static final UnicodeEmoji smiley_cat =
      new UnicodeEmoji._new("1f63a", ":smiley_cat:");
  static final UnicodeEmoji cd = new UnicodeEmoji._new("1f4bf", ":cd:");
  static final UnicodeEmoji cocktail =
      new UnicodeEmoji._new("1f378", ":cocktail:");
  static final UnicodeEmoji cake = new UnicodeEmoji._new("1f370", ":cake:");
  static final UnicodeEmoji video_game =
      new UnicodeEmoji._new("1f3ae", ":video_game:");
  static final UnicodeEmoji arrow_down =
      new UnicodeEmoji._new("2b07", ":arrow_down:");
  static final UnicodeEmoji no_entry_sign =
      new UnicodeEmoji._new("1f6ab", ":no_entry_sign:");
  static final UnicodeEmoji lipstick =
      new UnicodeEmoji._new("1f484", ":lipstick:");
  static final UnicodeEmoji whale = new UnicodeEmoji._new("1f433", ":whale:");
  static final UnicodeEmoji cookie = new UnicodeEmoji._new("1f36a", ":cookie:");
  static final UnicodeEmoji dolphin =
      new UnicodeEmoji._new("1f42c", ":dolphin:");
  static final UnicodeEmoji loud_sound =
      new UnicodeEmoji._new("1f50a", ":loud_sound:");
  static final UnicodeEmoji man = new UnicodeEmoji._new("1f468", ":man:");
  static final UnicodeEmoji hatched_chick =
      new UnicodeEmoji._new("1f425", ":hatched_chick:");
  static final UnicodeEmoji monkey = new UnicodeEmoji._new("1f412", ":monkey:");
  static final UnicodeEmoji books = new UnicodeEmoji._new("1f4da", ":books:");
  static final UnicodeEmoji japanese_ogre =
      new UnicodeEmoji._new("1f479", ":japanese_ogre:");
  static final UnicodeEmoji guardsman =
      new UnicodeEmoji._new("1f482", ":guardsman:");
  static final UnicodeEmoji loudspeaker =
      new UnicodeEmoji._new("1f4e2", ":loudspeaker:");
  static final UnicodeEmoji scissors =
      new UnicodeEmoji._new("2702", ":scissors:");
  static final UnicodeEmoji girl = new UnicodeEmoji._new("1f467", ":girl:");
  static final UnicodeEmoji mortar_board =
      new UnicodeEmoji._new("1f393", ":mortar_board:");
  static final UnicodeEmoji France = new UnicodeEmoji._new("1f1eb", ":fr:");
  static final UnicodeEmoji baseball =
      new UnicodeEmoji._new("26be", ":baseball:");
  static final UnicodeEmoji vertical_traffic_light =
      new UnicodeEmoji._new("1f6a6", ":vertical_traffic_light:");
  static final UnicodeEmoji woman = new UnicodeEmoji._new("1f469", ":woman:");
  static final UnicodeEmoji fireworks =
      new UnicodeEmoji._new("1f386", ":fireworks:");
  static final UnicodeEmoji stars = new UnicodeEmoji._new("1f320", ":stars:");
  static final UnicodeEmoji sos = new UnicodeEmoji._new("1f198", ":sos:");
  static final UnicodeEmoji mushroom =
      new UnicodeEmoji._new("1f344", ":mushroom:");
  static final UnicodeEmoji pouting_cat =
      new UnicodeEmoji._new("1f63e", ":pouting_cat:");
  static final UnicodeEmoji left_luggage =
      new UnicodeEmoji._new("1f6c5", ":left_luggage:");
  static final UnicodeEmoji high_heel =
      new UnicodeEmoji._new("1f460", ":high_heel:");
  static final UnicodeEmoji dart = new UnicodeEmoji._new("1f3af", ":dart:");
  static final UnicodeEmoji swimmer =
      new UnicodeEmoji._new("1f3ca", ":swimmer:");
  static final UnicodeEmoji key = new UnicodeEmoji._new("1f511", ":key:");
  static final UnicodeEmoji bikini = new UnicodeEmoji._new("1f459", ":bikini:");
  static final UnicodeEmoji family = new UnicodeEmoji._new("1f46a", ":family:");
  static final UnicodeEmoji pencil2 =
      new UnicodeEmoji._new("270f", ":pencil2:");
  static final UnicodeEmoji elephant =
      new UnicodeEmoji._new("1f418", ":elephant:");
  static final UnicodeEmoji droplet =
      new UnicodeEmoji._new("1f4a7", ":droplet:");
  static final UnicodeEmoji seedling =
      new UnicodeEmoji._new("1f331", ":seedling:");
  static final UnicodeEmoji apple = new UnicodeEmoji._new("1f34e", ":apple:");
  static final UnicodeEmoji cool = new UnicodeEmoji._new("1f192", ":cool:");
  static final UnicodeEmoji telephone_receiver =
      new UnicodeEmoji._new("1f4de", ":telephone_receiver:");
  static final UnicodeEmoji dollar = new UnicodeEmoji._new("1f4b5", ":dollar:");
  static final UnicodeEmoji house_with_garden =
      new UnicodeEmoji._new("1f3e1", ":house_with_garden:");
  static final UnicodeEmoji book = new UnicodeEmoji._new("1f4d6", ":book:");
  static final UnicodeEmoji haircut =
      new UnicodeEmoji._new("1f487", ":haircut:");
  static final UnicodeEmoji computer =
      new UnicodeEmoji._new("1f4bb", ":computer:");
  static final UnicodeEmoji bulb = new UnicodeEmoji._new("1f4a1", ":bulb:");
  static final UnicodeEmoji question =
      new UnicodeEmoji._new("2753", ":question:");
  static final UnicodeEmoji back = new UnicodeEmoji._new("1f519", ":back:");
  static final UnicodeEmoji boy = new UnicodeEmoji._new("1f466", ":boy:");
  static final UnicodeEmoji closed_lock_with_key =
      new UnicodeEmoji._new("1f510", ":closed_lock_with_key:");
  static final UnicodeEmoji person_with_pouting_face =
      new UnicodeEmoji._new("1f64e", ":person_with_pouting_face:");
  static final UnicodeEmoji tangerine =
      new UnicodeEmoji._new("1f34a", ":tangerine:");
  static final UnicodeEmoji sunrise =
      new UnicodeEmoji._new("1f305", ":sunrise:");
  static final UnicodeEmoji poultry_leg =
      new UnicodeEmoji._new("1f357", ":poultry_leg:");
  static final UnicodeEmoji blue_circle =
      new UnicodeEmoji._new("1f535", ":blue_circle:");
  static final UnicodeEmoji oncoming_automobile =
      new UnicodeEmoji._new("1f698", ":oncoming_automobile:");
  static final UnicodeEmoji shaved_ice =
      new UnicodeEmoji._new("1f367", ":shaved_ice:");
  static final UnicodeEmoji bird = new UnicodeEmoji._new("1f426", ":bird:");
  static final UnicodeEmoji Great = new UnicodeEmoji._new("Britain", ":gb:");
  static final UnicodeEmoji first_quarter_moon_with_face =
      new UnicodeEmoji._new("1f31b", ":first_quarter_moon_with_face:");
  static final UnicodeEmoji eyeglasses =
      new UnicodeEmoji._new("1f453", ":eyeglasses:");
  static final UnicodeEmoji goat = new UnicodeEmoji._new("1f410", ":goat:");
  static final UnicodeEmoji night_with_stars =
      new UnicodeEmoji._new("1f303", ":night_with_stars:");
  static final UnicodeEmoji older_woman =
      new UnicodeEmoji._new("1f475", ":older_woman:");
  static final UnicodeEmoji black_circle =
      new UnicodeEmoji._new("26ab", ":black_circle:");
  static final UnicodeEmoji new_moon =
      new UnicodeEmoji._new("1f311", ":new_moon:");
  static final UnicodeEmoji two_men_holding_hands =
      new UnicodeEmoji._new("1f46c", ":two_men_holding_hands:");
  static final UnicodeEmoji white_circle =
      new UnicodeEmoji._new("26aa", ":white_circle:");
  static final UnicodeEmoji customs =
      new UnicodeEmoji._new("1f6c3", ":customs:");
  static final UnicodeEmoji tropical_fish =
      new UnicodeEmoji._new("1f420", ":tropical_fish:");
  static final UnicodeEmoji house = new UnicodeEmoji._new("1f3e0", ":house:");
  static final UnicodeEmoji arrows_clockwise =
      new UnicodeEmoji._new("1f503", ":arrows_clockwise:");
  static final UnicodeEmoji last_quarter_moon_with_face =
      new UnicodeEmoji._new("1f31c", ":last_quarter_moon_with_face:");
  static final UnicodeEmoji round_pushpin =
      new UnicodeEmoji._new("1f4cd", ":round_pushpin:");
  static final UnicodeEmoji full_moon =
      new UnicodeEmoji._new("1f315", ":full_moon:");
  static final UnicodeEmoji athletic_shoe =
      new UnicodeEmoji._new("1f45f", ":athletic_shoe:");
  static final UnicodeEmoji lemon = new UnicodeEmoji._new("1f34b", ":lemon:");
  static final UnicodeEmoji baby_bottle =
      new UnicodeEmoji._new("1f37c", ":baby_bottle:");
  static final UnicodeEmoji spaghetti =
      new UnicodeEmoji._new("1f35d", ":spaghetti:");
  static final UnicodeEmoji wind_chime =
      new UnicodeEmoji._new("1f390", ":wind_chime:");
  static final UnicodeEmoji fish_cake =
      new UnicodeEmoji._new("1f365", ":fish_cake:");
  static final UnicodeEmoji evergreen_tree =
      new UnicodeEmoji._new("1f332", ":evergreen_tree:");
  static final UnicodeEmoji up = new UnicodeEmoji._new("1f199", ":up:");
  static final UnicodeEmoji arrow_up =
      new UnicodeEmoji._new("2b06", ":arrow_up:");
  static final UnicodeEmoji arrow_upper_right =
      new UnicodeEmoji._new("2197", ":arrow_upper_right:");
  static final UnicodeEmoji arrow_lower_right =
      new UnicodeEmoji._new("2198", ":arrow_lower_right:");
  static final UnicodeEmoji arrow_lower_left =
      new UnicodeEmoji._new("2199", ":arrow_lower_left:");
  static final UnicodeEmoji performing_arts =
      new UnicodeEmoji._new("1f3ad", ":performing_arts:");
  static final UnicodeEmoji nose = new UnicodeEmoji._new("1f443", ":nose:");
  static final UnicodeEmoji pig_nose =
      new UnicodeEmoji._new("1f43d", ":pig_nose:");
  static final UnicodeEmoji fish = new UnicodeEmoji._new("1f41f", ":fish:");
  static final UnicodeEmoji man_with_turban =
      new UnicodeEmoji._new("1f473", ":man_with_turban:");
  static final UnicodeEmoji koala = new UnicodeEmoji._new("1f428", ":koala:");
  static final UnicodeEmoji ear = new UnicodeEmoji._new("1f442", ":ear:");
  static final UnicodeEmoji eight_spoked_asterisk =
      new UnicodeEmoji._new("2733", ":eight_spoked_asterisk:");
  static final UnicodeEmoji small_blue_diamond =
      new UnicodeEmoji._new("1f539", ":small_blue_diamond:");
  static final UnicodeEmoji shower = new UnicodeEmoji._new("1f6bf", ":shower:");
  static final UnicodeEmoji bug = new UnicodeEmoji._new("1f41b", ":bug:");
  static final UnicodeEmoji ramen = new UnicodeEmoji._new("1f35c", ":ramen:");
  static final UnicodeEmoji tophat = new UnicodeEmoji._new("1f3a9", ":tophat:");
  static final UnicodeEmoji bride_with_veil =
      new UnicodeEmoji._new("1f470", ":bride_with_veil:");
  static final UnicodeEmoji fuelpump =
      new UnicodeEmoji._new("26fd", ":fuelpump:");
  static final UnicodeEmoji checkered_flag =
      new UnicodeEmoji._new("1f3c1", ":checkered_flag:");
  static final UnicodeEmoji horse = new UnicodeEmoji._new("1f434", ":horse:");
  static final UnicodeEmoji watch = new UnicodeEmoji._new("231a", ":watch:");
  static final UnicodeEmoji monkey_face =
      new UnicodeEmoji._new("1f435", ":monkey_face:");
  static final UnicodeEmoji baby_symbol =
      new UnicodeEmoji._new("1f6bc", ":baby_symbol:");
  static final UnicodeEmoji new_ = new UnicodeEmoji._new("1f195", ":new:");
  static final UnicodeEmoji free = new UnicodeEmoji._new("1f193", ":free:");
  static final UnicodeEmoji sparkler =
      new UnicodeEmoji._new("1f387", ":sparkler:");
  static final UnicodeEmoji corn = new UnicodeEmoji._new("1f33d", ":corn:");
  static final UnicodeEmoji tennis = new UnicodeEmoji._new("1f3be", ":tennis:");
  static final UnicodeEmoji alarm_clock =
      new UnicodeEmoji._new("23f0", ":alarm_clock:");
  static final UnicodeEmoji battery =
      new UnicodeEmoji._new("1f50b", ":battery:");
  static final UnicodeEmoji grey_exclamation =
      new UnicodeEmoji._new("2755", ":grey_exclamation:");
  static final UnicodeEmoji wolf = new UnicodeEmoji._new("1f43a", ":wolf:");
  static final UnicodeEmoji moyai = new UnicodeEmoji._new("1f5ff", ":moyai:");
  static final UnicodeEmoji cow = new UnicodeEmoji._new("1f42e", ":cow:");
  static final UnicodeEmoji mega = new UnicodeEmoji._new("1f4e3", ":mega:");
  static final UnicodeEmoji older_man =
      new UnicodeEmoji._new("1f474", ":older_man:");
  static final UnicodeEmoji dress = new UnicodeEmoji._new("1f457", ":dress:");
  static final UnicodeEmoji link = new UnicodeEmoji._new("1f517", ":link:");
  static final UnicodeEmoji chicken =
      new UnicodeEmoji._new("1f414", ":chicken:");
  static final UnicodeEmoji whale2 = new UnicodeEmoji._new("1f40b", ":whale2:");
  static final UnicodeEmoji arrow_upper_left =
      new UnicodeEmoji._new("2196", ":arrow_upper_left:");
  static final UnicodeEmoji deciduous_tree =
      new UnicodeEmoji._new("1f333", ":deciduous_tree:");
  static final UnicodeEmoji bento = new UnicodeEmoji._new("1f371", ":bento:");
  static final UnicodeEmoji pushpin =
      new UnicodeEmoji._new("1f4cc", ":pushpin:");
  static final UnicodeEmoji soon = new UnicodeEmoji._new("1f51c", ":soon:");
  static final UnicodeEmoji repeat = new UnicodeEmoji._new("1f501", ":repeat:");
  static final UnicodeEmoji dragon = new UnicodeEmoji._new("1f409", ":dragon:");
  static final UnicodeEmoji hamster =
      new UnicodeEmoji._new("1f439", ":hamster:");
  static final UnicodeEmoji golf = new UnicodeEmoji._new("26f3", ":golf:");
  static final UnicodeEmoji surfer = new UnicodeEmoji._new("1f3c4", ":surfer:");
  static final UnicodeEmoji mouse = new UnicodeEmoji._new("1f42d", ":mouse:");
  static final UnicodeEmoji waxing_crescent_moon =
      new UnicodeEmoji._new("1f312", ":waxing_crescent_moon:");
  static final UnicodeEmoji blue_car =
      new UnicodeEmoji._new("1f699", ":blue_car:");
  static final UnicodeEmoji a = new UnicodeEmoji._new("1f170", ":a:");
  static final UnicodeEmoji interrobang =
      new UnicodeEmoji._new("2049", ":interrobang:");
  static final UnicodeEmoji u5272 = new UnicodeEmoji._new("1f239", ":u5272:");
  static final UnicodeEmoji electric_plug =
      new UnicodeEmoji._new("1f50c", ":electric_plug:");
  static final UnicodeEmoji first_quarter_moon =
      new UnicodeEmoji._new("1f313", ":first_quarter_moon:");
  static final UnicodeEmoji cancer = new UnicodeEmoji._new("264b", ":cancer:");
  static final UnicodeEmoji trident =
      new UnicodeEmoji._new("1f531", ":trident:");
  static final UnicodeEmoji bread = new UnicodeEmoji._new("1f35e", ":bread:");
  static final UnicodeEmoji cop = new UnicodeEmoji._new("1f46e", ":cop:");
  static final UnicodeEmoji tea = new UnicodeEmoji._new("1f375", ":tea:");
  static final UnicodeEmoji fishing_pole_and_fish =
      new UnicodeEmoji._new("1f3a3", ":fishing_pole_and_fish:");
  static final UnicodeEmoji bike = new UnicodeEmoji._new("1f6b2", ":bike:");
  static final UnicodeEmoji rice = new UnicodeEmoji._new("1f35a", ":rice:");
  static final UnicodeEmoji radio = new UnicodeEmoji._new("1f4fb", ":radio:");
  static final UnicodeEmoji baby_chick =
      new UnicodeEmoji._new("1f424", ":baby_chick:");
  static final UnicodeEmoji arrow_heading_down =
      new UnicodeEmoji._new("2935", ":arrow_heading_down:");
  static final UnicodeEmoji waning_crescent_moon =
      new UnicodeEmoji._new("1f318", ":waning_crescent_moon:");
  static final UnicodeEmoji arrow_up_down =
      new UnicodeEmoji._new("2195", ":arrow_up_down:");
  static final UnicodeEmoji last_quarter_moon =
      new UnicodeEmoji._new("1f317", ":last_quarter_moon:");
  static final UnicodeEmoji radio_button =
      new UnicodeEmoji._new("1f518", ":radio_button:");
  static final UnicodeEmoji sheep = new UnicodeEmoji._new("1f411", ":sheep:");
  static final UnicodeEmoji person_with_blond_hair =
      new UnicodeEmoji._new("1f471", ":person_with_blond_hair:");
  static final UnicodeEmoji waning_gibbous_moon =
      new UnicodeEmoji._new("1f316", ":waning_gibbous_moon:");
  static final UnicodeEmoji lock = new UnicodeEmoji._new("1f512", ":lock:");
  static final UnicodeEmoji green_apple =
      new UnicodeEmoji._new("1f34f", ":green_apple:");
  static final UnicodeEmoji japanese_goblin =
      new UnicodeEmoji._new("1f47a", ":japanese_goblin:");
  static final UnicodeEmoji curly_loop =
      new UnicodeEmoji._new("27b0", ":curly_loop:");
  static final UnicodeEmoji triangular_flag_on_post =
      new UnicodeEmoji._new("1f6a9", ":triangular_flag_on_post:");
  static final UnicodeEmoji arrows_counterclockwise =
      new UnicodeEmoji._new("1f504", ":arrows_counterclockwise:");
  static final UnicodeEmoji racehorse =
      new UnicodeEmoji._new("1f40e", ":racehorse:");
  static final UnicodeEmoji fried_shrimp =
      new UnicodeEmoji._new("1f364", ":fried_shrimp:");
  static final UnicodeEmoji sunrise_over_mountains =
      new UnicodeEmoji._new("1f304", ":sunrise_over_mountains:");
  static final UnicodeEmoji volcano =
      new UnicodeEmoji._new("1f30b", ":volcano:");
  static final UnicodeEmoji rooster =
      new UnicodeEmoji._new("1f413", ":rooster:");
  static final UnicodeEmoji inbox_tray =
      new UnicodeEmoji._new("1f4e5", ":inbox_tray:");
  static final UnicodeEmoji wedding =
      new UnicodeEmoji._new("1f492", ":wedding:");
  static final UnicodeEmoji sushi = new UnicodeEmoji._new("1f363", ":sushi:");
  static final UnicodeEmoji wavy_dash =
      new UnicodeEmoji._new("3030", ":wavy_dash:");
  static final UnicodeEmoji ice_cream =
      new UnicodeEmoji._new("1f368", ":ice_cream:");
  static final UnicodeEmoji rewind = new UnicodeEmoji._new("23ea", ":rewind:");
  static final UnicodeEmoji tomato = new UnicodeEmoji._new("1f345", ":tomato:");
  static final UnicodeEmoji rabbit2 =
      new UnicodeEmoji._new("1f407", ":rabbit2:");
  static final UnicodeEmoji eight_pointed_black_star =
      new UnicodeEmoji._new("2734", ":eight_pointed_black_star:");
  static final UnicodeEmoji small_red_triangle =
      new UnicodeEmoji._new("1f53a", ":small_red_triangle:");
  static final UnicodeEmoji high_brightness =
      new UnicodeEmoji._new("1f506", ":high_brightness:");
  static final UnicodeEmoji heavy_plus_sign =
      new UnicodeEmoji._new("2795", ":heavy_plus_sign:");
  static final UnicodeEmoji man_with_gua_pi_mao =
      new UnicodeEmoji._new("1f472", ":man_with_gua_pi_mao:");
  static final UnicodeEmoji convenience_store =
      new UnicodeEmoji._new("1f3ea", ":convenience_store:");
  static final UnicodeEmoji busts_in_silhouette =
      new UnicodeEmoji._new("1f465", ":busts_in_silhouette:");
  static final UnicodeEmoji beetle = new UnicodeEmoji._new("1f41e", ":beetle:");
  static final UnicodeEmoji small_red_triangle_down =
      new UnicodeEmoji._new("1f53b", ":small_red_triangle_down:");
  static final UnicodeEmoji arrow_heading_up =
      new UnicodeEmoji._new("2934", ":arrow_heading_up:");
  static final UnicodeEmoji name_badge =
      new UnicodeEmoji._new("1f4db", ":name_badge:");
  static final UnicodeEmoji bath = new UnicodeEmoji._new("1f6c0", ":bath:");
  static final UnicodeEmoji no_entry =
      new UnicodeEmoji._new("26d4", ":no_entry:");
  static final UnicodeEmoji crocodile =
      new UnicodeEmoji._new("1f40a", ":crocodile:");
  static final UnicodeEmoji dog2 = new UnicodeEmoji._new("1f415", ":dog2:");
  static final UnicodeEmoji cat2 = new UnicodeEmoji._new("1f408", ":cat2:");
  static final UnicodeEmoji hammer = new UnicodeEmoji._new("1f528", ":hammer:");
  static final UnicodeEmoji meat_on_bone =
      new UnicodeEmoji._new("1f356", ":meat_on_bone:");
  static final UnicodeEmoji shell = new UnicodeEmoji._new("1f41a", ":shell:");
  static final UnicodeEmoji sparkle =
      new UnicodeEmoji._new("2747", ":sparkle:");
  static final UnicodeEmoji b = new UnicodeEmoji._new("1f171", ":b:");
  static final UnicodeEmoji m = new UnicodeEmoji._new("24c2", ":m:");
  static final UnicodeEmoji poodle = new UnicodeEmoji._new("1f429", ":poodle:");
  static final UnicodeEmoji aquarius =
      new UnicodeEmoji._new("2652", ":aquarius:");
  static final UnicodeEmoji stew = new UnicodeEmoji._new("1f372", ":stew:");
  static final UnicodeEmoji jeans = new UnicodeEmoji._new("1f456", ":jeans:");
  static final UnicodeEmoji honey_pot =
      new UnicodeEmoji._new("1f36f", ":honey_pot:");
  static final UnicodeEmoji musical_keyboard =
      new UnicodeEmoji._new("1f3b9", ":musical_keyboard:");
  static final UnicodeEmoji unlock = new UnicodeEmoji._new("1f513", ":unlock:");
  static final UnicodeEmoji black_nib =
      new UnicodeEmoji._new("2712", ":black_nib:");
  static final UnicodeEmoji statue_of_liberty =
      new UnicodeEmoji._new("1f5fd", ":statue_of_liberty:");
  static final UnicodeEmoji heavy_dollar_sign =
      new UnicodeEmoji._new("1f4b2", ":heavy_dollar_sign:");
  static final UnicodeEmoji snowboarder =
      new UnicodeEmoji._new("1f3c2", ":snowboarder:");
  static final UnicodeEmoji white_flower =
      new UnicodeEmoji._new("1f4ae", ":white_flower:");
  static final UnicodeEmoji necktie =
      new UnicodeEmoji._new("1f454", ":necktie:");
  static final UnicodeEmoji diamond_shape_with_a_dot_inside =
      new UnicodeEmoji._new("1f4a0", ":diamond_shape_with_a_dot_inside:");
  static final UnicodeEmoji aries = new UnicodeEmoji._new("2648", ":aries:");
  static final UnicodeEmoji womens = new UnicodeEmoji._new("1f6ba", ":womens:");
  static final UnicodeEmoji ant = new UnicodeEmoji._new("1f41c", ":ant:");
  static final UnicodeEmoji scorpius =
      new UnicodeEmoji._new("264f", ":scorpius:");
  static final UnicodeEmoji city_sunset =
      new UnicodeEmoji._new("1f307", ":city_sunset:");
  static final UnicodeEmoji hourglass_flowing_sand =
      new UnicodeEmoji._new("23f3", ":hourglass_flowing_sand:");
  static final UnicodeEmoji o2 = new UnicodeEmoji._new("1f17e", ":o2:");
  static final UnicodeEmoji dragon_face =
      new UnicodeEmoji._new("1f432", ":dragon_face:");
  static final UnicodeEmoji snail = new UnicodeEmoji._new("1f40c", ":snail:");
  static final UnicodeEmoji dvd = new UnicodeEmoji._new("1f4c0", ":dvd:");
  static final UnicodeEmoji shirt = new UnicodeEmoji._new("1f455", ":shirt:");
  static final UnicodeEmoji game_die =
      new UnicodeEmoji._new("1f3b2", ":game_die:");
  static final UnicodeEmoji heavy_minus_sign =
      new UnicodeEmoji._new("2796", ":heavy_minus_sign:");
  static final UnicodeEmoji dolls = new UnicodeEmoji._new("1f38e", ":dolls:");
  static final UnicodeEmoji sagittarius =
      new UnicodeEmoji._new("2650", ":sagittarius:");
  static final UnicodeEmoji eightBall =
      new UnicodeEmoji._new("1f3b1", ":8ball:");
  static final UnicodeEmoji bus = new UnicodeEmoji._new("1f68c", ":bus:");
  static final UnicodeEmoji custard =
      new UnicodeEmoji._new("1f36e", ":custard:");
  static final UnicodeEmoji crossed_flags =
      new UnicodeEmoji._new("1f38c", ":crossed_flags:");
  static final UnicodeEmoji part_alternation_mark =
      new UnicodeEmoji._new("303d", ":part_alternation_mark:");
  static final UnicodeEmoji camel = new UnicodeEmoji._new("1f42b", ":camel:");
  static final UnicodeEmoji curry = new UnicodeEmoji._new("1f35b", ":curry:");
  static final UnicodeEmoji steam_locomotive =
      new UnicodeEmoji._new("1f682", ":steam_locomotive:");
  static final UnicodeEmoji hospital =
      new UnicodeEmoji._new("1f3e5", ":hospital:");
  static final UnicodeEmoji large_blue_diamond =
      new UnicodeEmoji._new("1f537", ":large_blue_diamond:");
  static final UnicodeEmoji tanabata_tree =
      new UnicodeEmoji._new("1f38b", ":tanabata_tree:");
  static final UnicodeEmoji bell = new UnicodeEmoji._new("1f514", ":bell:");
  static final UnicodeEmoji leo = new UnicodeEmoji._new("264c", ":leo:");
  static final UnicodeEmoji gemini = new UnicodeEmoji._new("264a", ":gemini:");
  static final UnicodeEmoji pear = new UnicodeEmoji._new("1f350", ":pear:");
  static final UnicodeEmoji large_orange_diamond =
      new UnicodeEmoji._new("1f536", ":large_orange_diamond:");
  static final UnicodeEmoji taurus = new UnicodeEmoji._new("2649", ":taurus:");
  static final UnicodeEmoji globe_with_meridians =
      new UnicodeEmoji._new("1f310", ":globe_with_meridians:");
  static final UnicodeEmoji door = new UnicodeEmoji._new("1f6aa", ":door:");
  static final UnicodeEmoji clock6 = new UnicodeEmoji._new("1f555", ":clock6:");
  static final UnicodeEmoji oncoming_police_car =
      new UnicodeEmoji._new("1f694", ":oncoming_police_car:");
  static final UnicodeEmoji envelope_with_arrow =
      new UnicodeEmoji._new("1f4e9", ":envelope_with_arrow:");
  static final UnicodeEmoji closed_umbrella =
      new UnicodeEmoji._new("1f302", ":closed_umbrella:");
  static final UnicodeEmoji saxophone =
      new UnicodeEmoji._new("1f3b7", ":saxophone:");
  static final UnicodeEmoji church = new UnicodeEmoji._new("26ea", ":church:");
  static final UnicodeEmoji bicyclist =
      new UnicodeEmoji._new("1f6b4", ":bicyclist:");
  static final UnicodeEmoji pisces = new UnicodeEmoji._new("2653", ":pisces:");
  static final UnicodeEmoji dango = new UnicodeEmoji._new("1f361", ":dango:");
  static final UnicodeEmoji capricorn =
      new UnicodeEmoji._new("2651", ":capricorn:");
  static final UnicodeEmoji office = new UnicodeEmoji._new("1f3e2", ":office:");
  static final UnicodeEmoji rowboat =
      new UnicodeEmoji._new("1f6a3", ":rowboat:");
  static final UnicodeEmoji womans_hat =
      new UnicodeEmoji._new("1f452", ":womans_hat:");
  static final UnicodeEmoji mans_shoe =
      new UnicodeEmoji._new("1f45e", ":mans_shoe:");
  static final UnicodeEmoji love_hotel =
      new UnicodeEmoji._new("1f3e9", ":love_hotel:");
  static final UnicodeEmoji mount_fuji =
      new UnicodeEmoji._new("1f5fb", ":mount_fuji:");
  static final UnicodeEmoji dromedary_camel =
      new UnicodeEmoji._new("1f42a", ":dromedary_camel:");
  static final UnicodeEmoji handbag =
      new UnicodeEmoji._new("1f45c", ":handbag:");
  static final UnicodeEmoji hourglass =
      new UnicodeEmoji._new("231b", ":hourglass:");
  static final UnicodeEmoji negative_squared_cross_mark =
      new UnicodeEmoji._new("274e", ":negative_squared_cross_mark:");
  static final UnicodeEmoji trumpet =
      new UnicodeEmoji._new("1f3ba", ":trumpet:");
  static final UnicodeEmoji school = new UnicodeEmoji._new("1f3eb", ":school:");
  static final UnicodeEmoji cow2 = new UnicodeEmoji._new("1f404", ":cow2:");
  static final UnicodeEmoji construction_worker =
      new UnicodeEmoji._new("1f477", ":construction_worker:");
  static final UnicodeEmoji toilet = new UnicodeEmoji._new("1f6bd", ":toilet:");
  static final UnicodeEmoji pig2 = new UnicodeEmoji._new("1f416", ":pig2:");
  static final UnicodeEmoji grey_question =
      new UnicodeEmoji._new("2754", ":grey_question:");
  static final UnicodeEmoji beginner =
      new UnicodeEmoji._new("1f530", ":beginner:");
  static final UnicodeEmoji violin = new UnicodeEmoji._new("1f3bb", ":violin:");
  static final UnicodeEmoji on = new UnicodeEmoji._new("1f51b", ":on:");
  static final UnicodeEmoji credit_card =
      new UnicodeEmoji._new("1f4b3", ":credit_card:");
  static final UnicodeEmoji id = new UnicodeEmoji._new("1f194", ":id:");
  static final UnicodeEmoji secret = new UnicodeEmoji._new("3299", ":secret:");
  static final UnicodeEmoji ferris_wheel =
      new UnicodeEmoji._new("1f3a1", ":ferris_wheel:");
  static final UnicodeEmoji bowling =
      new UnicodeEmoji._new("1f3b3", ":bowling:");
  static final UnicodeEmoji libra = new UnicodeEmoji._new("264e", ":libra:");
  static final UnicodeEmoji virgo = new UnicodeEmoji._new("264d", ":virgo:");
  static final UnicodeEmoji barber = new UnicodeEmoji._new("1f488", ":barber:");
  static final UnicodeEmoji purse = new UnicodeEmoji._new("1f45b", ":purse:");
  static final UnicodeEmoji roller_coaster =
      new UnicodeEmoji._new("1f3a2", ":roller_coaster:");
  static final UnicodeEmoji rat = new UnicodeEmoji._new("1f400", ":rat:");
  static final UnicodeEmoji date = new UnicodeEmoji._new("1f4c5", ":date:");
  static final UnicodeEmoji rugby_football =
      new UnicodeEmoji._new("1f3c9", ":rugby_football:");
  static final UnicodeEmoji ram = new UnicodeEmoji._new("1f40f", ":ram:");
  static final UnicodeEmoji arrow_up_small =
      new UnicodeEmoji._new("1f53c", ":arrow_up_small:");
  static final UnicodeEmoji black_square_button =
      new UnicodeEmoji._new("1f532", ":black_square_button:");
  static final UnicodeEmoji mobile_phone_off =
      new UnicodeEmoji._new("1f4f4", ":mobile_phone_off:");
  static final UnicodeEmoji tokyo_tower =
      new UnicodeEmoji._new("1f5fc", ":tokyo_tower:");
  static final UnicodeEmoji congratulations =
      new UnicodeEmoji._new("3297", ":congratulations:");
  static final UnicodeEmoji kimono = new UnicodeEmoji._new("1f458", ":kimono:");
  static final UnicodeEmoji ship = new UnicodeEmoji._new("1f6a2", ":ship:");
  static final UnicodeEmoji mag_right =
      new UnicodeEmoji._new("1f50e", ":mag_right:");
  static final UnicodeEmoji mag = new UnicodeEmoji._new("1f50d", ":mag:");
  static final UnicodeEmoji fire_engine =
      new UnicodeEmoji._new("1f692", ":fire_engine:");
  static final UnicodeEmoji clock1130 =
      new UnicodeEmoji._new("1f566", ":clock1130:");
  static final UnicodeEmoji police_car =
      new UnicodeEmoji._new("1f693", ":police_car:");
  static final UnicodeEmoji black_joker =
      new UnicodeEmoji._new("1f0cf", ":black_joker:");
  static final UnicodeEmoji bridge_at_night =
      new UnicodeEmoji._new("1f309", ":bridge_at_night:");
  static final UnicodeEmoji package =
      new UnicodeEmoji._new("1f4e6", ":package:");
  static final UnicodeEmoji oncoming_taxi =
      new UnicodeEmoji._new("1f696", ":oncoming_taxi:");
  static final UnicodeEmoji calendar =
      new UnicodeEmoji._new("1f4c6", ":calendar:");
  static final UnicodeEmoji horse_racing =
      new UnicodeEmoji._new("1f3c7", ":horse_racing:");
  static final UnicodeEmoji tiger2 = new UnicodeEmoji._new("1f405", ":tiger2:");
  static final UnicodeEmoji boot = new UnicodeEmoji._new("1f462", ":boot:");
  static final UnicodeEmoji ambulance =
      new UnicodeEmoji._new("1f691", ":ambulance:");
  static final UnicodeEmoji white_square_button =
      new UnicodeEmoji._new("1f533", ":white_square_button:");
  static final UnicodeEmoji boar = new UnicodeEmoji._new("1f417", ":boar:");
  static final UnicodeEmoji school_satchel =
      new UnicodeEmoji._new("1f392", ":school_satchel:");
  static final UnicodeEmoji loop = new UnicodeEmoji._new("27bf", ":loop:");
  static final UnicodeEmoji pound = new UnicodeEmoji._new("1f4b7", ":pound:");
  static final UnicodeEmoji information_source =
      new UnicodeEmoji._new("2139", ":information_source:");
  static final UnicodeEmoji ox = new UnicodeEmoji._new("1f402", ":ox:");
  static final UnicodeEmoji rice_ball =
      new UnicodeEmoji._new("1f359", ":rice_ball:");
  static final UnicodeEmoji vs = new UnicodeEmoji._new("1f19a", ":vs:");
  static final UnicodeEmoji end = new UnicodeEmoji._new("1f51a", ":end:");
  static final UnicodeEmoji parking =
      new UnicodeEmoji._new("1f17f", ":parking:");
  static final UnicodeEmoji sandal = new UnicodeEmoji._new("1f461", ":sandal:");
  static final UnicodeEmoji tent = new UnicodeEmoji._new("26fa", ":tent:");
  static final UnicodeEmoji seat = new UnicodeEmoji._new("1f4ba", ":seat:");
  static final UnicodeEmoji taxi = new UnicodeEmoji._new("1f695", ":taxi:");
  static final UnicodeEmoji black_medium_small_square =
      new UnicodeEmoji._new("25fe", ":black_medium_small_square:");
  static final UnicodeEmoji briefcase =
      new UnicodeEmoji._new("1f4bc", ":briefcase:");
  static final UnicodeEmoji newspaper =
      new UnicodeEmoji._new("1f4f0", ":newspaper:");
  static final UnicodeEmoji circus_tent =
      new UnicodeEmoji._new("1f3aa", ":circus_tent:");
  static final UnicodeEmoji six_pointed_star =
      new UnicodeEmoji._new("1f52f", ":six_pointed_star:");
  static final UnicodeEmoji mens = new UnicodeEmoji._new("1f6b9", ":mens:");
  static final UnicodeEmoji european_castle =
      new UnicodeEmoji._new("1f3f0", ":european_castle:");
  static final UnicodeEmoji flashlight =
      new UnicodeEmoji._new("1f526", ":flashlight:");
  static final UnicodeEmoji foggy = new UnicodeEmoji._new("1f301", ":foggy:");
  static final UnicodeEmoji arrow_double_up =
      new UnicodeEmoji._new("23eb", ":arrow_double_up:");
  static final UnicodeEmoji bamboo = new UnicodeEmoji._new("1f38d", ":bamboo:");
  static final UnicodeEmoji ticket = new UnicodeEmoji._new("1f3ab", ":ticket:");
  static final UnicodeEmoji helicopter =
      new UnicodeEmoji._new("1f681", ":helicopter:");
  static final UnicodeEmoji minidisc =
      new UnicodeEmoji._new("1f4bd", ":minidisc:");
  static final UnicodeEmoji oncoming_bus =
      new UnicodeEmoji._new("1f68d", ":oncoming_bus:");
  static final UnicodeEmoji melon = new UnicodeEmoji._new("1f348", ":melon:");
  static final UnicodeEmoji white_small_square =
      new UnicodeEmoji._new("25ab", ":white_small_square:");
  static final UnicodeEmoji european_post_office =
      new UnicodeEmoji._new("1f3e4", ":european_post_office:");
  static final UnicodeEmoji keycap_ten =
      new UnicodeEmoji._new("1f51f", ":keycap_ten:");
  static final UnicodeEmoji notebook =
      new UnicodeEmoji._new("1f4d3", ":notebook:");
  static final UnicodeEmoji no_bell =
      new UnicodeEmoji._new("1f515", ":no_bell:");
  static final UnicodeEmoji oden = new UnicodeEmoji._new("1f362", ":oden:");
  static final UnicodeEmoji flags = new UnicodeEmoji._new("1f38f", ":flags:");
  static final UnicodeEmoji carousel_horse =
      new UnicodeEmoji._new("1f3a0", ":carousel_horse:");
  static final UnicodeEmoji blowfish =
      new UnicodeEmoji._new("1f421", ":blowfish:");
  static final UnicodeEmoji chart_with_upwards_trend =
      new UnicodeEmoji._new("1f4c8", ":chart_with_upwards_trend:");
  static final UnicodeEmoji sweet_potato =
      new UnicodeEmoji._new("1f360", ":sweet_potato:");
  static final UnicodeEmoji ski = new UnicodeEmoji._new("1f3bf", ":ski:");
  static final UnicodeEmoji clock12 =
      new UnicodeEmoji._new("1f55b", ":clock12:");
  static final UnicodeEmoji signal_strength =
      new UnicodeEmoji._new("1f4f6", ":signal_strength:");
  static final UnicodeEmoji construction =
      new UnicodeEmoji._new("1f6a7", ":construction:");
  static final UnicodeEmoji black_medium_square =
      new UnicodeEmoji._new("25fc", ":black_medium_square:");
  static final UnicodeEmoji satellite =
      new UnicodeEmoji._new("1f4e1", ":satellite:");
  static final UnicodeEmoji euro = new UnicodeEmoji._new("1f4b6", ":euro:");
  static final UnicodeEmoji womans_clothes =
      new UnicodeEmoji._new("1f45a", ":womans_clothes:");
  static final UnicodeEmoji ledger = new UnicodeEmoji._new("1f4d2", ":ledger:");
  static final UnicodeEmoji leopard =
      new UnicodeEmoji._new("1f406", ":leopard:");
  static final UnicodeEmoji low_brightness =
      new UnicodeEmoji._new("1f505", ":low_brightness:");
  static final UnicodeEmoji clock3 = new UnicodeEmoji._new("1f552", ":clock3:");
  static final UnicodeEmoji department_store =
      new UnicodeEmoji._new("1f3ec", ":department_store:");
  static final UnicodeEmoji truck = new UnicodeEmoji._new("1f69a", ":truck:");
  static final UnicodeEmoji sake = new UnicodeEmoji._new("1f376", ":sake:");
  static final UnicodeEmoji railway_car =
      new UnicodeEmoji._new("1f683", ":railway_car:");
  static final UnicodeEmoji speedboat =
      new UnicodeEmoji._new("1f6a4", ":speedboat:");
  static final UnicodeEmoji vhs = new UnicodeEmoji._new("1f4fc", ":vhs:");
  static final UnicodeEmoji clock1 = new UnicodeEmoji._new("1f550", ":clock1:");
  static final UnicodeEmoji arrow_double_down =
      new UnicodeEmoji._new("23ec", ":arrow_double_down:");
  static final UnicodeEmoji water_buffalo =
      new UnicodeEmoji._new("1f403", ":water_buffalo:");
  static final UnicodeEmoji arrow_down_small =
      new UnicodeEmoji._new("1f53d", ":arrow_down_small:");
  static final UnicodeEmoji yen = new UnicodeEmoji._new("1f4b4", ":yen:");
  static final UnicodeEmoji mute = new UnicodeEmoji._new("1f507", ":mute:");
  static final UnicodeEmoji running_shirt_with_sash =
      new UnicodeEmoji._new("1f3bd", ":running_shirt_with_sash:");
  static final UnicodeEmoji white_large_square =
      new UnicodeEmoji._new("2b1c", ":white_large_square:");
  static final UnicodeEmoji wheelchair =
      new UnicodeEmoji._new("267f", ":wheelchair:");
  static final UnicodeEmoji clock2 = new UnicodeEmoji._new("1f551", ":clock2:");
  static final UnicodeEmoji paperclip =
      new UnicodeEmoji._new("1f4ce", ":paperclip:");
  static final UnicodeEmoji atm = new UnicodeEmoji._new("1f3e7", ":atm:");
  static final UnicodeEmoji cinema = new UnicodeEmoji._new("1f3a6", ":cinema:");
  static final UnicodeEmoji telescope =
      new UnicodeEmoji._new("1f52d", ":telescope:");
  static final UnicodeEmoji rice_scene =
      new UnicodeEmoji._new("1f391", ":rice_scene:");
  static final UnicodeEmoji blue_book =
      new UnicodeEmoji._new("1f4d8", ":blue_book:");
  static final UnicodeEmoji white_medium_square =
      new UnicodeEmoji._new("25fb", ":white_medium_square:");
  static final UnicodeEmoji postbox =
      new UnicodeEmoji._new("1f4ee", ":postbox:");
  static final UnicodeEmoji email = new UnicodeEmoji._new("1f4e7", ":e-mail:");
  static final UnicodeEmoji mouse2 = new UnicodeEmoji._new("1f401", ":mouse2:");
  static final UnicodeEmoji bullettrain_side =
      new UnicodeEmoji._new("1f684", ":bullettrain_side:");
  static final UnicodeEmoji ideograph_advantage =
      new UnicodeEmoji._new("1f250", ":ideograph_advantage:");
  static final UnicodeEmoji nut_and_bolt =
      new UnicodeEmoji._new("1f529", ":nut_and_bolt:");
  static final UnicodeEmoji ng = new UnicodeEmoji._new("1f196", ":ng:");
  static final UnicodeEmoji hotel = new UnicodeEmoji._new("1f3e8", ":hotel:");
  static final UnicodeEmoji wc = new UnicodeEmoji._new("1f6be", ":wc:");
  static final UnicodeEmoji izakaya_lantern =
      new UnicodeEmoji._new("1f3ee", ":izakaya_lantern:");
  static final UnicodeEmoji repeat_one =
      new UnicodeEmoji._new("1f502", ":repeat_one:");
  static final UnicodeEmoji mailbox_with_mail =
      new UnicodeEmoji._new("1f4ec", ":mailbox_with_mail:");
  static final UnicodeEmoji chart_with_downwards_trend =
      new UnicodeEmoji._new("1f4c9", ":chart_with_downwards_trend:");
  static final UnicodeEmoji green_book =
      new UnicodeEmoji._new("1f4d7", ":green_book:");
  static final UnicodeEmoji tractor =
      new UnicodeEmoji._new("1f69c", ":tractor:");
  static final UnicodeEmoji fountain =
      new UnicodeEmoji._new("26f2", ":fountain:");
  static final UnicodeEmoji metro = new UnicodeEmoji._new("1f687", ":metro:");
  static final UnicodeEmoji clipboard =
      new UnicodeEmoji._new("1f4cb", ":clipboard:");
  static final UnicodeEmoji no_mobile_phones =
      new UnicodeEmoji._new("1f4f5", ":no_mobile_phones:");
  static final UnicodeEmoji clock4 = new UnicodeEmoji._new("1f553", ":clock4:");
  static final UnicodeEmoji no_smoking =
      new UnicodeEmoji._new("1f6ad", ":no_smoking:");
  static final UnicodeEmoji black_large_square =
      new UnicodeEmoji._new("2b1b", ":black_large_square:");
  static final UnicodeEmoji slot_machine =
      new UnicodeEmoji._new("1f3b0", ":slot_machine:");
  static final UnicodeEmoji clock5 = new UnicodeEmoji._new("1f554", ":clock5:");
  static final UnicodeEmoji bathtub =
      new UnicodeEmoji._new("1f6c1", ":bathtub:");
  static final UnicodeEmoji scroll = new UnicodeEmoji._new("1f4dc", ":scroll:");
  static final UnicodeEmoji station =
      new UnicodeEmoji._new("1f689", ":station:");
  static final UnicodeEmoji rice_cracker =
      new UnicodeEmoji._new("1f358", ":rice_cracker:");
  static final UnicodeEmoji bank = new UnicodeEmoji._new("1f3e6", ":bank:");
  static final UnicodeEmoji wrench = new UnicodeEmoji._new("1f527", ":wrench:");
  static final UnicodeEmoji u6307 = new UnicodeEmoji._new("1f22f", ":u6307:");
  static final UnicodeEmoji articulated_lorry =
      new UnicodeEmoji._new("1f69b", ":articulated_lorry:");
  static final UnicodeEmoji page_facing_up =
      new UnicodeEmoji._new("1f4c4", ":page_facing_up:");
  static final UnicodeEmoji ophiuchus =
      new UnicodeEmoji._new("26ce", ":ophiuchus:");
  static final UnicodeEmoji bar_chart =
      new UnicodeEmoji._new("1f4ca", ":bar_chart:");
  static final UnicodeEmoji no_pedestrians =
      new UnicodeEmoji._new("1f6b7", ":no_pedestrians:");
  static final UnicodeEmoji vibration_mode =
      new UnicodeEmoji._new("1f4f3", ":vibration_mode:");
  static final UnicodeEmoji clock10 =
      new UnicodeEmoji._new("1f559", ":clock10:");
  static final UnicodeEmoji clock9 = new UnicodeEmoji._new("1f558", ":clock9:");
  static final UnicodeEmoji bullettrain_front =
      new UnicodeEmoji._new("1f685", ":bullettrain_front:");
  static final UnicodeEmoji minibus =
      new UnicodeEmoji._new("1f690", ":minibus:");
  static final UnicodeEmoji tram = new UnicodeEmoji._new("1f68a", ":tram:");
  static final UnicodeEmoji clock8 = new UnicodeEmoji._new("1f557", ":clock8:");
  static final UnicodeEmoji u7a7a = new UnicodeEmoji._new("1f233", ":u7a7a:");
  static final UnicodeEmoji traffic_light =
      new UnicodeEmoji._new("1f6a5", ":traffic_light:");
  static final UnicodeEmoji mountain_bicyclist =
      new UnicodeEmoji._new("1f6b5", ":mountain_bicyclist:");
  static final UnicodeEmoji microscope =
      new UnicodeEmoji._new("1f52c", ":microscope:");
  static final UnicodeEmoji japanese_castle =
      new UnicodeEmoji._new("1f3ef", ":japanese_castle:");
  static final UnicodeEmoji bookmark =
      new UnicodeEmoji._new("1f516", ":bookmark:");
  static final UnicodeEmoji bookmark_tabs =
      new UnicodeEmoji._new("1f4d1", ":bookmark_tabs:");
  static final UnicodeEmoji pouch = new UnicodeEmoji._new("1f45d", ":pouch:");
  static final UnicodeEmoji ab = new UnicodeEmoji._new("1f18e", ":ab:");
  static final UnicodeEmoji page_with_curl =
      new UnicodeEmoji._new("1f4c3", ":page_with_curl:");
  static final UnicodeEmoji flower_playing_cards =
      new UnicodeEmoji._new("1f3b4", ":flower_playing_cards:");
  static final UnicodeEmoji clock11 =
      new UnicodeEmoji._new("1f55a", ":clock11:");
  static final UnicodeEmoji fax = new UnicodeEmoji._new("1f4e0", ":fax:");
  static final UnicodeEmoji clock7 = new UnicodeEmoji._new("1f556", ":clock7:");
  static final UnicodeEmoji white_medium_small_square =
      new UnicodeEmoji._new("25fd", ":white_medium_small_square:");
  static final UnicodeEmoji currency_exchange =
      new UnicodeEmoji._new("1f4b1", ":currency_exchange:");
  static final UnicodeEmoji sound = new UnicodeEmoji._new("1f509", ":sound:");
  static final UnicodeEmoji chart = new UnicodeEmoji._new("1f4b9", ":chart:");
  static final UnicodeEmoji cl = new UnicodeEmoji._new("1f191", ":cl:");
  static final UnicodeEmoji floppy_disk =
      new UnicodeEmoji._new("1f4be", ":floppy_disk:");
  static final UnicodeEmoji post_office =
      new UnicodeEmoji._new("1f3e3", ":post_office:");
  static final UnicodeEmoji speaker =
      new UnicodeEmoji._new("1f508", ":speaker:");
  static final UnicodeEmoji japan = new UnicodeEmoji._new("1f5fe", ":japan:");
  static final UnicodeEmoji u55b6 = new UnicodeEmoji._new("1f23a", ":u55b6:");
  static final UnicodeEmoji mahjong =
      new UnicodeEmoji._new("1f004", ":mahjong:");
  static final UnicodeEmoji incoming_envelope =
      new UnicodeEmoji._new("1f4e8", ":incoming_envelope:");
  static final UnicodeEmoji orange_book =
      new UnicodeEmoji._new("1f4d9", ":orange_book:");
  static final UnicodeEmoji restroom =
      new UnicodeEmoji._new("1f6bb", ":restroom:");
  static final UnicodeEmoji u7121 = new UnicodeEmoji._new("1f21a", ":u7121:");
  static final UnicodeEmoji u6709 = new UnicodeEmoji._new("1f236", ":u6709:");
  static final UnicodeEmoji triangular_ruler =
      new UnicodeEmoji._new("1f4d0", ":triangular_ruler:");
  static final UnicodeEmoji train = new UnicodeEmoji._new("1f68b", ":train:");
  static final UnicodeEmoji u7533 = new UnicodeEmoji._new("1f238", ":u7533:");
  static final UnicodeEmoji trolleybus =
      new UnicodeEmoji._new("1f68e", ":trolleybus:");
  static final UnicodeEmoji u6708 = new UnicodeEmoji._new("1f237", ":u6708:");
  static final UnicodeEmoji notebook_with_decorative_cover =
      new UnicodeEmoji._new("1f4d4", ":notebook_with_decorative_cover:");
  static final UnicodeEmoji u7981 = new UnicodeEmoji._new("1f232", ":u7981:");
  static final UnicodeEmoji u6e80 = new UnicodeEmoji._new("1f235", ":u6e80:");
  static final UnicodeEmoji postal_horn =
      new UnicodeEmoji._new("1f4ef", ":postal_horn:");
  static final UnicodeEmoji factory =
      new UnicodeEmoji._new("1f3ed", ":factory:");
  static final UnicodeEmoji children_crossing =
      new UnicodeEmoji._new("1f6b8", ":children_crossing:");
  static final UnicodeEmoji train2 = new UnicodeEmoji._new("1f686", ":train2:");
  static final UnicodeEmoji straight_ruler =
      new UnicodeEmoji._new("1f4cf", ":straight_ruler:");
  static final UnicodeEmoji pager = new UnicodeEmoji._new("1f4df", ":pager:");
  static final UnicodeEmoji accept = new UnicodeEmoji._new("1f251", ":accept:");
  static final UnicodeEmoji u5408 = new UnicodeEmoji._new("1f234", ":u5408:");
  static final UnicodeEmoji lock_with_ink_pen =
      new UnicodeEmoji._new("1f50f", ":lock_with_ink_pen:");
  static final UnicodeEmoji clock130 =
      new UnicodeEmoji._new("1f55c", ":clock130:");
  static final UnicodeEmoji sa = new UnicodeEmoji._new("1f202", ":sa:");
  static final UnicodeEmoji outbox_tray =
      new UnicodeEmoji._new("1f4e4", ":outbox_tray:");
  static final UnicodeEmoji twisted_rightwards_arrows =
      new UnicodeEmoji._new("1f500", ":twisted_rightwards_arrows:");
  static final UnicodeEmoji mailbox =
      new UnicodeEmoji._new("1f4eb", ":mailbox:");
  static final UnicodeEmoji light_rail =
      new UnicodeEmoji._new("1f688", ":light_rail:");
  static final UnicodeEmoji clock930 =
      new UnicodeEmoji._new("1f564", ":clock930:");
  static final UnicodeEmoji busstop =
      new UnicodeEmoji._new("1f68f", ":busstop:");
  static final UnicodeEmoji open_file_folder =
      new UnicodeEmoji._new("1f4c2", ":open_file_folder:");
  static final UnicodeEmoji file_folder =
      new UnicodeEmoji._new("1f4c1", ":file_folder:");
  static final UnicodeEmoji potable_water =
      new UnicodeEmoji._new("1f6b0", ":potable_water:");
  static final UnicodeEmoji card_index =
      new UnicodeEmoji._new("1f4c7", ":card_index:");
  static final UnicodeEmoji clock230 =
      new UnicodeEmoji._new("1f55d", ":clock230:");
  static final UnicodeEmoji monorail =
      new UnicodeEmoji._new("1f69d", ":monorail:");
  static final UnicodeEmoji clock1230 =
      new UnicodeEmoji._new("1f567", ":clock1230:");
  static final UnicodeEmoji clock1030 =
      new UnicodeEmoji._new("1f565", ":clock1030:");
  static final UnicodeEmoji abc = new UnicodeEmoji._new("1f524", ":abc:");
  static final UnicodeEmoji mailbox_closed =
      new UnicodeEmoji._new("1f4ea", ":mailbox_closed:");
  static final UnicodeEmoji clock430 =
      new UnicodeEmoji._new("1f55f", ":clock430:");
  static final UnicodeEmoji mountain_railway =
      new UnicodeEmoji._new("1f69e", ":mountain_railway:");
  static final UnicodeEmoji do_not_litter =
      new UnicodeEmoji._new("1f6af", ":do_not_litter:");
  static final UnicodeEmoji clock330 =
      new UnicodeEmoji._new("1f55e", ":clock330:");
  static final UnicodeEmoji heavy_division_sign =
      new UnicodeEmoji._new("2797", ":heavy_division_sign:");
  static final UnicodeEmoji clock730 =
      new UnicodeEmoji._new("1f562", ":clock730:");
  static final UnicodeEmoji clock530 =
      new UnicodeEmoji._new("1f560", ":clock530:");
  static final UnicodeEmoji capital_abcd =
      new UnicodeEmoji._new("1f520", ":capital_abcd:");
  static final UnicodeEmoji mailbox_with_no_mail =
      new UnicodeEmoji._new("1f4ed", ":mailbox_with_no_mail:");
  static final UnicodeEmoji symbols =
      new UnicodeEmoji._new("1f523", ":symbols:");
  static final UnicodeEmoji aerial_tramway =
      new UnicodeEmoji._new("1f6a1", ":aerial_tramway:");
  static final UnicodeEmoji clock830 =
      new UnicodeEmoji._new("1f563", ":clock830:");
  static final UnicodeEmoji clock630 =
      new UnicodeEmoji._new("1f561", ":clock630:");
  static final UnicodeEmoji abcd = new UnicodeEmoji._new("1f521", ":abcd:");
  static final UnicodeEmoji mountain_cableway =
      new UnicodeEmoji._new("1f6a0", ":mountain_cableway:");
  static final UnicodeEmoji koko = new UnicodeEmoji._new("1f201", ":koko:");
  static final UnicodeEmoji passport_control =
      new UnicodeEmoji._new("1f6c2", ":passport_control:");
  static final UnicodeEmoji nonPotableWater =
      new UnicodeEmoji._new("1f6b1", ":non-potable_water:");
  static final UnicodeEmoji suspension_railway =
      new UnicodeEmoji._new("1f69f", ":suspension_railway:");
  static final UnicodeEmoji baggage_claim =
      new UnicodeEmoji._new("1f6c4", ":baggage_claim:");
  static final UnicodeEmoji no_bicycles =
      new UnicodeEmoji._new("1f6b3", ":no_bicycles:");
  static final UnicodeEmoji skull_and_crossbones =
      new UnicodeEmoji._new("2620", ":skull_crossbones:");
  static final UnicodeEmoji hugging_face =
      new UnicodeEmoji._new("1f917", ":hugging:");
  static final UnicodeEmoji thinking_face =
      new UnicodeEmoji._new("1f914", ":thinking:");
  static final UnicodeEmoji nerd_face =
      new UnicodeEmoji._new("1f913", ":nerd:");
  static final UnicodeEmoji zipper_mouth_face =
      new UnicodeEmoji._new("1f910", ":zipper_mouth:");
  static final UnicodeEmoji face_with_rolling_eyes =
      new UnicodeEmoji._new("1f644", ":rolling_eyes:");
  static final UnicodeEmoji upside_down_face =
      new UnicodeEmoji._new("1f643", ":upside_down:");
  static final UnicodeEmoji slightly_smiling_face =
      new UnicodeEmoji._new("1f642", ":slight_smile:");
  static final UnicodeEmoji middle_finger =
      new UnicodeEmoji._new("1f595", ":middle_finger:");
  static final UnicodeEmoji writing_hand =
      new UnicodeEmoji._new("270d", ":writing_hand:");
  static final UnicodeEmoji dark_sunglasses =
      new UnicodeEmoji._new("1f576", ":dark_sunglasses:");
  static final UnicodeEmoji eye = new UnicodeEmoji._new("1f441", ":eye:");
  static final UnicodeEmoji golfer = new UnicodeEmoji._new("1f3cc", ":golfer:");
  static final UnicodeEmoji heart_exclamation =
      new UnicodeEmoji._new("2763", ":heart_exclamation:");
  static final UnicodeEmoji star_of_david =
      new UnicodeEmoji._new("2721", ":star_of_david:");
  static final UnicodeEmoji cross = new UnicodeEmoji._new("271d", ":cross:");
  static final UnicodeEmoji fleurDeLis =
      new UnicodeEmoji._new("269c", ":fleur-de-lis:");
  static final UnicodeEmoji atom = new UnicodeEmoji._new("269b", ":atom:");
  static final UnicodeEmoji wheel_of_dharma =
      new UnicodeEmoji._new("2638", ":wheel_of_dharma:");
  static final UnicodeEmoji yin_yang =
      new UnicodeEmoji._new("262f", ":yin_yang:");
  static final UnicodeEmoji peace = new UnicodeEmoji._new("262e", ":peace:");
  static final UnicodeEmoji star_and_crescent =
      new UnicodeEmoji._new("262a", ":star_and_crescent:");
  static final UnicodeEmoji orthodox_cross =
      new UnicodeEmoji._new("2626", ":orthodox_cross:");
  static final UnicodeEmoji biohazard =
      new UnicodeEmoji._new("2623", ":biohazard:");
  static final UnicodeEmoji radioactive =
      new UnicodeEmoji._new("2622", ":radioactive:");
  static final UnicodeEmoji place_of_worship =
      new UnicodeEmoji._new("1f6d0", ":place_of_worship:");
  static final UnicodeEmoji anger_right =
      new UnicodeEmoji._new("1f5ef", ":anger_right:");
  static final UnicodeEmoji menorah =
      new UnicodeEmoji._new("1f54e", ":menorah:");
  static final UnicodeEmoji om_symbol =
      new UnicodeEmoji._new("1f549", ":om_symbol:");
  static final UnicodeEmoji coffin = new UnicodeEmoji._new("26b0", ":coffin:");
  static final UnicodeEmoji gear = new UnicodeEmoji._new("2699", ":gear:");
  static final UnicodeEmoji alembic =
      new UnicodeEmoji._new("2697", ":alembic:");
  static final UnicodeEmoji scales = new UnicodeEmoji._new("2696", ":scales:");
  static final UnicodeEmoji crossed_swords =
      new UnicodeEmoji._new("2694", ":crossed_swords:");
  static final UnicodeEmoji keyboard =
      new UnicodeEmoji._new("2328", ":keyboard:");
  static final UnicodeEmoji shield = new UnicodeEmoji._new("1f6e1", ":shield:");
  static final UnicodeEmoji bed = new UnicodeEmoji._new("1f6cf", ":bed:");
  static final UnicodeEmoji shopping_bags =
      new UnicodeEmoji._new("1f6cd", ":shopping_bags:");
  static final UnicodeEmoji sleeping_accommodation =
      new UnicodeEmoji._new("1f6cc", ":sleeping_accommodation:");
  static final UnicodeEmoji ballot_box =
      new UnicodeEmoji._new("1f5f3", ":ballot_box:");
  static final UnicodeEmoji compression =
      new UnicodeEmoji._new("1f5dc", ":compression:");
  static final UnicodeEmoji wastebasket =
      new UnicodeEmoji._new("1f5d1", ":wastebasket:");
  static final UnicodeEmoji file_cabinet =
      new UnicodeEmoji._new("1f5c4", ":file_cabinet:");
  static final UnicodeEmoji trackball =
      new UnicodeEmoji._new("1f5b2", ":trackball:");
  static final UnicodeEmoji printer =
      new UnicodeEmoji._new("1f5a8", ":printer:");
  static final UnicodeEmoji joystick =
      new UnicodeEmoji._new("1f579", ":joystick:");
  static final UnicodeEmoji hole = new UnicodeEmoji._new("1f573", ":hole:");
  static final UnicodeEmoji candle = new UnicodeEmoji._new("1f56f", ":candle:");
  static final UnicodeEmoji prayer_beads =
      new UnicodeEmoji._new("1f4ff", ":prayer_beads:");
  static final UnicodeEmoji camera_with_flash =
      new UnicodeEmoji._new("1f4f8", ":camera_with_flash:");
  static final UnicodeEmoji amphora =
      new UnicodeEmoji._new("1f3fa", ":amphora:");
  static final UnicodeEmoji label = new UnicodeEmoji._new("1f3f7", ":label:");
  static final UnicodeEmoji waving_black_flag =
      new UnicodeEmoji._new("1f3f4", ":flag_black:");
  static final UnicodeEmoji waving_white_flag =
      new UnicodeEmoji._new("1f3f3", ":flag_white:");
  static final UnicodeEmoji film_frames =
      new UnicodeEmoji._new("1f39e", ":film_frames:");
  static final UnicodeEmoji control_knobs =
      new UnicodeEmoji._new("1f39b", ":control_knobs:");
  static final UnicodeEmoji level_slider =
      new UnicodeEmoji._new("1f39a", ":level_slider:");
  static final UnicodeEmoji thermometer =
      new UnicodeEmoji._new("1f321", ":thermometer:");
  static final UnicodeEmoji airplane_arriving =
      new UnicodeEmoji._new("1f6ec", ":airplane_arriving:");
  static final UnicodeEmoji airplane_departure =
      new UnicodeEmoji._new("1f6eb", ":airplane_departure:");
  static final UnicodeEmoji railway_track =
      new UnicodeEmoji._new("1f6e4", ":railway_track:");
  static final UnicodeEmoji motorway =
      new UnicodeEmoji._new("1f6e3", ":motorway:");
  static final UnicodeEmoji synagogue =
      new UnicodeEmoji._new("1f54d", ":synagogue:");
  static final UnicodeEmoji mosque = new UnicodeEmoji._new("1f54c", ":mosque:");
  static final UnicodeEmoji kaaba = new UnicodeEmoji._new("1f54b", ":kaaba:");
  static final UnicodeEmoji stadium =
      new UnicodeEmoji._new("1f3df", ":stadium:");
  static final UnicodeEmoji desert = new UnicodeEmoji._new("1f3dc", ":desert:");
  static final UnicodeEmoji classical_building =
      new UnicodeEmoji._new("1f3db", ":classical_building:");
  static final UnicodeEmoji cityscape =
      new UnicodeEmoji._new("1f3d9", ":cityscape:");
  static final UnicodeEmoji camping =
      new UnicodeEmoji._new("1f3d5", ":camping:");
  static final UnicodeEmoji bow_and_arrow =
      new UnicodeEmoji._new("1f3f9", ":bow_and_arrow:");
  static final UnicodeEmoji rosette =
      new UnicodeEmoji._new("1f3f5", ":rosette:");
  static final UnicodeEmoji volleyball =
      new UnicodeEmoji._new("1f3d0", ":volleyball:");
  static final UnicodeEmoji medal = new UnicodeEmoji._new("1f3c5", ":medal:");
  static final UnicodeEmoji reminder_ribbon =
      new UnicodeEmoji._new("1f397", ":reminder_ribbon:");
  static final UnicodeEmoji popcorn =
      new UnicodeEmoji._new("1f37f", ":popcorn:");
  static final UnicodeEmoji champagne =
      new UnicodeEmoji._new("1f37e", ":champagne:");
  static final UnicodeEmoji hot_pepper =
      new UnicodeEmoji._new("1f336", ":hot_pepper:");
  static final UnicodeEmoji burrito =
      new UnicodeEmoji._new("1f32f", ":burrito:");
  static final UnicodeEmoji taco = new UnicodeEmoji._new("1f32e", ":taco:");
  static final UnicodeEmoji hotdog = new UnicodeEmoji._new("1f32d", ":hotdog:");
  static final UnicodeEmoji shamrock =
      new UnicodeEmoji._new("2618", ":shamrock:");
  static final UnicodeEmoji comet = new UnicodeEmoji._new("2604", ":comet:");
  static final UnicodeEmoji turkey = new UnicodeEmoji._new("1f983", ":turkey:");
  static final UnicodeEmoji scorpion =
      new UnicodeEmoji._new("1f982", ":scorpion:");
  static final UnicodeEmoji lion_face =
      new UnicodeEmoji._new("1f981", ":lion_face:");
  static final UnicodeEmoji crab = new UnicodeEmoji._new("1f980", ":crab:");
  static final UnicodeEmoji spider_web =
      new UnicodeEmoji._new("1f578", ":spider_web:");
  static final UnicodeEmoji spider = new UnicodeEmoji._new("1f577", ":spider:");
  static final UnicodeEmoji chipmunk =
      new UnicodeEmoji._new("1f43f", ":chipmunk:");
  static final UnicodeEmoji wind_blowing_face =
      new UnicodeEmoji._new("1f32c", ":wind_blowing_face:");
  static final UnicodeEmoji fog = new UnicodeEmoji._new("1f32b", ":fog:");
  static final UnicodeEmoji play_pause =
      new UnicodeEmoji._new("23ef", ":play_pause:");
  static final UnicodeEmoji track_previous =
      new UnicodeEmoji._new("23ee", ":track_previous:");
  static final UnicodeEmoji track_next =
      new UnicodeEmoji._new("23ed", ":track_next:");
  static final UnicodeEmoji beach_umbrella =
      new UnicodeEmoji._new("26f1", ":beach_umbrella:");
  static final UnicodeEmoji chains = new UnicodeEmoji._new("26d3", ":chains:");
  static final UnicodeEmoji pick = new UnicodeEmoji._new("26cf", ":pick:");
  static final UnicodeEmoji stopwatch =
      new UnicodeEmoji._new("23f1", ":stopwatch:");
  static final UnicodeEmoji ferry = new UnicodeEmoji._new("26f4", ":ferry:");
  static final UnicodeEmoji mountain =
      new UnicodeEmoji._new("26f0", ":mountain:");
  static final UnicodeEmoji shinto_shrine =
      new UnicodeEmoji._new("2.6E+10", ":shinto_shrine:");
  static final UnicodeEmoji ice_skate =
      new UnicodeEmoji._new("26f8", ":ice_skate:");
  static final UnicodeEmoji skier = new UnicodeEmoji._new("26f7", ":skier:");
  static final UnicodeEmoji black_heart =
      new UnicodeEmoji._new("1f5a4", ":black_heart:");
  static final UnicodeEmoji speech_left =
      new UnicodeEmoji._new("1f5e8", ":speech_left:");
  static final UnicodeEmoji egg = new UnicodeEmoji._new("1f95a", ":egg:");
  static final UnicodeEmoji octagonal_sign =
      new UnicodeEmoji._new("1f6d1", ":octagonal_sign:");
  static final UnicodeEmoji spades = new UnicodeEmoji._new("2660", ":spades:");
  static final UnicodeEmoji hearts = new UnicodeEmoji._new("2665", ":hearts:");
  static final UnicodeEmoji diamonds =
      new UnicodeEmoji._new("2666", ":diamonds:");
  static final UnicodeEmoji clubs = new UnicodeEmoji._new("2663", ":clubs:");
  static final UnicodeEmoji drum = new UnicodeEmoji._new("1f941", ":drum:");
  static final UnicodeEmoji left_right_arrow =
      new UnicodeEmoji._new("2194", ":left_right_arrow:");
  static final UnicodeEmoji copyright =
      new UnicodeEmoji._new("00a9", ":copyright:");
  static final UnicodeEmoji registered =
      new UnicodeEmoji._new("00ae", ":registered:");
  static final UnicodeEmoji tm = new UnicodeEmoji._new("2122", ":tm:");
}
