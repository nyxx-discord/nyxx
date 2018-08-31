import 'dart:async';
import 'dart:mirrors';
import 'package:nyxx/nyxx.dart';

/// List of all Unicode Emojis (not really) :D
/// Class contains 1200+ emojis which has unicode hex value and shortcode.
class EmojisUnicode {
  /// Returns [Emoji] based on shortcode (eg. ":smile:")
  /// This method can be slow(extremely slow), because it uses mirrors to lookup for matching property in class.
  /// In future it will be rewritten to map.
  static Future<UnicodeEmoji> fromShortCode(String shortCode) {
    return Future(() {
      String normalize(String s) {
        if (s.startsWith(":") && s.endsWith(":")) return s;
        return ":$s:";
      }

      shortCode = normalize(shortCode);

      var mirror = reflectClass(EmojisUnicode);
      var variables =
          mirror.declarations.values.where((i) => i is VariableMirror);
      for (var variable in variables) {
        var emo =
            mirror.getField(variable.simpleName).reflectee as UnicodeEmoji;
        if (emo.name == shortCode) return emo;
      }

      return null;
    });
  }

  /// Allows to find emojis based on its hex code.
  static Future<UnicodeEmoji> fromHexCode(String hexCode) {
    return Future(() {
      var mirror = reflectClass(EmojisUnicode);
      var variables =
          mirror.declarations.values.where((i) => i is VariableMirror);
      for (var variable in variables) {
        var emo =
            mirror.getField(variable.simpleName).reflectee as UnicodeEmoji;
        if (emo.code == hexCode) return emo;
      }

      return null;
    });
  }

