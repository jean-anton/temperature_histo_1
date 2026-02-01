'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "2cd5d18753a6aebd4707133fe6ab135f",
"version.json": "ecdf215c2c8254c024d3b10eefead19f",
"index.html": "0a6c9a499327c11d3000a2b362040176",
"/": "0a6c9a499327c11d3000a2b362040176",
"main.dart.js": "64cd4694c1cf9c5935eb20c56792b2c0",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "39cefc6fe4af3c508365d8670947372d",
"main.dart.mjs": "a469df4c583d19706cc747c2dd4b7f9d",
"icons/Icon-192.png": "39cefc6fe4af3c508365d8670947372d",
"icons/Icon-maskable-192.png": "a15cb5fe5d824f9adc2e33b7c70e6550",
"icons/Icon-maskable-512.png": "49d869b9b4b6e099a9509416db96c25b",
"icons/Icon-512.png": "39cefc6fe4af3c508365d8670947372d",
"coi-serviceworker.js": "12cf3e8ef3deac5151098b970f08e763",
"manifest.json": "8a0cca5366bf447f036e22977c708970",
"main.dart.wasm": "e02f33811b8d6fb517fad0e4e640b4ae",
"assets/USER_MANUAL_FR.md": "9e2502c6b2cd86b3c7a392b1e72c5b25",
"assets/NOTICES": "519e040263cfee683985c31b70d02581",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "7ad87b30ec66ac8e7254fb48641fe258",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "9eee58269758413d627aff16ca0b7d65",
"assets/fonts/MaterialIcons-Regular.otf": "065d1f39bc414004b2e2e88778c51e31",
"assets/assets/images/logo.png": "39cefc6fe4af3c508365d8670947372d",
"assets/assets/google_weather_icons/v4.a_revoir/snow_with_cloudy_light.svg": "a0584597bf9025c2374b102ad347f51e",
"assets/assets/google_weather_icons/v4.a_revoir/icy.svg": "1ecc9dc29e309324c51c4ef3a77dbaa2",
"assets/assets/google_weather_icons/v4.a_revoir/moderate_rain_showers.svg": "1482d5702338626044c7e1e5943cbe7e",
"assets/assets/google_weather_icons/v4.a_revoir/tropical_storm_hurricane.svg": "fd2be5dac09e0b9d517fc910fca35482",
"assets/assets/google_weather_icons/v4.a_revoir/windy.svg": "f19b7c1f0796762b5a163db7602cbd00",
"assets/assets/google_weather_icons/v4.a_revoir/isolated_scattered_thunderstorms_day.svg": "2f726b853c3f03c6181df2521441bb7e",
"assets/assets/google_weather_icons/v4.a_revoir/slight_snow.svg": "bacea524081014f81b8c29634254a731",
"assets/assets/google_weather_icons/v4.a_revoir/scattered_snow_showers_night.svg": "d4e06bcbab652c6e06befc3a2584811a",
"assets/assets/google_weather_icons/v4.a_revoir/rain_with_cloudy_light.svg": "fdbc92563ebcd34af52bfefcc5b6aa73",
"assets/assets/google_weather_icons/v4.a_revoir/sunny_with_cloudy_light.svg": "4d99d1aac3ac5edbfa3543658f7df4ab",
"assets/assets/google_weather_icons/v4.a_revoir/umbrella.svg": "5d4e1ffa0e37a41962c1275f86f88146",
"assets/assets/google_weather_icons/v4.a_revoir/rain_with_sunny_light.svg": "6add86a99189ddb079b82a1022613ccd",
"assets/assets/google_weather_icons/v4.a_revoir/showers_snow.svg": "fee84f5cb9756564496adc631c0288d4",
"assets/assets/google_weather_icons/v4.a_revoir/very_hot.svg": "fb2ba8a687ab38002bd10dc7a8a422a6",
"assets/assets/google_weather_icons/v4.a_revoir/snow_with_sunny_light.svg": "93eba3eb6e080982c1d5d0a1e717c5ab",
"assets/assets/google_weather_icons/v4.a_revoir/clear_night.svg": "79798b14acb0fbea94595ba9c1e107ef",
"assets/assets/google_weather_icons/v4.a_revoir/mostly_cloudy_night.svg": "1f8a9d91a5e490ee4e80a6d6fa3b6ce1",
"assets/assets/google_weather_icons/v4.a_revoir/partly_cloudy_night.svg": "0ddee7598f6fb7962c0e3aec1e9d8173",
"assets/assets/google_weather_icons/v4.a_revoir/cloudy_with_rain_light.svg": "6d50a72a6c0ca5ab1b505c7334d7b861",
"assets/assets/google_weather_icons/v4.a_revoir/snow_with_rain_light.svg": "db5e29aea340ca2c3f792081b0d38b0a",
"assets/assets/google_weather_icons/v4.a_revoir/tornado.svg": "8cb61c28d22b47be1c0778d751011c48",
"assets/assets/google_weather_icons/v4.a_revoir/mixed_rain_snow.svg": "ab01723377d0c1cfae0fb95850d24d60",
"assets/assets/google_weather_icons/v4.a_revoir/mostly_cloudy_day.svg": "dc70e8ede02a7e4171fc37479b9f0a87",
"assets/assets/google_weather_icons/v4.a_revoir/heavy_snow.svg": "b1f6d071867b6ba5f9e8baba0d3d56ec",
"assets/assets/google_weather_icons/v4.a_revoir/scattered_snow_showers_day.svg": "5f45aff1d4fb2b5820eb6358da453c02",
"assets/assets/google_weather_icons/v4.a_revoir/scattered_showers_day.svg": "f2ef7e8140c2435201b6bf6cce90ec64",
"assets/assets/google_weather_icons/v4.a_revoir/slight_rain_showers.svg": "b48a7099cbffd2e6953b508e75667280",
"assets/assets/google_weather_icons/v4.a_revoir/partly_cloudy_day.svg": "acf44dccf19df70441a8a60df5e34050",
"assets/assets/google_weather_icons/v4.a_revoir/cloudy_with_sunny_light.svg": "01c15a673b0537c81ec132a97e21624c",
"assets/assets/google_weather_icons/v4.a_revoir/sunny_with_rain_light.svg": "8379c5b5323e463c84e17d00f476c07b",
"assets/assets/google_weather_icons/v4.a_revoir/mostly_clear_night.svg": "7dd2e0010ec3cfe7229dcd8dd2954cc0",
"assets/assets/google_weather_icons/v4.a_revoir/mostly_clear_day.svg": "266d0ff7afd1683293809aac2d737f37",
"assets/assets/google_weather_icons/v4.a_revoir/mixed_rain_hail_sleet.svg": "00fcc178e42cf45a776413c5ef0eaf93",
"assets/assets/google_weather_icons/v4.a_revoir/sleet_hail.svg": "ca11de070e20d84d86bd4d45cbee9bbf",
"assets/assets/google_weather_icons/v4.a_revoir/moderate_drizzle.svg": "84e6d80a4824ef7c0d7df5013b221d88",
"assets/assets/google_weather_icons/v4.a_revoir/showers_rain.svg": "a2febf601016afaa23056eb97505caf1",
"assets/assets/google_weather_icons/v4.a_revoir/drizzle.svg": "a906ea648e6fc6f6207984dc79e70d44",
"assets/assets/google_weather_icons/v4.a_revoir/sunny_with_snow_light.svg": "5d0e93617f2ffb764e9355cc7037b6f1",
"assets/assets/google_weather_icons/v4.a_revoir/flurries.svg": "bacea524081014f81b8c29634254a731",
"assets/assets/google_weather_icons/v4.a_revoir/very_cold.svg": "d0c9850ae8342485666902cb892eebc4",
"assets/assets/google_weather_icons/v4.a_revoir/isolated_scattered_thunderstorms_night.svg": "6dcd9949f8253987f881aaa9199e09d1",
"assets/assets/google_weather_icons/v4.a_revoir/isolated_thunderstorms.svg": "255d629e772716bbc8b3fc7a6aa20a21",
"assets/assets/google_weather_icons/v4.a_revoir/slight_rain.svg": "a906ea648e6fc6f6207984dc79e70d44",
"assets/assets/google_weather_icons/v4.a_revoir/blowing_snow.svg": "595ee77f77d9e4d4dd8710379ed435d2",
"assets/assets/google_weather_icons/v4.a_revoir/heavy_rain.svg": "3d06fb2222eec018e3184373857dbc2c",
"assets/assets/google_weather_icons/v4.a_revoir/scattered_showers_night.svg": "5484d3b903f95cffbe6c9fc29ae3e75c",
"assets/assets/google_weather_icons/v4.a_revoir/strong_thunderstorms.svg": "d336b05073939b66e3e66bcba725a28e",
"assets/assets/google_weather_icons/v4.a_revoir/cloudy_with_snow_light.svg": "db698a8ac559e4f24df28b216b3b89e1",
"assets/assets/google_weather_icons/v4.a_revoir/blizzard.svg": "3a5779e27bfda0ccf75067bea3e15b47",
"assets/assets/google_weather_icons/v4.a_revoir/light_drizzle.svg": "f73b6a82f5bd45dd9dadcd5151c42fc2",
"assets/assets/google_weather_icons/v4.a_revoir/dense_drizzle.svg": "8cd2867ef39999f888f15d3b394a3d7b",
"assets/assets/google_weather_icons/v4.a_revoir/rain_with_snow_light.svg": "aa0e557c855efc206b525a9ea4293d0c",
"assets/assets/google_weather_icons/v4.a_revoir/cloudy.svg": "d90284e2092644cf6ec39a57b3ce5bc7",
"assets/assets/google_weather_icons/v4.a_revoir/clear_day.svg": "b8c67eddc94a8736975c0c969b383c86",
"assets/assets/google_weather_icons/v4.a_revoir/haze_fog_dust_smoke.svg": "2ae216c574222d5906105b8970109430",
"assets/assets/google_weather_icons/v4.a_revoir/violent_rain_showers.svg": "b72b1f1bfd2a4d9f987766091417ef0d",
"assets/assets/google_weather_icons/v4/snow_with_cloudy_light.svg": "a0584597bf9025c2374b102ad347f51e",
"assets/assets/google_weather_icons/v4/icy.svg": "1ecc9dc29e309324c51c4ef3a77dbaa2",
"assets/assets/google_weather_icons/v4/moderate_rain_showers.svg": "1482d5702338626044c7e1e5943cbe7e",
"assets/assets/google_weather_icons/v4/tropical_storm_hurricane.svg": "fd2be5dac09e0b9d517fc910fca35482",
"assets/assets/google_weather_icons/v4/windy.svg": "f19b7c1f0796762b5a163db7602cbd00",
"assets/assets/google_weather_icons/v4/isolated_scattered_thunderstorms_day.svg": "2f726b853c3f03c6181df2521441bb7e",
"assets/assets/google_weather_icons/v4/slight_snow.svg": "bacea524081014f81b8c29634254a731",
"assets/assets/google_weather_icons/v4/scattered_snow_showers_night.svg": "d4e06bcbab652c6e06befc3a2584811a",
"assets/assets/google_weather_icons/v4/rain_with_cloudy_light.svg": "fdbc92563ebcd34af52bfefcc5b6aa73",
"assets/assets/google_weather_icons/v4/sunny_with_cloudy_light.svg": "4d99d1aac3ac5edbfa3543658f7df4ab",
"assets/assets/google_weather_icons/v4/umbrella.svg": "5d4e1ffa0e37a41962c1275f86f88146",
"assets/assets/google_weather_icons/v4/rain_with_sunny_light.svg": "6add86a99189ddb079b82a1022613ccd",
"assets/assets/google_weather_icons/v4/showers_snow.svg": "fee84f5cb9756564496adc631c0288d4",
"assets/assets/google_weather_icons/v4/very_hot.svg": "fb2ba8a687ab38002bd10dc7a8a422a6",
"assets/assets/google_weather_icons/v4/snow_with_sunny_light.svg": "93eba3eb6e080982c1d5d0a1e717c5ab",
"assets/assets/google_weather_icons/v4/clear_night.svg": "79798b14acb0fbea94595ba9c1e107ef",
"assets/assets/google_weather_icons/v4/mostly_cloudy_night.svg": "1f8a9d91a5e490ee4e80a6d6fa3b6ce1",
"assets/assets/google_weather_icons/v4/partly_cloudy_night.svg": "0ddee7598f6fb7962c0e3aec1e9d8173",
"assets/assets/google_weather_icons/v4/cloudy_with_rain_light.svg": "6d50a72a6c0ca5ab1b505c7334d7b861",
"assets/assets/google_weather_icons/v4/snow_with_rain_light.svg": "db5e29aea340ca2c3f792081b0d38b0a",
"assets/assets/google_weather_icons/v4/tornado.svg": "8cb61c28d22b47be1c0778d751011c48",
"assets/assets/google_weather_icons/v4/mixed_rain_snow.svg": "ab01723377d0c1cfae0fb95850d24d60",
"assets/assets/google_weather_icons/v4/mostly_cloudy_day.svg": "dc70e8ede02a7e4171fc37479b9f0a87",
"assets/assets/google_weather_icons/v4/heavy_snow.svg": "b1f6d071867b6ba5f9e8baba0d3d56ec",
"assets/assets/google_weather_icons/v4/scattered_snow_showers_day.svg": "5f45aff1d4fb2b5820eb6358da453c02",
"assets/assets/google_weather_icons/v4/scattered_showers_day.svg": "f2ef7e8140c2435201b6bf6cce90ec64",
"assets/assets/google_weather_icons/v4/slight_rain_showers.svg": "b48a7099cbffd2e6953b508e75667280",
"assets/assets/google_weather_icons/v4/partly_cloudy_day.svg": "acf44dccf19df70441a8a60df5e34050",
"assets/assets/google_weather_icons/v4/cloudy_with_sunny_light.svg": "01c15a673b0537c81ec132a97e21624c",
"assets/assets/google_weather_icons/v4/sunny_with_rain_light.svg": "8379c5b5323e463c84e17d00f476c07b",
"assets/assets/google_weather_icons/v4/mostly_clear_night.svg": "7dd2e0010ec3cfe7229dcd8dd2954cc0",
"assets/assets/google_weather_icons/v4/mostly_clear_day.svg": "266d0ff7afd1683293809aac2d737f37",
"assets/assets/google_weather_icons/v4/mixed_rain_hail_sleet.svg": "00fcc178e42cf45a776413c5ef0eaf93",
"assets/assets/google_weather_icons/v4/sleet_hail.svg": "ca11de070e20d84d86bd4d45cbee9bbf",
"assets/assets/google_weather_icons/v4/moderate_drizzle.svg": "cd332cffe2d78f6c6ef38462d13f1d6a",
"assets/assets/google_weather_icons/v4/showers_rain.svg": "a2febf601016afaa23056eb97505caf1",
"assets/assets/google_weather_icons/v4/drizzle.svg": "a906ea648e6fc6f6207984dc79e70d44",
"assets/assets/google_weather_icons/v4/sunny_with_snow_light.svg": "5d0e93617f2ffb764e9355cc7037b6f1",
"assets/assets/google_weather_icons/v4/flurries.svg": "bacea524081014f81b8c29634254a731",
"assets/assets/google_weather_icons/v4/very_cold.svg": "d0c9850ae8342485666902cb892eebc4",
"assets/assets/google_weather_icons/v4/isolated_scattered_thunderstorms_night.svg": "6dcd9949f8253987f881aaa9199e09d1",
"assets/assets/google_weather_icons/v4/isolated_thunderstorms.svg": "255d629e772716bbc8b3fc7a6aa20a21",
"assets/assets/google_weather_icons/v4/slight_rain.svg": "a906ea648e6fc6f6207984dc79e70d44",
"assets/assets/google_weather_icons/v4/blowing_snow.svg": "595ee77f77d9e4d4dd8710379ed435d2",
"assets/assets/google_weather_icons/v4/heavy_rain.svg": "3d06fb2222eec018e3184373857dbc2c",
"assets/assets/google_weather_icons/v4/scattered_showers_night.svg": "5484d3b903f95cffbe6c9fc29ae3e75c",
"assets/assets/google_weather_icons/v4/strong_thunderstorms.svg": "d336b05073939b66e3e66bcba725a28e",
"assets/assets/google_weather_icons/v4/cloudy_with_snow_light.svg": "db698a8ac559e4f24df28b216b3b89e1",
"assets/assets/google_weather_icons/v4/blizzard.svg": "3a5779e27bfda0ccf75067bea3e15b47",
"assets/assets/google_weather_icons/v4/light_drizzle.svg": "83a2046871972bc642950302242fe1e5",
"assets/assets/google_weather_icons/v4/dense_drizzle.svg": "1addd1f23cae328d411cffe6d5c74ad4",
"assets/assets/google_weather_icons/v4/rain_with_snow_light.svg": "aa0e557c855efc206b525a9ea4293d0c",
"assets/assets/google_weather_icons/v4/cloudy.svg": "d90284e2092644cf6ec39a57b3ce5bc7",
"assets/assets/google_weather_icons/v4/clear_day.svg": "b8c67eddc94a8736975c0c969b383c86",
"assets/assets/google_weather_icons/v4/haze_fog_dust_smoke.svg": "2ae216c574222d5906105b8970109430",
"assets/assets/google_weather_icons/v4/violent_rain_showers.svg": "b72b1f1bfd2a4d9f987766091417ef0d",
"assets/assets/google_weather_icons/v3/icy.svg": "938cd0483a49536ac877d3de0d5119d7",
"assets/assets/google_weather_icons/v3/wind.svg": "ee835965e53487161dc4f00a84f60fb1",
"assets/assets/google_weather_icons/v3/mostly_sunny.svg": "6182aa8d836ba651f51e087eae709df6",
"assets/assets/google_weather_icons/v3/wintry_mix.svg": "07b4bbf65fabdd31dbe9a57ca284c116",
"assets/assets/google_weather_icons/v3/arrow.svg": "0d490d02059e34ab7dee19d18a8ae58c",
"assets/assets/google_weather_icons/v3/dust.svg": "128e22e3dd8294e55d07e257ba96d19f",
"assets/assets/google_weather_icons/v3/mostly_cloudy_night_alt.svg": "aa656a59c01206dc2ac3481d2f09e5cd",
"assets/assets/google_weather_icons/v3/mostly_cloudy_night.svg": "bfb60f3c7809088054dacf12b09b3f5e",
"assets/assets/google_weather_icons/v3/droplet_clear.svg": "9f3eb6d0ba0d8d010e6490ca89a4d317",
"assets/assets/google_weather_icons/v3/scattered_showers.svg": "06631be2972ed9192b4bbac30d9145fd",
"assets/assets/google_weather_icons/v3/tornado.svg": "c7eab24a8557530d388f2b4ec8489fbd",
"assets/assets/google_weather_icons/v3/clear.svg": "4f47e8c0389cbf5f60f105a7032d91aa",
"assets/assets/google_weather_icons/v3/arrow_contour.svg": "f19e12e3a29d8c8e6a3e6b4e511896fb",
"assets/assets/google_weather_icons/v3/heavy_snow.svg": "b6a783a00d81d4025096e1242edc67ef",
"assets/assets/google_weather_icons/v3/arrow_4.svg": "be16f25fb67ebb40adb46f3f3005b7df",
"assets/assets/google_weather_icons/v3/arrow_5.svg": "7f24764c7151d5e612c6e20f4ea63d7a",
"assets/assets/google_weather_icons/v3/partly_cloudy.svg": "0f0013b3875463e62e42e50e767ca218",
"assets/assets/google_weather_icons/v3/partly_clear.svg": "fcde76c608cb17700da17aae9ecbd859",
"assets/assets/google_weather_icons/v3/clear_alt.svg": "1b4a772d7a3b87d5f96b26bf245f8d4e",
"assets/assets/google_weather_icons/v3/fog.svg": "12d12edb84c9d357d0e3f529b07c0f20",
"assets/assets/google_weather_icons/v3/arrow_2.svg": "a631bfc52a2a4034e84df5f9f031bb6e",
"assets/assets/google_weather_icons/v3/arrow_3.svg": "eae45d00a27b0897b831d58dfb2c3db4",
"assets/assets/google_weather_icons/v3/isolated_tstorms.svg": "ce5b9aec899879ea658be2bc8d44d562",
"assets/assets/google_weather_icons/v3/mixed_rain_hail_sleet.svg": "279fb837bc889477fec2e91e407d060b",
"assets/assets/google_weather_icons/v3/scattered_snow.svg": "df5f3b75403a7bb75dadd9df0d0a547f",
"assets/assets/google_weather_icons/v3/sleet_hail.svg": "301345a82a058148dbdce8abae7f9c9d",
"assets/assets/google_weather_icons/v3/droplet_heavy.svg": "3c5ca3174cd5a7b45d55d5f6922df573",
"assets/assets/google_weather_icons/v3/drizzle.svg": "64c73591c4bcec8904c24c41270cdcd0",
"assets/assets/google_weather_icons/v3/flurries.svg": "e7c9e876ad772fce9fa104a92241a429",
"assets/assets/google_weather_icons/v3/showers.svg": "947680ab018cd06f7e0c3229adfb8b94",
"assets/assets/google_weather_icons/v3/very_cold.svg": "adc81917afa4c70d072809f5d0aee1b1",
"assets/assets/google_weather_icons/v3/mist.svg": "41afa5afb811ea51ce6f9ca1908b1ec7",
"assets/assets/google_weather_icons/v3/blowing_snow.svg": "98cbb039cbb589a82302aa2ffb9465ec",
"assets/assets/google_weather_icons/v3/droplet_moderate.svg": "df153536f7cb5e652edf33443b8139d8",
"assets/assets/google_weather_icons/v3/mostly_cloudy.svg": "6ef9e023e4a4c8848adf9bd1845ea9ae",
"assets/assets/google_weather_icons/v3/arrow_centered_jg.svg": "a36e1c0f77f8b74d87cce8e33a7736fb",
"assets/assets/google_weather_icons/v3/droplet_drizzle.svg": "ae3573b2a9f1009e1d5204c8f54840dd",
"assets/assets/google_weather_icons/v3/partly_clear_alt.svg": "78214aa40212647c5b93882065e46dcf",
"assets/assets/google_weather_icons/v3/blizzard.svg": "7fdbdf465e752fc416ae58b387010e33",
"assets/assets/google_weather_icons/v3/smoke.svg": "9f436d2eda89bfaa11292c2e6e6d1b72",
"assets/assets/google_weather_icons/v3/mostly_clear.svg": "81c24945c6d02369bf88a1febfbf6258",
"assets/assets/google_weather_icons/v3/mostly_clear_alt.svg": "8bea6deebc983de813a005098749e1f3",
"assets/assets/google_weather_icons/v3/sunny.svg": "39ea2a3f35f42f9f1bc115d16916ea60",
"assets/assets/google_weather_icons/v3/cloudy.svg": "e135c55c28032b1ce363873baac1a56e",
"assets/assets/google_weather_icons/v3/strong_tstorms.svg": "d5e49229afd8ba1588d4abb8584b6035",
"assets/assets/google_weather_icons/v3/droplet_light.svg": "e1dd601685a9f7140831e5867fc3defe",
"assets/assets/google_weather_icons/v3/snow_showers.svg": "0173f92b6694055d44f75702ceaf5b90",
"assets/assets/data/climatologie_04339_Saarbr%25C3%25BCcken-Sankt-Johann_1961_1990.csv": "04821827342dc83e843346f15a68c161",
"assets/assets/data/climatologie_06217_Saarbr%25C3%25BCcken-Burbach_2001_2010.csv": "bdc8ec2b4fa22ae99c234f1db17f0ba1",
"assets/assets/data/climatologie_01072_Bad-D%25C3%25BCrkheim_1961_1990.csv": "2b8d6b21c090bcea8148dedd04366756",
"assets/assets/data/climatologie_04336_Saarbr%25C3%25BCcken-Ensheim_1961_1990.csv": "e043a4834f78878e728d1cac9b82a27f",
"assets/assets/data/climatologie_00460_Berus_1961_1990.csv": "178f2ebac0bb66084a2c14cf74025233",
"assets/assets/data/climatologie_05244_V%25C3%25B6lklingen-Stadt_1961_1982.csv": "6a96900f344cbb618203075bcd6069cc",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"main.dart.wasm",
"main.dart.mjs",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