  static final UnicodeEmoji joy = UnicodeEmoji("1f602", ":joy:");
  static final UnicodeEmoji heart = UnicodeEmoji("2764", ":heart:");
  static final UnicodeEmoji heart_eyes = UnicodeEmoji("1f60d", ":heart_eyes:");
  static final UnicodeEmoji sob = UnicodeEmoji("1f62d", ":sob:");
  static final UnicodeEmoji blush = UnicodeEmoji("1f60a", ":blush:");
  static final UnicodeEmoji unamused = UnicodeEmoji("1f612", ":unamused:");
  static final UnicodeEmoji kissing_heart =
      UnicodeEmoji("1f618", ":kissing_heart:");
  static final UnicodeEmoji two_hearts = UnicodeEmoji("1f495", ":two_hearts:");
  static final UnicodeEmoji weary = UnicodeEmoji("1f629", ":weary:");
  static final UnicodeEmoji ok_hand = UnicodeEmoji("1f44c", ":ok_hand:");
  static final UnicodeEmoji pensive = UnicodeEmoji("1f614", ":pensive:");
  static final UnicodeEmoji smirk = UnicodeEmoji("1f60f", ":smirk:");
  static final UnicodeEmoji grin = UnicodeEmoji("1f601", ":grin:");
  static final UnicodeEmoji recycle = UnicodeEmoji("267b", ":recycle:");
  static final UnicodeEmoji wink = UnicodeEmoji("1f609", ":wink:");
  static final UnicodeEmoji thumbsup = UnicodeEmoji("1f44d", ":thumbsup:");
  static final UnicodeEmoji pray = UnicodeEmoji("1f64f", ":pray:");
  static final UnicodeEmoji relieved = UnicodeEmoji("1f60c", ":relieved:");
  static final UnicodeEmoji notes = UnicodeEmoji("1f3b6", ":notes:");
  static final UnicodeEmoji flushed = UnicodeEmoji("1f633", ":flushed:");
  static final UnicodeEmoji raised_hands =
      UnicodeEmoji("1f64c", ":raised_hands:");
  static final UnicodeEmoji see_no_evil =
      UnicodeEmoji("1f648", ":see_no_evil:");
  static final UnicodeEmoji cry = UnicodeEmoji("1f622", ":cry:");
  static final UnicodeEmoji sunglasses = UnicodeEmoji("1f60e", ":sunglasses:");
  static final UnicodeEmoji v = UnicodeEmoji("270c", ":v:");
  static final UnicodeEmoji eyes = UnicodeEmoji("1f440", ":eyes:");
  static final UnicodeEmoji sweat_smile =
      UnicodeEmoji("1f605", ":sweat_smile:");
  static final UnicodeEmoji sparkles = UnicodeEmoji("2728", ":sparkles:");
  static final UnicodeEmoji sleeping = UnicodeEmoji("1f634", ":sleeping:");
  static final UnicodeEmoji smile = UnicodeEmoji("1f604", ":smile:");
  static final UnicodeEmoji purple_heart =
      UnicodeEmoji("1f49c", ":purple_heart:");
  static final UnicodeEmoji broken_heart =
      UnicodeEmoji("1f494", ":broken_heart:");
  static final UnicodeEmoji expressionless =
      UnicodeEmoji("1f611", ":expressionless:");
  static final UnicodeEmoji sparkling_heart =
      UnicodeEmoji("1f496", ":sparkling_heart:");
  static final UnicodeEmoji blue_heart = UnicodeEmoji("1f499", ":blue_heart:");
  static final UnicodeEmoji confused = UnicodeEmoji("1f615", ":confused:");
  static final UnicodeEmoji information_desk_person =
      UnicodeEmoji("1f481", ":information_desk_person:");
  static final UnicodeEmoji stuck_out_tongue_winking_eye =
      UnicodeEmoji("1f61c", ":stuck_out_tongue_winking_eye:");
  static final UnicodeEmoji disappointed =
      UnicodeEmoji("1f61e", ":disappointed:");
  static final UnicodeEmoji yum = UnicodeEmoji("1f60b", ":yum:");
  static final UnicodeEmoji neutral_face =
      UnicodeEmoji("1f610", ":neutral_face:");
  static final UnicodeEmoji sleepy = UnicodeEmoji("1f62a", ":sleepy:");
  static final UnicodeEmoji clap = UnicodeEmoji("1f44f", ":clap:");
  static final UnicodeEmoji cupid = UnicodeEmoji("1f498", ":cupid:");
  static final UnicodeEmoji heartpulse = UnicodeEmoji("1f497", ":heartpulse:");
  static final UnicodeEmoji revolving_hearts =
      UnicodeEmoji("1f49e", ":revolving_hearts:");
  static final UnicodeEmoji arrow_left = UnicodeEmoji("2b05", ":arrow_left:");
  static final UnicodeEmoji speak_no_evil =
      UnicodeEmoji("1f64a", ":speak_no_evil:");
  static final UnicodeEmoji kiss = UnicodeEmoji("1f48b", ":kiss:");
  static final UnicodeEmoji point_right =
      UnicodeEmoji("1f449", ":point_right:");
  static final UnicodeEmoji cherry_blossom =
      UnicodeEmoji("1f338", ":cherry_blossom:");
  static final UnicodeEmoji scream = UnicodeEmoji("1f631", ":scream:");
  static final UnicodeEmoji fire = UnicodeEmoji("1f525", ":fire:");
  static final UnicodeEmoji rage = UnicodeEmoji("1f621", ":rage:");
  static final UnicodeEmoji smiley = UnicodeEmoji("1f603", ":smiley:");
  static final UnicodeEmoji tada = UnicodeEmoji("1f389", ":tada:");
  static final UnicodeEmoji tired_face = UnicodeEmoji("1f62b", ":tired_face:");
  static final UnicodeEmoji camera = UnicodeEmoji("1f4f7", ":camera:");
  static final UnicodeEmoji rose = UnicodeEmoji("1f339", ":rose:");
  static final UnicodeEmoji stuck_out_tongue_closed_eyes =
      UnicodeEmoji("1f61d", ":stuck_out_tongue_closed_eyes:");
  static final UnicodeEmoji muscle = UnicodeEmoji("1f4aa", ":muscle:");
  static final UnicodeEmoji skull = UnicodeEmoji("1f480", ":skull:");
  static final UnicodeEmoji sunny = UnicodeEmoji("2600", ":sunny:");
  static final UnicodeEmoji yellow_heart =
      UnicodeEmoji("1f49b", ":yellow_heart:");
  static final UnicodeEmoji triumph = UnicodeEmoji("1f624", ":triumph:");
  static final UnicodeEmoji new_moon_with_face =
      UnicodeEmoji("1f31a", ":new_moon_with_face:");
  static final UnicodeEmoji laughing = UnicodeEmoji("1f606", ":laughing:");
  static final UnicodeEmoji sweat = UnicodeEmoji("1f613", ":sweat:");
  static final UnicodeEmoji point_left = UnicodeEmoji("1f448", ":point_left:");
  static final UnicodeEmoji heavy_check_mark =
      UnicodeEmoji("2714", ":heavy_check_mark:");
  static final UnicodeEmoji heart_eyes_cat =
      UnicodeEmoji("1f63b", ":heart_eyes_cat:");
  static final UnicodeEmoji grinning = UnicodeEmoji("1f600", ":grinning:");
  static final UnicodeEmoji mask = UnicodeEmoji("1f637", ":mask:");
  static final UnicodeEmoji green_heart =
      UnicodeEmoji("1f49a", ":green_heart:");
  static final UnicodeEmoji wave = UnicodeEmoji("1f44b", ":wave:");
  static final UnicodeEmoji persevere = UnicodeEmoji("1f623", ":persevere:");
  static final UnicodeEmoji heartbeat = UnicodeEmoji("1f493", ":heartbeat:");
  static final UnicodeEmoji arrow_forward =
      UnicodeEmoji("25b6", ":arrow_forward:");
  static final UnicodeEmoji arrow_backward =
      UnicodeEmoji("25c0", ":arrow_backward:");
  static final UnicodeEmoji arrow_right_hook =
      UnicodeEmoji("21aa", ":arrow_right_hook:");
  static final UnicodeEmoji leftwards_arrow_with_hook =
      UnicodeEmoji("21a9", ":leftwards_arrow_with_hook:");
  static final UnicodeEmoji crown = UnicodeEmoji("1f451", ":crown:");
  static final UnicodeEmoji kissing_closed_eyes =
      UnicodeEmoji("1f61a", ":kissing_closed_eyes:");
  static final UnicodeEmoji stuck_out_tongue =
      UnicodeEmoji("1f61b", ":stuck_out_tongue:");
  static final UnicodeEmoji disappointed_relieved =
      UnicodeEmoji("1f625", ":disappointed_relieved:");
  static final UnicodeEmoji innocent = UnicodeEmoji("1f607", ":innocent:");
  static final UnicodeEmoji headphones = UnicodeEmoji("1f3a7", ":headphones:");
  static final UnicodeEmoji white_check_mark =
      UnicodeEmoji("2705", ":white_check_mark:");
  static final UnicodeEmoji confounded = UnicodeEmoji("1f616", ":confounded:");
  static final UnicodeEmoji arrow_right = UnicodeEmoji("27a1", ":arrow_right:");
  static final UnicodeEmoji angry = UnicodeEmoji("1f620", ":angry:");
  static final UnicodeEmoji grimacing = UnicodeEmoji("1f62c", ":grimacing:");
  static final UnicodeEmoji star2 = UnicodeEmoji("1f31f", ":star2:");
  static final UnicodeEmoji gun = UnicodeEmoji("1f52b", ":gun:");
  static final UnicodeEmoji raising_hand =
      UnicodeEmoji("1f64b", ":raising_hand:");
  static final UnicodeEmoji thumbsdown = UnicodeEmoji("1f44e", ":thumbsdown:");
  static final UnicodeEmoji dancer = UnicodeEmoji("1f483", ":dancer:");
  static final UnicodeEmoji musical_note =
      UnicodeEmoji("1f3b5", ":musical_note:");
  static final UnicodeEmoji no_mouth = UnicodeEmoji("1f636", ":no_mouth:");
  static final UnicodeEmoji dizzy = UnicodeEmoji("1f4ab", ":dizzy:");
  static final UnicodeEmoji fist = UnicodeEmoji("270a", ":fist:");
  static final UnicodeEmoji point_down = UnicodeEmoji("1f447", ":point_down:");
  static final UnicodeEmoji red_circle = UnicodeEmoji("1f534", ":red_circle:");
  static final UnicodeEmoji no_good = UnicodeEmoji("1f645", ":no_good:");
  static final UnicodeEmoji boom = UnicodeEmoji("1f4a5", ":boom:");
  static final UnicodeEmoji thought_balloon =
      UnicodeEmoji("1f4ad", ":thought_balloon:");
  static final UnicodeEmoji tongue = UnicodeEmoji("1f445", ":tongue:");
  static final UnicodeEmoji cold_sweat = UnicodeEmoji("1f630", ":cold_sweat:");
  static final UnicodeEmoji gem = UnicodeEmoji("1f48e", ":gem:");
  static final UnicodeEmoji ok_woman = UnicodeEmoji("1f646", ":ok_woman:");
  static final UnicodeEmoji pizza = UnicodeEmoji("1f355", ":pizza:");
  static final UnicodeEmoji joy_cat = UnicodeEmoji("1f639", ":joy_cat:");
  static final UnicodeEmoji sun_with_face =
      UnicodeEmoji("1f31e", ":sun_with_face:");
  static final UnicodeEmoji leaves = UnicodeEmoji("1f343", ":leaves:");
  static final UnicodeEmoji sweat_drops =
      UnicodeEmoji("1f4a6", ":sweat_drops:");
  static final UnicodeEmoji penguin = UnicodeEmoji("1f427", ":penguin:");
  static final UnicodeEmoji zzz = UnicodeEmoji("1f4a4", ":zzz:");
  static final UnicodeEmoji walking = UnicodeEmoji("1f6b6", ":walking:");
  static final UnicodeEmoji airplane = UnicodeEmoji("2708", ":airplane:");
  static final UnicodeEmoji balloon = UnicodeEmoji("1f388", ":balloon:");
  static final UnicodeEmoji star = UnicodeEmoji("2b50", ":star:");
  static final UnicodeEmoji ribbon = UnicodeEmoji("1f380", ":ribbon:");
  static final UnicodeEmoji ballot_box_with_check =
      UnicodeEmoji("2611", ":ballot_box_with_check:");
  static final UnicodeEmoji worried = UnicodeEmoji("1f61f", ":worried:");
  static final UnicodeEmoji underage = UnicodeEmoji("1f51e", ":underage:");
  static final UnicodeEmoji fearful = UnicodeEmoji("1f628", ":fearful:");
  static final UnicodeEmoji four_leaf_clover =
      UnicodeEmoji("1f340", ":four_leaf_clover:");
  static final UnicodeEmoji hibiscus = UnicodeEmoji("1f33a", ":hibiscus:");
  static final UnicodeEmoji microphone = UnicodeEmoji("1f3a4", ":microphone:");
  static final UnicodeEmoji open_hands = UnicodeEmoji("1f450", ":open_hands:");
  static final UnicodeEmoji ghost = UnicodeEmoji("1f47b", ":ghost:");
  static final UnicodeEmoji palm_tree = UnicodeEmoji("1f334", ":palm_tree:");
  static final UnicodeEmoji bangbang = UnicodeEmoji("203c", ":bangbang:");
  static final UnicodeEmoji nail_care = UnicodeEmoji("1f485", ":nail_care:");
  static final UnicodeEmoji x = UnicodeEmoji("274c", ":x:");
  static final UnicodeEmoji alien = UnicodeEmoji("1f47d", ":alien:");
  static final UnicodeEmoji bow = UnicodeEmoji("1f647", ":bow:");
  static final UnicodeEmoji cloud = UnicodeEmoji("2601", ":cloud:");
  static final UnicodeEmoji soccer = UnicodeEmoji("26bd", ":soccer:");
  static final UnicodeEmoji angel = UnicodeEmoji("1f47c", ":angel:");
  static final UnicodeEmoji dancers = UnicodeEmoji("1f46f", ":dancers:");
  static final UnicodeEmoji exclamation = UnicodeEmoji("2757", ":exclamation:");
  static final UnicodeEmoji snowflake = UnicodeEmoji("2744", ":snowflake:");
  static final UnicodeEmoji point_up = UnicodeEmoji("261d", ":point_up:");
  static final UnicodeEmoji kissing_smiling_eyes =
      UnicodeEmoji("1f619", ":kissing_smiling_eyes:");
  static final UnicodeEmoji rainbow = UnicodeEmoji("1f308", ":rainbow:");
  static final UnicodeEmoji crescent_moon =
      UnicodeEmoji("1f319", ":crescent_moon:");
  static final UnicodeEmoji heart_decoration =
      UnicodeEmoji("1f49f", ":heart_decoration:");
  static final UnicodeEmoji gift_heart = UnicodeEmoji("1f49d", ":gift_heart:");
  static final UnicodeEmoji gift = UnicodeEmoji("1f381", ":gift:");
  static final UnicodeEmoji beers = UnicodeEmoji("1f37b", ":beers:");
  static final UnicodeEmoji anguished = UnicodeEmoji("1f627", ":anguished:");
  static final UnicodeEmoji earth_africa =
      UnicodeEmoji("1f30d", ":earth_africa:");
  static final UnicodeEmoji movie_camera =
      UnicodeEmoji("1f3a5", ":movie_camera:");
  static final UnicodeEmoji anchor = UnicodeEmoji("2693", ":anchor:");
  static final UnicodeEmoji zap = UnicodeEmoji("26a1", ":zap:");
  static final UnicodeEmoji heavy_multiplication_x =
      UnicodeEmoji("2716", ":heavy_multiplication_x:");
  static final UnicodeEmoji runner = UnicodeEmoji("1f3c3", ":runner:");
  static final UnicodeEmoji sunflower = UnicodeEmoji("1f33b", ":sunflower:");
  static final UnicodeEmoji earth_americas =
      UnicodeEmoji("1f30e", ":earth_americas:");
  static final UnicodeEmoji bouquet = UnicodeEmoji("1f490", ":bouquet:");
  static final UnicodeEmoji dog = UnicodeEmoji("1f436", ":dog:");
  static final UnicodeEmoji moneybag = UnicodeEmoji("1f4b0", ":moneybag:");
  static final UnicodeEmoji herb = UnicodeEmoji("1f33f", ":herb:");
  static final UnicodeEmoji couple = UnicodeEmoji("1f46b", ":couple:");
  static final UnicodeEmoji fallen_leaf =
      UnicodeEmoji("1f342", ":fallen_leaf:");
  static final UnicodeEmoji tulip = UnicodeEmoji("1f337", ":tulip:");
  static final UnicodeEmoji birthday = UnicodeEmoji("1f382", ":birthday:");
  static final UnicodeEmoji cat = UnicodeEmoji("1f431", ":cat:");
  static final UnicodeEmoji coffee = UnicodeEmoji("2615", ":coffee:");
  static final UnicodeEmoji dizzy_face = UnicodeEmoji("1f635", ":dizzy_face:");
  static final UnicodeEmoji point_up_2 = UnicodeEmoji("1f446", ":point_up_2:");
  static final UnicodeEmoji open_mouth = UnicodeEmoji("1f62e", ":open_mouth:");
  static final UnicodeEmoji hushed = UnicodeEmoji("1f62f", ":hushed:");
  static final UnicodeEmoji basketball = UnicodeEmoji("1f3c0", ":basketball:");
  static final UnicodeEmoji christmas_tree =
      UnicodeEmoji("1f384", ":christmas_tree:");
  static final UnicodeEmoji ring = UnicodeEmoji("1f48d", ":ring:");
  static final UnicodeEmoji full_moon_with_face =
      UnicodeEmoji("1f31d", ":full_moon_with_face:");
  static final UnicodeEmoji astonished = UnicodeEmoji("1f632", ":astonished:");
  static final UnicodeEmoji two_women_holding_hands =
      UnicodeEmoji("1f46d", ":two_women_holding_hands:");
  static final UnicodeEmoji money_with_wings =
      UnicodeEmoji("1f4b8", ":money_with_wings:");
  static final UnicodeEmoji crying_cat_face =
      UnicodeEmoji("1f63f", ":crying_cat_face:");
  static final UnicodeEmoji hear_no_evil =
      UnicodeEmoji("1f649", ":hear_no_evil:");
  static final UnicodeEmoji dash = UnicodeEmoji("1f4a8", ":dash:");
  static final UnicodeEmoji cactus = UnicodeEmoji("1f335", ":cactus:");
  static final UnicodeEmoji hotsprings = UnicodeEmoji("2668", ":hotsprings:");
  static final UnicodeEmoji telephone = UnicodeEmoji("260e", ":telephone:");
  static final UnicodeEmoji maple_leaf = UnicodeEmoji("1f341", ":maple_leaf:");
  static final UnicodeEmoji princess = UnicodeEmoji("1f478", ":princess:");
  static final UnicodeEmoji massage = UnicodeEmoji("1f486", ":massage:");
  static final UnicodeEmoji love_letter =
      UnicodeEmoji("1f48c", ":love_letter:");
  static final UnicodeEmoji trophy = UnicodeEmoji("1f3c6", ":trophy:");
  static final UnicodeEmoji person_frowning =
      UnicodeEmoji("1f64d", ":person_frowning:");
  static final UnicodeEmoji confetti_ball =
      UnicodeEmoji("1f38a", ":confetti_ball:");
  static final UnicodeEmoji blossom = UnicodeEmoji("1f33c", ":blossom:");
  static final UnicodeEmoji lips = UnicodeEmoji("1f444", ":lips:");
  static final UnicodeEmoji fries = UnicodeEmoji("1f35f", ":fries:");
  static final UnicodeEmoji doughnut = UnicodeEmoji("1f369", ":doughnut:");
  static final UnicodeEmoji frowning = UnicodeEmoji("1f626", ":frowning:");
  static final UnicodeEmoji ocean = UnicodeEmoji("1f30a", ":ocean:");
  static final UnicodeEmoji bomb = UnicodeEmoji("1f4a3", ":bomb:");
  static final UnicodeEmoji ok = UnicodeEmoji("1f197", ":ok:");
  static final UnicodeEmoji cyclone = UnicodeEmoji("1f300", ":cyclone:");
  static final UnicodeEmoji rocket = UnicodeEmoji("1f680", ":rocket:");
  static final UnicodeEmoji umbrella = UnicodeEmoji("2614", ":umbrella:");
  static final UnicodeEmoji couplekiss = UnicodeEmoji("1f48f", ":couplekiss:");
  static final UnicodeEmoji couple_with_heart =
      UnicodeEmoji("1f491", ":couple_with_heart:");
  static final UnicodeEmoji lollipop = UnicodeEmoji("1f36d", ":lollipop:");
  static final UnicodeEmoji clapper = UnicodeEmoji("1f3ac", ":clapper:");
  static final UnicodeEmoji pig = UnicodeEmoji("1f437", ":pig:");
  static final UnicodeEmoji smiling_imp =
      UnicodeEmoji("1f608", ":smiling_imp:");
  static final UnicodeEmoji imp = UnicodeEmoji("1f47f", ":imp:");
  static final UnicodeEmoji bee = UnicodeEmoji("1f41d", ":bee:");
  static final UnicodeEmoji kissing_cat =
      UnicodeEmoji("1f63d", ":kissing_cat:");
  static final UnicodeEmoji anger = UnicodeEmoji("1f4a2", ":anger:");
  static final UnicodeEmoji musical_score =
      UnicodeEmoji("1f3bc", ":musical_score:");
  static final UnicodeEmoji santa = UnicodeEmoji("1f385", ":santa:");
  static final UnicodeEmoji earth_asia = UnicodeEmoji("1f30f", ":earth_asia:");
  static final UnicodeEmoji football = UnicodeEmoji("1f3c8", ":football:");
  static final UnicodeEmoji guitar = UnicodeEmoji("1f3b8", ":guitar:");
  static final UnicodeEmoji panda_face = UnicodeEmoji("1f43c", ":panda_face:");
  static final UnicodeEmoji speech_balloon =
      UnicodeEmoji("1f4ac", ":speech_balloon:");
  static final UnicodeEmoji strawberry = UnicodeEmoji("1f353", ":strawberry:");
  static final UnicodeEmoji smirk_cat = UnicodeEmoji("1f63c", ":smirk_cat:");
  static final UnicodeEmoji banana = UnicodeEmoji("1f34c", ":banana:");
  static final UnicodeEmoji watermelon = UnicodeEmoji("1f349", ":watermelon:");
  static final UnicodeEmoji snowman = UnicodeEmoji("26c4", ":snowman:");
  static final UnicodeEmoji smile_cat = UnicodeEmoji("1f638", ":smile_cat:");
  static final UnicodeEmoji top = UnicodeEmoji("1f51d", ":top:");
  static final UnicodeEmoji eggplant = UnicodeEmoji("1f346", ":eggplant:");
  static final UnicodeEmoji crystal_ball =
      UnicodeEmoji("1f52e", ":crystal_ball:");
  static final UnicodeEmoji fork_and_knife =
      UnicodeEmoji("1f374", ":fork_and_knife:");
  static final UnicodeEmoji calling = UnicodeEmoji("1f4f2", ":calling:");
  static final UnicodeEmoji iphone = UnicodeEmoji("1f4f1", ":iphone:");
  static final UnicodeEmoji partly_sunny =
      UnicodeEmoji("26c5", ":partly_sunny:");
  static final UnicodeEmoji warning = UnicodeEmoji("26a0", ":warning:");
  static final UnicodeEmoji scream_cat = UnicodeEmoji("1f640", ":scream_cat:");
  static final UnicodeEmoji small_orange_diamond =
      UnicodeEmoji("1f538", ":small_orange_diamond:");
  static final UnicodeEmoji baby = UnicodeEmoji("1f476", ":baby:");
  static final UnicodeEmoji feet = UnicodeEmoji("1f43e", ":feet:");
  static final UnicodeEmoji footprints = UnicodeEmoji("1f463", ":footprints:");
  static final UnicodeEmoji beer = UnicodeEmoji("1f37a", ":beer:");
  static final UnicodeEmoji wine_glass = UnicodeEmoji("1f377", ":wine_glass:");
  static final UnicodeEmoji o = UnicodeEmoji("2b55", ":o:");
  static final UnicodeEmoji video_camera =
      UnicodeEmoji("1f4f9", ":video_camera:");
  static final UnicodeEmoji rabbit = UnicodeEmoji("1f430", ":rabbit:");
  static final UnicodeEmoji tropical_drink =
      UnicodeEmoji("1f379", ":tropical_drink:");
  static final UnicodeEmoji smoking = UnicodeEmoji("1f6ac", ":smoking:");
  static final UnicodeEmoji space_invader =
      UnicodeEmoji("1f47e", ":space_invader:");
  static final UnicodeEmoji peach = UnicodeEmoji("1f351", ":peach:");
  static final UnicodeEmoji snake = UnicodeEmoji("1f40d", ":snake:");
  static final UnicodeEmoji turtle = UnicodeEmoji("1f422", ":turtle:");
  static final UnicodeEmoji cherries = UnicodeEmoji("1f352", ":cherries:");
  static final UnicodeEmoji kissing = UnicodeEmoji("1f617", ":kissing:");
  static final UnicodeEmoji frog = UnicodeEmoji("1f438", ":frog:");
  static final UnicodeEmoji milky_way = UnicodeEmoji("1f30c", ":milky_way:");
  static final UnicodeEmoji rotating_light =
      UnicodeEmoji("1f6a8", ":rotating_light:");
  static final UnicodeEmoji hatching_chick =
      UnicodeEmoji("1f423", ":hatching_chick:");
  static final UnicodeEmoji closed_book =
      UnicodeEmoji("1f4d5", ":closed_book:");
  static final UnicodeEmoji candy = UnicodeEmoji("1f36c", ":candy:");
  static final UnicodeEmoji hamburger = UnicodeEmoji("1f354", ":hamburger:");
  static final UnicodeEmoji bear = UnicodeEmoji("1f43b", ":bear:");
  static final UnicodeEmoji tiger = UnicodeEmoji("1f42f", ":tiger:");
  static final UnicodeEmoji fast_forward =
      UnicodeEmoji("2.3E+10", ":fast_forward:");
  static final UnicodeEmoji icecream = UnicodeEmoji("1f366", ":icecream:");
  static final UnicodeEmoji pineapple = UnicodeEmoji("1f34d", ":pineapple:");
  static final UnicodeEmoji ear_of_rice =
      UnicodeEmoji("1f33e", ":ear_of_rice:");
  static final UnicodeEmoji syringe = UnicodeEmoji("1f489", ":syringe:");
  static final UnicodeEmoji put_litter_in_its_place =
      UnicodeEmoji("1f6ae", ":put_litter_in_its_place:");
  static final UnicodeEmoji chocolate_bar =
      UnicodeEmoji("1f36b", ":chocolate_bar:");
  static final UnicodeEmoji black_small_square =
      UnicodeEmoji("25aa", ":black_small_square:");
  static final UnicodeEmoji tv = UnicodeEmoji("1f4fa", ":tv:");
  static final UnicodeEmoji pill = UnicodeEmoji("1f48a", ":pill:");
  static final UnicodeEmoji octopus = UnicodeEmoji("1f419", ":octopus:");
  static final UnicodeEmoji jack_o_lantern =
      UnicodeEmoji("1f383", ":jack_o_lantern:");
  static final UnicodeEmoji grapes = UnicodeEmoji("1f347", ":grapes:");
  static final UnicodeEmoji smiley_cat = UnicodeEmoji("1f63a", ":smiley_cat:");
  static final UnicodeEmoji cd = UnicodeEmoji("1f4bf", ":cd:");
  static final UnicodeEmoji cocktail = UnicodeEmoji("1f378", ":cocktail:");
  static final UnicodeEmoji cake = UnicodeEmoji("1f370", ":cake:");
  static final UnicodeEmoji video_game = UnicodeEmoji("1f3ae", ":video_game:");
  static final UnicodeEmoji arrow_down = UnicodeEmoji("2b07", ":arrow_down:");
  static final UnicodeEmoji no_entry_sign =
      UnicodeEmoji("1f6ab", ":no_entry_sign:");
  static final UnicodeEmoji lipstick = UnicodeEmoji("1f484", ":lipstick:");
  static final UnicodeEmoji whale = UnicodeEmoji("1f433", ":whale:");
  static final UnicodeEmoji cookie = UnicodeEmoji("1f36a", ":cookie:");
  static final UnicodeEmoji dolphin = UnicodeEmoji("1f42c", ":dolphin:");
  static final UnicodeEmoji loud_sound = UnicodeEmoji("1f50a", ":loud_sound:");
  static final UnicodeEmoji man = UnicodeEmoji("1f468", ":man:");
  static final UnicodeEmoji hatched_chick =
      UnicodeEmoji("1f425", ":hatched_chick:");
  static final UnicodeEmoji monkey = UnicodeEmoji("1f412", ":monkey:");
  static final UnicodeEmoji books = UnicodeEmoji("1f4da", ":books:");
  static final UnicodeEmoji japanese_ogre =
      UnicodeEmoji("1f479", ":japanese_ogre:");
  static final UnicodeEmoji guardsman = UnicodeEmoji("1f482", ":guardsman:");
  static final UnicodeEmoji loudspeaker =
      UnicodeEmoji("1f4e2", ":loudspeaker:");
  static final UnicodeEmoji scissors = UnicodeEmoji("2702", ":scissors:");
  static final UnicodeEmoji girl = UnicodeEmoji("1f467", ":girl:");
  static final UnicodeEmoji mortar_board =
      UnicodeEmoji("1f393", ":mortar_board:");
  static final UnicodeEmoji France = UnicodeEmoji("1f1eb", ":fr:");
  static final UnicodeEmoji baseball = UnicodeEmoji("26be", ":baseball:");
  static final UnicodeEmoji vertical_traffic_light =
      UnicodeEmoji("1f6a6", ":vertical_traffic_light:");
  static final UnicodeEmoji woman = UnicodeEmoji("1f469", ":woman:");
  static final UnicodeEmoji fireworks = UnicodeEmoji("1f386", ":fireworks:");
  static final UnicodeEmoji stars = UnicodeEmoji("1f320", ":stars:");
  static final UnicodeEmoji sos = UnicodeEmoji("1f198", ":sos:");
  static final UnicodeEmoji mushroom = UnicodeEmoji("1f344", ":mushroom:");
  static final UnicodeEmoji pouting_cat =
      UnicodeEmoji("1f63e", ":pouting_cat:");
  static final UnicodeEmoji left_luggage =
      UnicodeEmoji("1f6c5", ":left_luggage:");
  static final UnicodeEmoji high_heel = UnicodeEmoji("1f460", ":high_heel:");
  static final UnicodeEmoji dart = UnicodeEmoji("1f3af", ":dart:");
  static final UnicodeEmoji swimmer = UnicodeEmoji("1f3ca", ":swimmer:");
  static final UnicodeEmoji key = UnicodeEmoji("1f511", ":key:");
  static final UnicodeEmoji bikini = UnicodeEmoji("1f459", ":bikini:");
  static final UnicodeEmoji family = UnicodeEmoji("1f46a", ":family:");
  static final UnicodeEmoji pencil2 = UnicodeEmoji("270f", ":pencil2:");
  static final UnicodeEmoji elephant = UnicodeEmoji("1f418", ":elephant:");
  static final UnicodeEmoji droplet = UnicodeEmoji("1f4a7", ":droplet:");
  static final UnicodeEmoji seedling = UnicodeEmoji("1f331", ":seedling:");
  static final UnicodeEmoji apple = UnicodeEmoji("1f34e", ":apple:");
  static final UnicodeEmoji cool = UnicodeEmoji("1f192", ":cool:");
  static final UnicodeEmoji telephone_receiver =
      UnicodeEmoji("1f4de", ":telephone_receiver:");
  static final UnicodeEmoji dollar = UnicodeEmoji("1f4b5", ":dollar:");
  static final UnicodeEmoji house_with_garden =
      UnicodeEmoji("1f3e1", ":house_with_garden:");
  static final UnicodeEmoji book = UnicodeEmoji("1f4d6", ":book:");
  static final UnicodeEmoji haircut = UnicodeEmoji("1f487", ":haircut:");
  static final UnicodeEmoji computer = UnicodeEmoji("1f4bb", ":computer:");
  static final UnicodeEmoji bulb = UnicodeEmoji("1f4a1", ":bulb:");
  static final UnicodeEmoji question = UnicodeEmoji("2753", ":question:");
  static final UnicodeEmoji back = UnicodeEmoji("1f519", ":back:");
  static final UnicodeEmoji boy = UnicodeEmoji("1f466", ":boy:");
  static final UnicodeEmoji closed_lock_with_key =
      UnicodeEmoji("1f510", ":closed_lock_with_key:");
  static final UnicodeEmoji person_with_pouting_face =
      UnicodeEmoji("1f64e", ":person_with_pouting_face:");
  static final UnicodeEmoji tangerine = UnicodeEmoji("1f34a", ":tangerine:");
  static final UnicodeEmoji sunrise = UnicodeEmoji("1f305", ":sunrise:");
  static final UnicodeEmoji poultry_leg =
      UnicodeEmoji("1f357", ":poultry_leg:");
  static final UnicodeEmoji blue_circle =
      UnicodeEmoji("1f535", ":blue_circle:");
  static final UnicodeEmoji oncoming_automobile =
      UnicodeEmoji("1f698", ":oncoming_automobile:");
  static final UnicodeEmoji shaved_ice = UnicodeEmoji("1f367", ":shaved_ice:");
  static final UnicodeEmoji bird = UnicodeEmoji("1f426", ":bird:");
  static final UnicodeEmoji Great = UnicodeEmoji("Britain", ":gb:");
  static final UnicodeEmoji first_quarter_moon_with_face =
      UnicodeEmoji("1f31b", ":first_quarter_moon_with_face:");
  static final UnicodeEmoji eyeglasses = UnicodeEmoji("1f453", ":eyeglasses:");
  static final UnicodeEmoji goat = UnicodeEmoji("1f410", ":goat:");
  static final UnicodeEmoji night_with_stars =
      UnicodeEmoji("1f303", ":night_with_stars:");
  static final UnicodeEmoji older_woman =
      UnicodeEmoji("1f475", ":older_woman:");
  static final UnicodeEmoji black_circle =
      UnicodeEmoji("26ab", ":black_circle:");
  static final UnicodeEmoji new_moon = UnicodeEmoji("1f311", ":new_moon:");
  static final UnicodeEmoji two_men_holding_hands =
      UnicodeEmoji("1f46c", ":two_men_holding_hands:");
  static final UnicodeEmoji white_circle =
      UnicodeEmoji("26aa", ":white_circle:");
  static final UnicodeEmoji customs = UnicodeEmoji("1f6c3", ":customs:");
  static final UnicodeEmoji tropical_fish =
      UnicodeEmoji("1f420", ":tropical_fish:");
  static final UnicodeEmoji house = UnicodeEmoji("1f3e0", ":house:");
  static final UnicodeEmoji arrows_clockwise =
      UnicodeEmoji("1f503", ":arrows_clockwise:");
  static final UnicodeEmoji last_quarter_moon_with_face =
      UnicodeEmoji("1f31c", ":last_quarter_moon_with_face:");
  static final UnicodeEmoji round_pushpin =
      UnicodeEmoji("1f4cd", ":round_pushpin:");
  static final UnicodeEmoji full_moon = UnicodeEmoji("1f315", ":full_moon:");
  static final UnicodeEmoji athletic_shoe =
      UnicodeEmoji("1f45f", ":athletic_shoe:");
  static final UnicodeEmoji lemon = UnicodeEmoji("1f34b", ":lemon:");
  static final UnicodeEmoji baby_bottle =
      UnicodeEmoji("1f37c", ":baby_bottle:");
  static final UnicodeEmoji spaghetti = UnicodeEmoji("1f35d", ":spaghetti:");
  static final UnicodeEmoji wind_chime = UnicodeEmoji("1f390", ":wind_chime:");
  static final UnicodeEmoji fish_cake = UnicodeEmoji("1f365", ":fish_cake:");
  static final UnicodeEmoji evergreen_tree =
      UnicodeEmoji("1f332", ":evergreen_tree:");
  static final UnicodeEmoji up = UnicodeEmoji("1f199", ":up:");
  static final UnicodeEmoji arrow_up = UnicodeEmoji("2b06", ":arrow_up:");
  static final UnicodeEmoji arrow_upper_right =
      UnicodeEmoji("2197", ":arrow_upper_right:");
  static final UnicodeEmoji arrow_lower_right =
      UnicodeEmoji("2198", ":arrow_lower_right:");
  static final UnicodeEmoji arrow_lower_left =
      UnicodeEmoji("2199", ":arrow_lower_left:");
  static final UnicodeEmoji performing_arts =
      UnicodeEmoji("1f3ad", ":performing_arts:");
  static final UnicodeEmoji nose = UnicodeEmoji("1f443", ":nose:");
  static final UnicodeEmoji pig_nose = UnicodeEmoji("1f43d", ":pig_nose:");
  static final UnicodeEmoji fish = UnicodeEmoji("1f41f", ":fish:");
  static final UnicodeEmoji man_with_turban =
      UnicodeEmoji("1f473", ":man_with_turban:");
  static final UnicodeEmoji koala = UnicodeEmoji("1f428", ":koala:");
  static final UnicodeEmoji ear = UnicodeEmoji("1f442", ":ear:");
  static final UnicodeEmoji eight_spoked_asterisk =
      UnicodeEmoji("2733", ":eight_spoked_asterisk:");
  static final UnicodeEmoji small_blue_diamond =
      UnicodeEmoji("1f539", ":small_blue_diamond:");
  static final UnicodeEmoji shower = UnicodeEmoji("1f6bf", ":shower:");
  static final UnicodeEmoji bug = UnicodeEmoji("1f41b", ":bug:");
  static final UnicodeEmoji ramen = UnicodeEmoji("1f35c", ":ramen:");
  static final UnicodeEmoji tophat = UnicodeEmoji("1f3a9", ":tophat:");
  static final UnicodeEmoji bride_with_veil =
      UnicodeEmoji("1f470", ":bride_with_veil:");
  static final UnicodeEmoji fuelpump = UnicodeEmoji("26fd", ":fuelpump:");
  static final UnicodeEmoji checkered_flag =
      UnicodeEmoji("1f3c1", ":checkered_flag:");
  static final UnicodeEmoji horse = UnicodeEmoji("1f434", ":horse:");
  static final UnicodeEmoji watch = UnicodeEmoji("231a", ":watch:");
  static final UnicodeEmoji monkey_face =
      UnicodeEmoji("1f435", ":monkey_face:");
  static final UnicodeEmoji baby_symbol =
      UnicodeEmoji("1f6bc", ":baby_symbol:");
  static final UnicodeEmoji new_ = UnicodeEmoji("1f195", ":new:");
  static final UnicodeEmoji free = UnicodeEmoji("1f193", ":free:");
  static final UnicodeEmoji sparkler = UnicodeEmoji("1f387", ":sparkler:");
  static final UnicodeEmoji corn = UnicodeEmoji("1f33d", ":corn:");
  static final UnicodeEmoji tennis = UnicodeEmoji("1f3be", ":tennis:");
  static final UnicodeEmoji alarm_clock = UnicodeEmoji("23f0", ":alarm_clock:");
  static final UnicodeEmoji battery = UnicodeEmoji("1f50b", ":battery:");
  static final UnicodeEmoji grey_exclamation =
      UnicodeEmoji("2755", ":grey_exclamation:");
  static final UnicodeEmoji wolf = UnicodeEmoji("1f43a", ":wolf:");
  static final UnicodeEmoji moyai = UnicodeEmoji("1f5ff", ":moyai:");
  static final UnicodeEmoji cow = UnicodeEmoji("1f42e", ":cow:");
  static final UnicodeEmoji mega = UnicodeEmoji("1f4e3", ":mega:");
  static final UnicodeEmoji older_man = UnicodeEmoji("1f474", ":older_man:");
  static final UnicodeEmoji dress = UnicodeEmoji("1f457", ":dress:");
  static final UnicodeEmoji link = UnicodeEmoji("1f517", ":link:");
  static final UnicodeEmoji chicken = UnicodeEmoji("1f414", ":chicken:");
  static final UnicodeEmoji whale2 = UnicodeEmoji("1f40b", ":whale2:");
  static final UnicodeEmoji arrow_upper_left =
      UnicodeEmoji("2196", ":arrow_upper_left:");
  static final UnicodeEmoji deciduous_tree =
      UnicodeEmoji("1f333", ":deciduous_tree:");
  static final UnicodeEmoji bento = UnicodeEmoji("1f371", ":bento:");
  static final UnicodeEmoji pushpin = UnicodeEmoji("1f4cc", ":pushpin:");
  static final UnicodeEmoji soon = UnicodeEmoji("1f51c", ":soon:");
  static final UnicodeEmoji repeat = UnicodeEmoji("1f501", ":repeat:");
  static final UnicodeEmoji dragon = UnicodeEmoji("1f409", ":dragon:");
  static final UnicodeEmoji hamster = UnicodeEmoji("1f439", ":hamster:");
  static final UnicodeEmoji golf = UnicodeEmoji("26f3", ":golf:");
  static final UnicodeEmoji surfer = UnicodeEmoji("1f3c4", ":surfer:");
  static final UnicodeEmoji mouse = UnicodeEmoji("1f42d", ":mouse:");
  static final UnicodeEmoji waxing_crescent_moon =
      UnicodeEmoji("1f312", ":waxing_crescent_moon:");
  static final UnicodeEmoji blue_car = UnicodeEmoji("1f699", ":blue_car:");
  static final UnicodeEmoji a = UnicodeEmoji("1f170", ":a:");
  static final UnicodeEmoji interrobang = UnicodeEmoji("2049", ":interrobang:");
  static final UnicodeEmoji u5272 = UnicodeEmoji("1f239", ":u5272:");
  static final UnicodeEmoji electric_plug =
      UnicodeEmoji("1f50c", ":electric_plug:");
  static final UnicodeEmoji first_quarter_moon =
      UnicodeEmoji("1f313", ":first_quarter_moon:");
  static final UnicodeEmoji cancer = UnicodeEmoji("264b", ":cancer:");
  static final UnicodeEmoji trident = UnicodeEmoji("1f531", ":trident:");
  static final UnicodeEmoji bread = UnicodeEmoji("1f35e", ":bread:");
  static final UnicodeEmoji cop = UnicodeEmoji("1f46e", ":cop:");
  static final UnicodeEmoji tea = UnicodeEmoji("1f375", ":tea:");
  static final UnicodeEmoji fishing_pole_and_fish =
      UnicodeEmoji("1f3a3", ":fishing_pole_and_fish:");
  static final UnicodeEmoji bike = UnicodeEmoji("1f6b2", ":bike:");
  static final UnicodeEmoji rice = UnicodeEmoji("1f35a", ":rice:");
  static final UnicodeEmoji radio = UnicodeEmoji("1f4fb", ":radio:");
  static final UnicodeEmoji baby_chick = UnicodeEmoji("1f424", ":baby_chick:");
  static final UnicodeEmoji arrow_heading_down =
      UnicodeEmoji("2935", ":arrow_heading_down:");
  static final UnicodeEmoji waning_crescent_moon =
      UnicodeEmoji("1f318", ":waning_crescent_moon:");
  static final UnicodeEmoji arrow_up_down =
      UnicodeEmoji("2195", ":arrow_up_down:");
  static final UnicodeEmoji last_quarter_moon =
      UnicodeEmoji("1f317", ":last_quarter_moon:");
  static final UnicodeEmoji radio_button =
      UnicodeEmoji("1f518", ":radio_button:");
  static final UnicodeEmoji sheep = UnicodeEmoji("1f411", ":sheep:");
  static final UnicodeEmoji person_with_blond_hair =
      UnicodeEmoji("1f471", ":person_with_blond_hair:");
  static final UnicodeEmoji waning_gibbous_moon =
      UnicodeEmoji("1f316", ":waning_gibbous_moon:");
  static final UnicodeEmoji lock = UnicodeEmoji("1f512", ":lock:");
  static final UnicodeEmoji green_apple =
      UnicodeEmoji("1f34f", ":green_apple:");
  static final UnicodeEmoji japanese_goblin =
      UnicodeEmoji("1f47a", ":japanese_goblin:");
  static final UnicodeEmoji curly_loop = UnicodeEmoji("27b0", ":curly_loop:");
  static final UnicodeEmoji triangular_flag_on_post =
      UnicodeEmoji("1f6a9", ":triangular_flag_on_post:");
  static final UnicodeEmoji arrows_counterclockwise =
      UnicodeEmoji("1f504", ":arrows_counterclockwise:");
  static final UnicodeEmoji racehorse = UnicodeEmoji("1f40e", ":racehorse:");
  static final UnicodeEmoji fried_shrimp =
      UnicodeEmoji("1f364", ":fried_shrimp:");
  static final UnicodeEmoji sunrise_over_mountains =
      UnicodeEmoji("1f304", ":sunrise_over_mountains:");
  static final UnicodeEmoji volcano = UnicodeEmoji("1f30b", ":volcano:");
  static final UnicodeEmoji rooster = UnicodeEmoji("1f413", ":rooster:");
  static final UnicodeEmoji inbox_tray = UnicodeEmoji("1f4e5", ":inbox_tray:");
  static final UnicodeEmoji wedding = UnicodeEmoji("1f492", ":wedding:");
  static final UnicodeEmoji sushi = UnicodeEmoji("1f363", ":sushi:");
  static final UnicodeEmoji wavy_dash = UnicodeEmoji("3030", ":wavy_dash:");
  static final UnicodeEmoji ice_cream = UnicodeEmoji("1f368", ":ice_cream:");
  static final UnicodeEmoji rewind = UnicodeEmoji("23ea", ":rewind:");
  static final UnicodeEmoji tomato = UnicodeEmoji("1f345", ":tomato:");
  static final UnicodeEmoji rabbit2 = UnicodeEmoji("1f407", ":rabbit2:");
  static final UnicodeEmoji eight_pointed_black_star =
      UnicodeEmoji("2734", ":eight_pointed_black_star:");
  static final UnicodeEmoji small_red_triangle =
      UnicodeEmoji("1f53a", ":small_red_triangle:");
  static final UnicodeEmoji high_brightness =
      UnicodeEmoji("1f506", ":high_brightness:");
  static final UnicodeEmoji heavy_plus_sign =
      UnicodeEmoji("2795", ":heavy_plus_sign:");
  static final UnicodeEmoji man_with_gua_pi_mao =
      UnicodeEmoji("1f472", ":man_with_gua_pi_mao:");
  static final UnicodeEmoji convenience_store =
      UnicodeEmoji("1f3ea", ":convenience_store:");
  static final UnicodeEmoji busts_in_silhouette =
      UnicodeEmoji("1f465", ":busts_in_silhouette:");
  static final UnicodeEmoji beetle = UnicodeEmoji("1f41e", ":beetle:");
  static final UnicodeEmoji small_red_triangle_down =
      UnicodeEmoji("1f53b", ":small_red_triangle_down:");
  static final UnicodeEmoji arrow_heading_up =
      UnicodeEmoji("2934", ":arrow_heading_up:");
  static final UnicodeEmoji name_badge = UnicodeEmoji("1f4db", ":name_badge:");
  static final UnicodeEmoji bath = UnicodeEmoji("1f6c0", ":bath:");
  static final UnicodeEmoji no_entry = UnicodeEmoji("26d4", ":no_entry:");
  static final UnicodeEmoji crocodile = UnicodeEmoji("1f40a", ":crocodile:");
  static final UnicodeEmoji dog2 = UnicodeEmoji("1f415", ":dog2:");
  static final UnicodeEmoji cat2 = UnicodeEmoji("1f408", ":cat2:");
  static final UnicodeEmoji hammer = UnicodeEmoji("1f528", ":hammer:");
  static final UnicodeEmoji meat_on_bone =
      UnicodeEmoji("1f356", ":meat_on_bone:");
  static final UnicodeEmoji shell = UnicodeEmoji("1f41a", ":shell:");
  static final UnicodeEmoji sparkle = UnicodeEmoji("2747", ":sparkle:");
  static final UnicodeEmoji b = UnicodeEmoji("1f171", ":b:");
  static final UnicodeEmoji m = UnicodeEmoji("24c2", ":m:");
  static final UnicodeEmoji poodle = UnicodeEmoji("1f429", ":poodle:");
  static final UnicodeEmoji aquarius = UnicodeEmoji("2652", ":aquarius:");
  static final UnicodeEmoji stew = UnicodeEmoji("1f372", ":stew:");
  static final UnicodeEmoji jeans = UnicodeEmoji("1f456", ":jeans:");
  static final UnicodeEmoji honey_pot = UnicodeEmoji("1f36f", ":honey_pot:");
  static final UnicodeEmoji musical_keyboard =
      UnicodeEmoji("1f3b9", ":musical_keyboard:");
  static final UnicodeEmoji unlock = UnicodeEmoji("1f513", ":unlock:");
  static final UnicodeEmoji black_nib = UnicodeEmoji("2712", ":black_nib:");
  static final UnicodeEmoji statue_of_liberty =
      UnicodeEmoji("1f5fd", ":statue_of_liberty:");
  static final UnicodeEmoji heavy_dollar_sign =
      UnicodeEmoji("1f4b2", ":heavy_dollar_sign:");
  static final UnicodeEmoji snowboarder =
      UnicodeEmoji("1f3c2", ":snowboarder:");
  static final UnicodeEmoji white_flower =
      UnicodeEmoji("1f4ae", ":white_flower:");
  static final UnicodeEmoji necktie = UnicodeEmoji("1f454", ":necktie:");
  static final UnicodeEmoji diamond_shape_with_a_dot_inside =
      UnicodeEmoji("1f4a0", ":diamond_shape_with_a_dot_inside:");
  static final UnicodeEmoji aries = UnicodeEmoji("2648", ":aries:");
  static final UnicodeEmoji womens = UnicodeEmoji("1f6ba", ":womens:");
  static final UnicodeEmoji ant = UnicodeEmoji("1f41c", ":ant:");
  static final UnicodeEmoji scorpius = UnicodeEmoji("264f", ":scorpius:");
  static final UnicodeEmoji city_sunset =
      UnicodeEmoji("1f307", ":city_sunset:");
  static final UnicodeEmoji hourglass_flowing_sand =
      UnicodeEmoji("23f3", ":hourglass_flowing_sand:");
  static final UnicodeEmoji o2 = UnicodeEmoji("1f17e", ":o2:");
  static final UnicodeEmoji dragon_face =
      UnicodeEmoji("1f432", ":dragon_face:");
  static final UnicodeEmoji snail = UnicodeEmoji("1f40c", ":snail:");
  static final UnicodeEmoji dvd = UnicodeEmoji("1f4c0", ":dvd:");
  static final UnicodeEmoji shirt = UnicodeEmoji("1f455", ":shirt:");
  static final UnicodeEmoji game_die = UnicodeEmoji("1f3b2", ":game_die:");
  static final UnicodeEmoji heavy_minus_sign =
      UnicodeEmoji("2796", ":heavy_minus_sign:");
  static final UnicodeEmoji dolls = UnicodeEmoji("1f38e", ":dolls:");
  static final UnicodeEmoji sagittarius = UnicodeEmoji("2650", ":sagittarius:");
  static final UnicodeEmoji eightBall = UnicodeEmoji("1f3b1", ":8ball:");
  static final UnicodeEmoji bus = UnicodeEmoji("1f68c", ":bus:");
  static final UnicodeEmoji custard = UnicodeEmoji("1f36e", ":custard:");
  static final UnicodeEmoji crossed_flags =
      UnicodeEmoji("1f38c", ":crossed_flags:");
  static final UnicodeEmoji part_alternation_mark =
      UnicodeEmoji("303d", ":part_alternation_mark:");
  static final UnicodeEmoji camel = UnicodeEmoji("1f42b", ":camel:");
  static final UnicodeEmoji curry = UnicodeEmoji("1f35b", ":curry:");
  static final UnicodeEmoji steam_locomotive =
      UnicodeEmoji("1f682", ":steam_locomotive:");
  static final UnicodeEmoji hospital = UnicodeEmoji("1f3e5", ":hospital:");
  static final UnicodeEmoji large_blue_diamond =
      UnicodeEmoji("1f537", ":large_blue_diamond:");
  static final UnicodeEmoji tanabata_tree =
      UnicodeEmoji("1f38b", ":tanabata_tree:");
  static final UnicodeEmoji bell = UnicodeEmoji("1f514", ":bell:");
  static final UnicodeEmoji leo = UnicodeEmoji("264c", ":leo:");
  static final UnicodeEmoji gemini = UnicodeEmoji("264a", ":gemini:");
  static final UnicodeEmoji pear = UnicodeEmoji("1f350", ":pear:");
  static final UnicodeEmoji large_orange_diamond =
      UnicodeEmoji("1f536", ":large_orange_diamond:");
  static final UnicodeEmoji taurus = UnicodeEmoji("2649", ":taurus:");
  static final UnicodeEmoji globe_with_meridians =
      UnicodeEmoji("1f310", ":globe_with_meridians:");
  static final UnicodeEmoji door = UnicodeEmoji("1f6aa", ":door:");
  static final UnicodeEmoji clock6 = UnicodeEmoji("1f555", ":clock6:");
  static final UnicodeEmoji oncoming_police_car =
      UnicodeEmoji("1f694", ":oncoming_police_car:");
  static final UnicodeEmoji envelope_with_arrow =
      UnicodeEmoji("1f4e9", ":envelope_with_arrow:");
  static final UnicodeEmoji closed_umbrella =
      UnicodeEmoji("1f302", ":closed_umbrella:");
  static final UnicodeEmoji saxophone = UnicodeEmoji("1f3b7", ":saxophone:");
  static final UnicodeEmoji church = UnicodeEmoji("26ea", ":church:");
  static final UnicodeEmoji bicyclist = UnicodeEmoji("1f6b4", ":bicyclist:");
  static final UnicodeEmoji pisces = UnicodeEmoji("2653", ":pisces:");
  static final UnicodeEmoji dango = UnicodeEmoji("1f361", ":dango:");
  static final UnicodeEmoji capricorn = UnicodeEmoji("2651", ":capricorn:");
  static final UnicodeEmoji office = UnicodeEmoji("1f3e2", ":office:");
  static final UnicodeEmoji rowboat = UnicodeEmoji("1f6a3", ":rowboat:");
  static final UnicodeEmoji womans_hat = UnicodeEmoji("1f452", ":womans_hat:");
  static final UnicodeEmoji mans_shoe = UnicodeEmoji("1f45e", ":mans_shoe:");
  static final UnicodeEmoji love_hotel = UnicodeEmoji("1f3e9", ":love_hotel:");
  static final UnicodeEmoji mount_fuji = UnicodeEmoji("1f5fb", ":mount_fuji:");
  static final UnicodeEmoji dromedary_camel =
      UnicodeEmoji("1f42a", ":dromedary_camel:");
  static final UnicodeEmoji handbag = UnicodeEmoji("1f45c", ":handbag:");
  static final UnicodeEmoji hourglass = UnicodeEmoji("231b", ":hourglass:");
  static final UnicodeEmoji negative_squared_cross_mark =
      UnicodeEmoji("274e", ":negative_squared_cross_mark:");
  static final UnicodeEmoji trumpet = UnicodeEmoji("1f3ba", ":trumpet:");
  static final UnicodeEmoji school = UnicodeEmoji("1f3eb", ":school:");
  static final UnicodeEmoji cow2 = UnicodeEmoji("1f404", ":cow2:");
  static final UnicodeEmoji construction_worker =
      UnicodeEmoji("1f477", ":construction_worker:");
  static final UnicodeEmoji toilet = UnicodeEmoji("1f6bd", ":toilet:");
  static final UnicodeEmoji pig2 = UnicodeEmoji("1f416", ":pig2:");
  static final UnicodeEmoji grey_question =
      UnicodeEmoji("2754", ":grey_question:");
  static final UnicodeEmoji beginner = UnicodeEmoji("1f530", ":beginner:");
  static final UnicodeEmoji violin = UnicodeEmoji("1f3bb", ":violin:");
  static final UnicodeEmoji on = UnicodeEmoji("1f51b", ":on:");
  static final UnicodeEmoji credit_card =
      UnicodeEmoji("1f4b3", ":credit_card:");
  static final UnicodeEmoji id = UnicodeEmoji("1f194", ":id:");
  static final UnicodeEmoji secret = UnicodeEmoji("3299", ":secret:");
  static final UnicodeEmoji ferris_wheel =
      UnicodeEmoji("1f3a1", ":ferris_wheel:");
  static final UnicodeEmoji bowling = UnicodeEmoji("1f3b3", ":bowling:");
  static final UnicodeEmoji libra = UnicodeEmoji("264e", ":libra:");
  static final UnicodeEmoji virgo = UnicodeEmoji("264d", ":virgo:");
  static final UnicodeEmoji barber = UnicodeEmoji("1f488", ":barber:");
  static final UnicodeEmoji purse = UnicodeEmoji("1f45b", ":purse:");
  static final UnicodeEmoji roller_coaster =
      UnicodeEmoji("1f3a2", ":roller_coaster:");
  static final UnicodeEmoji rat = UnicodeEmoji("1f400", ":rat:");
  static final UnicodeEmoji date = UnicodeEmoji("1f4c5", ":date:");
  static final UnicodeEmoji rugby_football =
      UnicodeEmoji("1f3c9", ":rugby_football:");
  static final UnicodeEmoji ram = UnicodeEmoji("1f40f", ":ram:");
  static final UnicodeEmoji arrow_up_small =
      UnicodeEmoji("1f53c", ":arrow_up_small:");
  static final UnicodeEmoji black_square_button =
      UnicodeEmoji("1f532", ":black_square_button:");
  static final UnicodeEmoji mobile_phone_off =
      UnicodeEmoji("1f4f4", ":mobile_phone_off:");
  static final UnicodeEmoji tokyo_tower =
      UnicodeEmoji("1f5fc", ":tokyo_tower:");
  static final UnicodeEmoji congratulations =
      UnicodeEmoji("3297", ":congratulations:");
  static final UnicodeEmoji kimono = UnicodeEmoji("1f458", ":kimono:");
  static final UnicodeEmoji ship = UnicodeEmoji("1f6a2", ":ship:");
  static final UnicodeEmoji mag_right = UnicodeEmoji("1f50e", ":mag_right:");
  static final UnicodeEmoji mag = UnicodeEmoji("1f50d", ":mag:");
  static final UnicodeEmoji fire_engine =
      UnicodeEmoji("1f692", ":fire_engine:");
  static final UnicodeEmoji clock1130 = UnicodeEmoji("1f566", ":clock1130:");
  static final UnicodeEmoji police_car = UnicodeEmoji("1f693", ":police_car:");
  static final UnicodeEmoji black_joker =
      UnicodeEmoji("1f0cf", ":black_joker:");
  static final UnicodeEmoji bridge_at_night =
      UnicodeEmoji("1f309", ":bridge_at_night:");
  static final UnicodeEmoji package = UnicodeEmoji("1f4e6", ":package:");
  static final UnicodeEmoji oncoming_taxi =
      UnicodeEmoji("1f696", ":oncoming_taxi:");
  static final UnicodeEmoji calendar = UnicodeEmoji("1f4c6", ":calendar:");
  static final UnicodeEmoji horse_racing =
      UnicodeEmoji("1f3c7", ":horse_racing:");
  static final UnicodeEmoji tiger2 = UnicodeEmoji("1f405", ":tiger2:");
  static final UnicodeEmoji boot = UnicodeEmoji("1f462", ":boot:");
  static final UnicodeEmoji ambulance = UnicodeEmoji("1f691", ":ambulance:");
  static final UnicodeEmoji white_square_button =
      UnicodeEmoji("1f533", ":white_square_button:");
  static final UnicodeEmoji boar = UnicodeEmoji("1f417", ":boar:");
  static final UnicodeEmoji school_satchel =
      UnicodeEmoji("1f392", ":school_satchel:");
  static final UnicodeEmoji loop = UnicodeEmoji("27bf", ":loop:");
  static final UnicodeEmoji pound = UnicodeEmoji("1f4b7", ":pound:");
  static final UnicodeEmoji information_source =
      UnicodeEmoji("2139", ":information_source:");
  static final UnicodeEmoji ox = UnicodeEmoji("1f402", ":ox:");
  static final UnicodeEmoji rice_ball = UnicodeEmoji("1f359", ":rice_ball:");
  static final UnicodeEmoji vs = UnicodeEmoji("1f19a", ":vs:");
  static final UnicodeEmoji end = UnicodeEmoji("1f51a", ":end:");
  static final UnicodeEmoji parking = UnicodeEmoji("1f17f", ":parking:");
  static final UnicodeEmoji sandal = UnicodeEmoji("1f461", ":sandal:");
  static final UnicodeEmoji tent = UnicodeEmoji("26fa", ":tent:");
  static final UnicodeEmoji seat = UnicodeEmoji("1f4ba", ":seat:");
  static final UnicodeEmoji taxi = UnicodeEmoji("1f695", ":taxi:");
  static final UnicodeEmoji black_medium_small_square =
      UnicodeEmoji("25fe", ":black_medium_small_square:");
  static final UnicodeEmoji briefcase = UnicodeEmoji("1f4bc", ":briefcase:");
  static final UnicodeEmoji newspaper = UnicodeEmoji("1f4f0", ":newspaper:");
  static final UnicodeEmoji circus_tent =
      UnicodeEmoji("1f3aa", ":circus_tent:");
  static final UnicodeEmoji six_pointed_star =
      UnicodeEmoji("1f52f", ":six_pointed_star:");
  static final UnicodeEmoji mens = UnicodeEmoji("1f6b9", ":mens:");
  static final UnicodeEmoji european_castle =
      UnicodeEmoji("1f3f0", ":european_castle:");
  static final UnicodeEmoji flashlight = UnicodeEmoji("1f526", ":flashlight:");
  static final UnicodeEmoji foggy = UnicodeEmoji("1f301", ":foggy:");
  static final UnicodeEmoji arrow_double_up =
      UnicodeEmoji("23eb", ":arrow_double_up:");
  static final UnicodeEmoji bamboo = UnicodeEmoji("1f38d", ":bamboo:");
  static final UnicodeEmoji ticket = UnicodeEmoji("1f3ab", ":ticket:");
  static final UnicodeEmoji helicopter = UnicodeEmoji("1f681", ":helicopter:");
  static final UnicodeEmoji minidisc = UnicodeEmoji("1f4bd", ":minidisc:");
  static final UnicodeEmoji oncoming_bus =
      UnicodeEmoji("1f68d", ":oncoming_bus:");
  static final UnicodeEmoji melon = UnicodeEmoji("1f348", ":melon:");
  static final UnicodeEmoji white_small_square =
      UnicodeEmoji("25ab", ":white_small_square:");
  static final UnicodeEmoji european_post_office =
      UnicodeEmoji("1f3e4", ":european_post_office:");
  static final UnicodeEmoji keycap_ten = UnicodeEmoji("1f51f", ":keycap_ten:");
  static final UnicodeEmoji notebook = UnicodeEmoji("1f4d3", ":notebook:");
  static final UnicodeEmoji no_bell = UnicodeEmoji("1f515", ":no_bell:");
  static final UnicodeEmoji oden = UnicodeEmoji("1f362", ":oden:");
  static final UnicodeEmoji flags = UnicodeEmoji("1f38f", ":flags:");
  static final UnicodeEmoji carousel_horse =
      UnicodeEmoji("1f3a0", ":carousel_horse:");
  static final UnicodeEmoji blowfish = UnicodeEmoji("1f421", ":blowfish:");
  static final UnicodeEmoji chart_with_upwards_trend =
      UnicodeEmoji("1f4c8", ":chart_with_upwards_trend:");
  static final UnicodeEmoji sweet_potato =
      UnicodeEmoji("1f360", ":sweet_potato:");
  static final UnicodeEmoji ski = UnicodeEmoji("1f3bf", ":ski:");
  static final UnicodeEmoji clock12 = UnicodeEmoji("1f55b", ":clock12:");
  static final UnicodeEmoji signal_strength =
      UnicodeEmoji("1f4f6", ":signal_strength:");
  static final UnicodeEmoji construction =
      UnicodeEmoji("1f6a7", ":construction:");
  static final UnicodeEmoji black_medium_square =
      UnicodeEmoji("25fc", ":black_medium_square:");
  static final UnicodeEmoji satellite = UnicodeEmoji("1f4e1", ":satellite:");
  static final UnicodeEmoji euro = UnicodeEmoji("1f4b6", ":euro:");
  static final UnicodeEmoji womans_clothes =
      UnicodeEmoji("1f45a", ":womans_clothes:");
  static final UnicodeEmoji ledger = UnicodeEmoji("1f4d2", ":ledger:");
  static final UnicodeEmoji leopard = UnicodeEmoji("1f406", ":leopard:");
  static final UnicodeEmoji low_brightness =
      UnicodeEmoji("1f505", ":low_brightness:");
  static final UnicodeEmoji clock3 = UnicodeEmoji("1f552", ":clock3:");
  static final UnicodeEmoji department_store =
      UnicodeEmoji("1f3ec", ":department_store:");
  static final UnicodeEmoji truck = UnicodeEmoji("1f69a", ":truck:");
  static final UnicodeEmoji sake = UnicodeEmoji("1f376", ":sake:");
  static final UnicodeEmoji railway_car =
      UnicodeEmoji("1f683", ":railway_car:");
  static final UnicodeEmoji speedboat = UnicodeEmoji("1f6a4", ":speedboat:");
  static final UnicodeEmoji vhs = UnicodeEmoji("1f4fc", ":vhs:");
  static final UnicodeEmoji clock1 = UnicodeEmoji("1f550", ":clock1:");
  static final UnicodeEmoji arrow_double_down =
      UnicodeEmoji("23ec", ":arrow_double_down:");
  static final UnicodeEmoji water_buffalo =
      UnicodeEmoji("1f403", ":water_buffalo:");
  static final UnicodeEmoji arrow_down_small =
      UnicodeEmoji("1f53d", ":arrow_down_small:");
  static final UnicodeEmoji yen = UnicodeEmoji("1f4b4", ":yen:");
  static final UnicodeEmoji mute = UnicodeEmoji("1f507", ":mute:");
  static final UnicodeEmoji running_shirt_with_sash =
      UnicodeEmoji("1f3bd", ":running_shirt_with_sash:");
  static final UnicodeEmoji white_large_square =
      UnicodeEmoji("2b1c", ":white_large_square:");
  static final UnicodeEmoji wheelchair = UnicodeEmoji("267f", ":wheelchair:");
  static final UnicodeEmoji clock2 = UnicodeEmoji("1f551", ":clock2:");
  static final UnicodeEmoji paperclip = UnicodeEmoji("1f4ce", ":paperclip:");
  static final UnicodeEmoji atm = UnicodeEmoji("1f3e7", ":atm:");
  static final UnicodeEmoji cinema = UnicodeEmoji("1f3a6", ":cinema:");
  static final UnicodeEmoji telescope = UnicodeEmoji("1f52d", ":telescope:");
  static final UnicodeEmoji rice_scene = UnicodeEmoji("1f391", ":rice_scene:");
  static final UnicodeEmoji blue_book = UnicodeEmoji("1f4d8", ":blue_book:");
  static final UnicodeEmoji white_medium_square =
      UnicodeEmoji("25fb", ":white_medium_square:");
  static final UnicodeEmoji postbox = UnicodeEmoji("1f4ee", ":postbox:");
  static final UnicodeEmoji email = UnicodeEmoji("1f4e7", ":e-mail:");
  static final UnicodeEmoji mouse2 = UnicodeEmoji("1f401", ":mouse2:");
  static final UnicodeEmoji bullettrain_side =
      UnicodeEmoji("1f684", ":bullettrain_side:");
  static final UnicodeEmoji ideograph_advantage =
      UnicodeEmoji("1f250", ":ideograph_advantage:");
  static final UnicodeEmoji nut_and_bolt =
      UnicodeEmoji("1f529", ":nut_and_bolt:");
  static final UnicodeEmoji ng = UnicodeEmoji("1f196", ":ng:");
  static final UnicodeEmoji hotel = UnicodeEmoji("1f3e8", ":hotel:");
  static final UnicodeEmoji wc = UnicodeEmoji("1f6be", ":wc:");
  static final UnicodeEmoji izakaya_lantern =
      UnicodeEmoji("1f3ee", ":izakaya_lantern:");
  static final UnicodeEmoji repeat_one = UnicodeEmoji("1f502", ":repeat_one:");
  static final UnicodeEmoji mailbox_with_mail =
      UnicodeEmoji("1f4ec", ":mailbox_with_mail:");
  static final UnicodeEmoji chart_with_downwards_trend =
      UnicodeEmoji("1f4c9", ":chart_with_downwards_trend:");
  static final UnicodeEmoji green_book = UnicodeEmoji("1f4d7", ":green_book:");
  static final UnicodeEmoji tractor = UnicodeEmoji("1f69c", ":tractor:");
  static final UnicodeEmoji fountain = UnicodeEmoji("26f2", ":fountain:");
  static final UnicodeEmoji metro = UnicodeEmoji("1f687", ":metro:");
  static final UnicodeEmoji clipboard = UnicodeEmoji("1f4cb", ":clipboard:");
  static final UnicodeEmoji no_mobile_phones =
      UnicodeEmoji("1f4f5", ":no_mobile_phones:");
  static final UnicodeEmoji clock4 = UnicodeEmoji("1f553", ":clock4:");
  static final UnicodeEmoji no_smoking = UnicodeEmoji("1f6ad", ":no_smoking:");
  static final UnicodeEmoji black_large_square =
      UnicodeEmoji("2b1b", ":black_large_square:");
  static final UnicodeEmoji slot_machine =
      UnicodeEmoji("1f3b0", ":slot_machine:");
  static final UnicodeEmoji clock5 = UnicodeEmoji("1f554", ":clock5:");
  static final UnicodeEmoji bathtub = UnicodeEmoji("1f6c1", ":bathtub:");
  static final UnicodeEmoji scroll = UnicodeEmoji("1f4dc", ":scroll:");
  static final UnicodeEmoji station = UnicodeEmoji("1f689", ":station:");
  static final UnicodeEmoji rice_cracker =
      UnicodeEmoji("1f358", ":rice_cracker:");
  static final UnicodeEmoji bank = UnicodeEmoji("1f3e6", ":bank:");
  static final UnicodeEmoji wrench = UnicodeEmoji("1f527", ":wrench:");
  static final UnicodeEmoji u6307 = UnicodeEmoji("1f22f", ":u6307:");
  static final UnicodeEmoji articulated_lorry =
      UnicodeEmoji("1f69b", ":articulated_lorry:");
  static final UnicodeEmoji page_facing_up =
      UnicodeEmoji("1f4c4", ":page_facing_up:");
  static final UnicodeEmoji ophiuchus = UnicodeEmoji("26ce", ":ophiuchus:");
  static final UnicodeEmoji bar_chart = UnicodeEmoji("1f4ca", ":bar_chart:");
  static final UnicodeEmoji no_pedestrians =
      UnicodeEmoji("1f6b7", ":no_pedestrians:");
  static final UnicodeEmoji vibration_mode =
      UnicodeEmoji("1f4f3", ":vibration_mode:");
  static final UnicodeEmoji clock10 = UnicodeEmoji("1f559", ":clock10:");
  static final UnicodeEmoji clock9 = UnicodeEmoji("1f558", ":clock9:");
  static final UnicodeEmoji bullettrain_front =
      UnicodeEmoji("1f685", ":bullettrain_front:");
  static final UnicodeEmoji minibus = UnicodeEmoji("1f690", ":minibus:");
  static final UnicodeEmoji tram = UnicodeEmoji("1f68a", ":tram:");
  static final UnicodeEmoji clock8 = UnicodeEmoji("1f557", ":clock8:");
  static final UnicodeEmoji u7a7a = UnicodeEmoji("1f233", ":u7a7a:");
  static final UnicodeEmoji traffic_light =
      UnicodeEmoji("1f6a5", ":traffic_light:");
  static final UnicodeEmoji mountain_bicyclist =
      UnicodeEmoji("1f6b5", ":mountain_bicyclist:");
  static final UnicodeEmoji microscope = UnicodeEmoji("1f52c", ":microscope:");
  static final UnicodeEmoji japanese_castle =
      UnicodeEmoji("1f3ef", ":japanese_castle:");
  static final UnicodeEmoji bookmark = UnicodeEmoji("1f516", ":bookmark:");
  static final UnicodeEmoji bookmark_tabs =
      UnicodeEmoji("1f4d1", ":bookmark_tabs:");
  static final UnicodeEmoji pouch = UnicodeEmoji("1f45d", ":pouch:");
  static final UnicodeEmoji ab = UnicodeEmoji("1f18e", ":ab:");
  static final UnicodeEmoji page_with_curl =
      UnicodeEmoji("1f4c3", ":page_with_curl:");
  static final UnicodeEmoji flower_playing_cards =
      UnicodeEmoji("1f3b4", ":flower_playing_cards:");
  static final UnicodeEmoji clock11 = UnicodeEmoji("1f55a", ":clock11:");
  static final UnicodeEmoji fax = UnicodeEmoji("1f4e0", ":fax:");
  static final UnicodeEmoji clock7 = UnicodeEmoji("1f556", ":clock7:");
  static final UnicodeEmoji white_medium_small_square =
      UnicodeEmoji("25fd", ":white_medium_small_square:");
  static final UnicodeEmoji currency_exchange =
      UnicodeEmoji("1f4b1", ":currency_exchange:");
  static final UnicodeEmoji sound = UnicodeEmoji("1f509", ":sound:");
  static final UnicodeEmoji chart = UnicodeEmoji("1f4b9", ":chart:");
  static final UnicodeEmoji cl = UnicodeEmoji("1f191", ":cl:");
  static final UnicodeEmoji floppy_disk =
      UnicodeEmoji("1f4be", ":floppy_disk:");
  static final UnicodeEmoji post_office =
      UnicodeEmoji("1f3e3", ":post_office:");
  static final UnicodeEmoji speaker = UnicodeEmoji("1f508", ":speaker:");
  static final UnicodeEmoji japan = UnicodeEmoji("1f5fe", ":japan:");
  static final UnicodeEmoji u55b6 = UnicodeEmoji("1f23a", ":u55b6:");
  static final UnicodeEmoji mahjong = UnicodeEmoji("1f004", ":mahjong:");
  static final UnicodeEmoji incoming_envelope =
      UnicodeEmoji("1f4e8", ":incoming_envelope:");
  static final UnicodeEmoji orange_book =
      UnicodeEmoji("1f4d9", ":orange_book:");
  static final UnicodeEmoji restroom = UnicodeEmoji("1f6bb", ":restroom:");
  static final UnicodeEmoji u7121 = UnicodeEmoji("1f21a", ":u7121:");
  static final UnicodeEmoji u6709 = UnicodeEmoji("1f236", ":u6709:");
  static final UnicodeEmoji triangular_ruler =
      UnicodeEmoji("1f4d0", ":triangular_ruler:");
  static final UnicodeEmoji train = UnicodeEmoji("1f68b", ":train:");
  static final UnicodeEmoji u7533 = UnicodeEmoji("1f238", ":u7533:");
  static final UnicodeEmoji trolleybus = UnicodeEmoji("1f68e", ":trolleybus:");
  static final UnicodeEmoji u6708 = UnicodeEmoji("1f237", ":u6708:");
  static final UnicodeEmoji notebook_with_decorative_cover =
      UnicodeEmoji("1f4d4", ":notebook_with_decorative_cover:");
  static final UnicodeEmoji u7981 = UnicodeEmoji("1f232", ":u7981:");
  static final UnicodeEmoji u6e80 = UnicodeEmoji("1f235", ":u6e80:");
  static final UnicodeEmoji postal_horn =
      UnicodeEmoji("1f4ef", ":postal_horn:");
  static final UnicodeEmoji factory = UnicodeEmoji("1f3ed", ":factory:");
  static final UnicodeEmoji children_crossing =
      UnicodeEmoji("1f6b8", ":children_crossing:");
  static final UnicodeEmoji train2 = UnicodeEmoji("1f686", ":train2:");
  static final UnicodeEmoji straight_ruler =
      UnicodeEmoji("1f4cf", ":straight_ruler:");
  static final UnicodeEmoji pager = UnicodeEmoji("1f4df", ":pager:");
  static final UnicodeEmoji accept = UnicodeEmoji("1f251", ":accept:");
  static final UnicodeEmoji u5408 = UnicodeEmoji("1f234", ":u5408:");
  static final UnicodeEmoji lock_with_ink_pen =
      UnicodeEmoji("1f50f", ":lock_with_ink_pen:");
  static final UnicodeEmoji clock130 = UnicodeEmoji("1f55c", ":clock130:");
  static final UnicodeEmoji sa = UnicodeEmoji("1f202", ":sa:");
  static final UnicodeEmoji outbox_tray =
      UnicodeEmoji("1f4e4", ":outbox_tray:");
  static final UnicodeEmoji twisted_rightwards_arrows =
      UnicodeEmoji("1f500", ":twisted_rightwards_arrows:");
  static final UnicodeEmoji mailbox = UnicodeEmoji("1f4eb", ":mailbox:");
  static final UnicodeEmoji light_rail = UnicodeEmoji("1f688", ":light_rail:");
  static final UnicodeEmoji clock930 = UnicodeEmoji("1f564", ":clock930:");
  static final UnicodeEmoji busstop = UnicodeEmoji("1f68f", ":busstop:");
  static final UnicodeEmoji open_file_folder =
      UnicodeEmoji("1f4c2", ":open_file_folder:");
  static final UnicodeEmoji file_folder =
      UnicodeEmoji("1f4c1", ":file_folder:");
  static final UnicodeEmoji potable_water =
      UnicodeEmoji("1f6b0", ":potable_water:");
  static final UnicodeEmoji card_index = UnicodeEmoji("1f4c7", ":card_index:");
  static final UnicodeEmoji clock230 = UnicodeEmoji("1f55d", ":clock230:");
  static final UnicodeEmoji monorail = UnicodeEmoji("1f69d", ":monorail:");
  static final UnicodeEmoji clock1230 = UnicodeEmoji("1f567", ":clock1230:");
  static final UnicodeEmoji clock1030 = UnicodeEmoji("1f565", ":clock1030:");
  static final UnicodeEmoji abc = UnicodeEmoji("1f524", ":abc:");
  static final UnicodeEmoji mailbox_closed =
      UnicodeEmoji("1f4ea", ":mailbox_closed:");
  static final UnicodeEmoji clock430 = UnicodeEmoji("1f55f", ":clock430:");
  static final UnicodeEmoji mountain_railway =
      UnicodeEmoji("1f69e", ":mountain_railway:");
  static final UnicodeEmoji do_not_litter =
      UnicodeEmoji("1f6af", ":do_not_litter:");
  static final UnicodeEmoji clock330 = UnicodeEmoji("1f55e", ":clock330:");
  static final UnicodeEmoji heavy_division_sign =
      UnicodeEmoji("2797", ":heavy_division_sign:");
  static final UnicodeEmoji clock730 = UnicodeEmoji("1f562", ":clock730:");
  static final UnicodeEmoji clock530 = UnicodeEmoji("1f560", ":clock530:");
  static final UnicodeEmoji capital_abcd =
      UnicodeEmoji("1f520", ":capital_abcd:");
  static final UnicodeEmoji mailbox_with_no_mail =
      UnicodeEmoji("1f4ed", ":mailbox_with_no_mail:");
  static final UnicodeEmoji symbols = UnicodeEmoji("1f523", ":symbols:");
  static final UnicodeEmoji aerial_tramway =
      UnicodeEmoji("1f6a1", ":aerial_tramway:");
  static final UnicodeEmoji clock830 = UnicodeEmoji("1f563", ":clock830:");
  static final UnicodeEmoji clock630 = UnicodeEmoji("1f561", ":clock630:");
  static final UnicodeEmoji abcd = UnicodeEmoji("1f521", ":abcd:");
  static final UnicodeEmoji mountain_cableway =
      UnicodeEmoji("1f6a0", ":mountain_cableway:");
  static final UnicodeEmoji koko = UnicodeEmoji("1f201", ":koko:");
  static final UnicodeEmoji passport_control =
      UnicodeEmoji("1f6c2", ":passport_control:");
  static final UnicodeEmoji nonPotableWater =
      UnicodeEmoji("1f6b1", ":non-potable_water:");
  static final UnicodeEmoji suspension_railway =
      UnicodeEmoji("1f69f", ":suspension_railway:");
  static final UnicodeEmoji baggage_claim =
      UnicodeEmoji("1f6c4", ":baggage_claim:");
  static final UnicodeEmoji no_bicycles =
      UnicodeEmoji("1f6b3", ":no_bicycles:");
  static final UnicodeEmoji skull_and_crossbones =
      UnicodeEmoji("2620", ":skull_crossbones:");
  static final UnicodeEmoji hugging_face = UnicodeEmoji("1f917", ":hugging:");
  static final UnicodeEmoji thinking_face = UnicodeEmoji("1f914", ":thinking:");
  static final UnicodeEmoji nerd_face = UnicodeEmoji("1f913", ":nerd:");
  static final UnicodeEmoji zipper_mouth_face =
      UnicodeEmoji("1f910", ":zipper_mouth:");
  static final UnicodeEmoji face_with_rolling_eyes =
      UnicodeEmoji("1f644", ":rolling_eyes:");
  static final UnicodeEmoji upside_down_face =
      UnicodeEmoji("1f643", ":upside_down:");
  static final UnicodeEmoji slightly_smiling_face =
      UnicodeEmoji("1f642", ":slight_smile:");
  static final UnicodeEmoji middle_finger =
      UnicodeEmoji("1f595", ":middle_finger:");
  static final UnicodeEmoji writing_hand =
      UnicodeEmoji("270d", ":writing_hand:");
  static final UnicodeEmoji dark_sunglasses =
      UnicodeEmoji("1f576", ":dark_sunglasses:");
  static final UnicodeEmoji eye = UnicodeEmoji("1f441", ":eye:");
  static final UnicodeEmoji golfer = UnicodeEmoji("1f3cc", ":golfer:");
  static final UnicodeEmoji heart_exclamation =
      UnicodeEmoji("2763", ":heart_exclamation:");
  static final UnicodeEmoji star_of_david =
      UnicodeEmoji("2721", ":star_of_david:");
  static final UnicodeEmoji cross = UnicodeEmoji("271d", ":cross:");
  static final UnicodeEmoji fleurDeLis = UnicodeEmoji("269c", ":fleur-de-lis:");
  static final UnicodeEmoji atom = UnicodeEmoji("269b", ":atom:");
  static final UnicodeEmoji wheel_of_dharma =
      UnicodeEmoji("2638", ":wheel_of_dharma:");
  static final UnicodeEmoji yin_yang = UnicodeEmoji("262f", ":yin_yang:");
  static final UnicodeEmoji peace = UnicodeEmoji("262e", ":peace:");
  static final UnicodeEmoji star_and_crescent =
      UnicodeEmoji("262a", ":star_and_crescent:");
  static final UnicodeEmoji orthodox_cross =
      UnicodeEmoji("2626", ":orthodox_cross:");
  static final UnicodeEmoji biohazard = UnicodeEmoji("2623", ":biohazard:");
  static final UnicodeEmoji radioactive = UnicodeEmoji("2622", ":radioactive:");
  static final UnicodeEmoji place_of_worship =
      UnicodeEmoji("1f6d0", ":place_of_worship:");
  static final UnicodeEmoji anger_right =
      UnicodeEmoji("1f5ef", ":anger_right:");
  static final UnicodeEmoji menorah = UnicodeEmoji("1f54e", ":menorah:");
  static final UnicodeEmoji om_symbol = UnicodeEmoji("1f549", ":om_symbol:");
  static final UnicodeEmoji coffin = UnicodeEmoji("26b0", ":coffin:");
  static final UnicodeEmoji gear = UnicodeEmoji("2699", ":gear:");
  static final UnicodeEmoji alembic = UnicodeEmoji("2697", ":alembic:");
  static final UnicodeEmoji scales = UnicodeEmoji("2696", ":scales:");
  static final UnicodeEmoji crossed_swords =
      UnicodeEmoji("2694", ":crossed_swords:");
  static final UnicodeEmoji keyboard = UnicodeEmoji("2328", ":keyboard:");
  static final UnicodeEmoji shield = UnicodeEmoji("1f6e1", ":shield:");
  static final UnicodeEmoji bed = UnicodeEmoji("1f6cf", ":bed:");
  static final UnicodeEmoji shopping_bags =
      UnicodeEmoji("1f6cd", ":shopping_bags:");
  static final UnicodeEmoji sleeping_accommodation =
      UnicodeEmoji("1f6cc", ":sleeping_accommodation:");
  static final UnicodeEmoji ballot_box = UnicodeEmoji("1f5f3", ":ballot_box:");
  static final UnicodeEmoji compression =
      UnicodeEmoji("1f5dc", ":compression:");
  static final UnicodeEmoji wastebasket =
      UnicodeEmoji("1f5d1", ":wastebasket:");
  static final UnicodeEmoji file_cabinet =
      UnicodeEmoji("1f5c4", ":file_cabinet:");
  static final UnicodeEmoji trackball = UnicodeEmoji("1f5b2", ":trackball:");
  static final UnicodeEmoji printer = UnicodeEmoji("1f5a8", ":printer:");
  static final UnicodeEmoji joystick = UnicodeEmoji("1f579", ":joystick:");
  static final UnicodeEmoji hole = UnicodeEmoji("1f573", ":hole:");
  static final UnicodeEmoji candle = UnicodeEmoji("1f56f", ":candle:");
  static final UnicodeEmoji prayer_beads =
      UnicodeEmoji("1f4ff", ":prayer_beads:");
  static final UnicodeEmoji camera_with_flash =
      UnicodeEmoji("1f4f8", ":camera_with_flash:");
  static final UnicodeEmoji amphora = UnicodeEmoji("1f3fa", ":amphora:");
  static final UnicodeEmoji label = UnicodeEmoji("1f3f7", ":label:");
  static final UnicodeEmoji waving_black_flag =
      UnicodeEmoji("1f3f4", ":flag_black:");
  static final UnicodeEmoji waving_white_flag =
      UnicodeEmoji("1f3f3", ":flag_white:");
  static final UnicodeEmoji film_frames =
      UnicodeEmoji("1f39e", ":film_frames:");
  static final UnicodeEmoji control_knobs =
      UnicodeEmoji("1f39b", ":control_knobs:");
  static final UnicodeEmoji level_slider =
      UnicodeEmoji("1f39a", ":level_slider:");
  static final UnicodeEmoji thermometer =
      UnicodeEmoji("1f321", ":thermometer:");
  static final UnicodeEmoji airplane_arriving =
      UnicodeEmoji("1f6ec", ":airplane_arriving:");
  static final UnicodeEmoji airplane_departure =
      UnicodeEmoji("1f6eb", ":airplane_departure:");
  static final UnicodeEmoji railway_track =
      UnicodeEmoji("1f6e4", ":railway_track:");
  static final UnicodeEmoji motorway = UnicodeEmoji("1f6e3", ":motorway:");
  static final UnicodeEmoji synagogue = UnicodeEmoji("1f54d", ":synagogue:");
  static final UnicodeEmoji mosque = UnicodeEmoji("1f54c", ":mosque:");
  static final UnicodeEmoji kaaba = UnicodeEmoji("1f54b", ":kaaba:");
  static final UnicodeEmoji stadium = UnicodeEmoji("1f3df", ":stadium:");
  static final UnicodeEmoji desert = UnicodeEmoji("1f3dc", ":desert:");
  static final UnicodeEmoji classical_building =
      UnicodeEmoji("1f3db", ":classical_building:");
  static final UnicodeEmoji cityscape = UnicodeEmoji("1f3d9", ":cityscape:");
  static final UnicodeEmoji camping = UnicodeEmoji("1f3d5", ":camping:");
  static final UnicodeEmoji bow_and_arrow =
      UnicodeEmoji("1f3f9", ":bow_and_arrow:");
  static final UnicodeEmoji rosette = UnicodeEmoji("1f3f5", ":rosette:");
  static final UnicodeEmoji volleyball = UnicodeEmoji("1f3d0", ":volleyball:");
  static final UnicodeEmoji medal = UnicodeEmoji("1f3c5", ":medal:");
  static final UnicodeEmoji reminder_ribbon =
      UnicodeEmoji("1f397", ":reminder_ribbon:");
  static final UnicodeEmoji popcorn = UnicodeEmoji("1f37f", ":popcorn:");
  static final UnicodeEmoji champagne = UnicodeEmoji("1f37e", ":champagne:");
  static final UnicodeEmoji hot_pepper = UnicodeEmoji("1f336", ":hot_pepper:");
  static final UnicodeEmoji burrito = UnicodeEmoji("1f32f", ":burrito:");
  static final UnicodeEmoji taco = UnicodeEmoji("1f32e", ":taco:");
  static final UnicodeEmoji hotdog = UnicodeEmoji("1f32d", ":hotdog:");
  static final UnicodeEmoji shamrock = UnicodeEmoji("2618", ":shamrock:");
  static final UnicodeEmoji comet = UnicodeEmoji("2604", ":comet:");
  static final UnicodeEmoji turkey = UnicodeEmoji("1f983", ":turkey:");
  static final UnicodeEmoji scorpion = UnicodeEmoji("1f982", ":scorpion:");
  static final UnicodeEmoji lion_face = UnicodeEmoji("1f981", ":lion_face:");
  static final UnicodeEmoji crab = UnicodeEmoji("1f980", ":crab:");
  static final UnicodeEmoji spider_web = UnicodeEmoji("1f578", ":spider_web:");
  static final UnicodeEmoji spider = UnicodeEmoji("1f577", ":spider:");
  static final UnicodeEmoji chipmunk = UnicodeEmoji("1f43f", ":chipmunk:");
  static final UnicodeEmoji wind_blowing_face =
      UnicodeEmoji("1f32c", ":wind_blowing_face:");
  static final UnicodeEmoji fog = UnicodeEmoji("1f32b", ":fog:");
  static final UnicodeEmoji play_pause = UnicodeEmoji("23ef", ":play_pause:");
  static final UnicodeEmoji track_previous =
      UnicodeEmoji("23ee", ":track_previous:");
  static final UnicodeEmoji track_next = UnicodeEmoji("23ed", ":track_next:");
  static final UnicodeEmoji beach_umbrella =
      UnicodeEmoji("26f1", ":beach_umbrella:");
  static final UnicodeEmoji chains = UnicodeEmoji("26d3", ":chains:");
  static final UnicodeEmoji pick = UnicodeEmoji("26cf", ":pick:");
  static final UnicodeEmoji stopwatch = UnicodeEmoji("23f1", ":stopwatch:");
  static final UnicodeEmoji ferry = UnicodeEmoji("26f4", ":ferry:");
  static final UnicodeEmoji mountain = UnicodeEmoji("26f0", ":mountain:");
  static final UnicodeEmoji shinto_shrine =
      UnicodeEmoji("2.6E+10", ":shinto_shrine:");
  static final UnicodeEmoji ice_skate = UnicodeEmoji("26f8", ":ice_skate:");
  static final UnicodeEmoji skier = UnicodeEmoji("26f7", ":skier:");
  static final UnicodeEmoji black_heart =
      UnicodeEmoji("1f5a4", ":black_heart:");
  static final UnicodeEmoji speech_left =
      UnicodeEmoji("1f5e8", ":speech_left:");
  static final UnicodeEmoji egg = UnicodeEmoji("1f95a", ":egg:");
  static final UnicodeEmoji octagonal_sign =
      UnicodeEmoji("1f6d1", ":octagonal_sign:");
  static final UnicodeEmoji spades = UnicodeEmoji("2660", ":spades:");
  static final UnicodeEmoji hearts = UnicodeEmoji("2665", ":hearts:");
  static final UnicodeEmoji diamonds = UnicodeEmoji("2666", ":diamonds:");
  static final UnicodeEmoji clubs = UnicodeEmoji("2663", ":clubs:");
  static final UnicodeEmoji drum = UnicodeEmoji("1f941", ":drum:");
  static final UnicodeEmoji left_right_arrow =
      UnicodeEmoji("2194", ":left_right_arrow:");
  static final UnicodeEmoji copyright = UnicodeEmoji("00a9", ":copyright:");
  static final UnicodeEmoji registered = UnicodeEmoji("00ae", ":registered:");
  static final UnicodeEmoji tm = UnicodeEmoji("2122", ":tm:");
}
