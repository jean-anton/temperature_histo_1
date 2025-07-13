'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "81a63a6991ce362bcbb504357cddade4",
"version.json": "ecdf215c2c8254c024d3b10eefead19f",
"index.html": "71dab1a092c36c1fe471c5461ec9be9d",
"/": "71dab1a092c36c1fe471c5461ec9be9d",
"main.dart.js": "388f84c3266a4904d94c7c3bba079e77",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"favicon.png": "a72a69bec94992898e057685950e774f",
"icons/Icon-192.png": "a15cb5fe5d824f9adc2e33b7c70e6550",
"icons/Icon-maskable-192.png": "a15cb5fe5d824f9adc2e33b7c70e6550",
"icons/Icon-maskable-512.png": "49d869b9b4b6e099a9509416db96c25b",
"icons/Icon-512.png": "49d869b9b4b6e099a9509416db96c25b",
"manifest.json": "8a0cca5366bf447f036e22977c708970",
".git/config": "0a8ae2f66751282ae6cd6a886c459673",
".git/objects/61/bdd20cc971d1fad95939fc1f025def3b824fad": "cd783637cb2b459a83ae39731db044bd",
".git/objects/61/1f19507418a50dfda731353be62f2e4d6a632c": "f6e553e84462a8d36f96423b8493f7b0",
".git/objects/95/a3ab24e04940cd4c9ed11b879979cfbd2050b3": "34df471db626a30bac29a8fe11652b20",
".git/objects/0c/1b1d21339652459fd420c7a61e7e9e9893d512": "7b1accf564a5134c8e73dd451dd5c2cd",
".git/objects/6f/2c68addbae8b90f4c26903c4be62cd04630cf7": "f148a51537a14e46596b98791a837f9f",
".git/objects/9b/d3accc7e6a1485f4b1ddfbeeaae04e67e121d8": "784f8e1966649133f308f05f2d98214f",
".git/objects/3c/a4b702944f5594c375eae7c501db8d869d01b5": "81cff8d391ee641f3d5c90afde5bbf29",
".git/objects/56/a547d5ffecd037b7242e483234a6b8ffb195c5": "edd35cbd77a3994d5b464cbecc9b60bf",
".git/objects/60/059b3e7b37866629b5fe016c174a9737852d1e": "d6a8a9a347bcfa599ebd163db24f980a",
".git/objects/34/e9e066b62f4ffa3fc437d3d499952a702f450d": "149bf360e9e784aa57ab3dd1c4f1a32e",
".git/objects/34/ae4e1feef15591864b5c59f9a4156f08b78bcf": "895181f3a79d35c143e4ebfabc79ac38",
".git/objects/9d/6703def54572bcef701d0d0d3c3b37194886ce": "41f141fbb51fe2b3323ed1bcd235d4ee",
".git/objects/02/af74080170c7a0f9b5975f75b849ac5f722f74": "5433f87ebe35acee885c8fccb60bc209",
".git/objects/b5/fb7aa1851765a9c54364ed230671cec20a9259": "f735c10466545e8f1358b0c466830c59",
".git/objects/b2/8fac01e03570308d0197ad4f354e63b5959393": "7632a1687a739f69c114b834019b1503",
".git/objects/ad/ace8df502cea5f5584a3af1cec373753be7d87": "9fa00c958acc8f10c2a0cf3cdf8f6b6b",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/b3/6320af0dd25c422fcfd608639570400725862e": "b381f78db9d7502e06aa7294c0d3869f",
".git/objects/da/9cc682868f646f058e0c51b1a37efb65d0b6c1": "bee77d43058e7dad06485f7e43087a6e",
".git/objects/eb/d433dab3e0819ab0854a7a3e917ba26237917f": "6bd196e9fea894029e2076092c603b35",
".git/objects/c7/85c84c83295a2c19a0ff31048ec3feeb804343": "088d4ad6950efafcebb4445c03953d93",
".git/objects/ee/5d7d73a7dba4747e6e7c0d25973d67ed5fafa0": "04a1a9d416b97bc7e74bf5da5153a30f",
".git/objects/ee/0e319c5539dbb17d9167d3b7194b5e1a963b42": "b8904b0dc33f998f23b01fa587059178",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/e3/b77e286b343ad1323cc92ab52ed2acbca33b6c": "a3a69c9777e7f9333cb8d71934375e80",
".git/objects/e4/460f57f1e19fb64af6607025f4f301198fbdfe": "656e7f66a6a5b917d246aa599c7a0ad4",
".git/objects/c8/08fb85f7e1f0bf2055866aed144791a1409207": "92cdd8b3553e66b1f3185e40eb77684e",
".git/objects/ed/2bc0ff3d006f9021ef9f98a9f16dc5f85b5fc8": "1b897f97dbba7a032f9b785e25c53746",
".git/objects/11/c8012f8869287b762aac62cd04ccb87a0fda58": "8971e74e3d0737ca549e36e5fa7fd29a",
".git/objects/1f/6d516ef616c8bdc87746e0e2587e4bbd6e3a3f": "949d6cc8fc63603188b4751eb34f2eff",
".git/objects/73/d0ef7fdbcdc1489705cc6e6e422866cdf6417c": "fbd6c37f95db53841a899f18e50f47a5",
".git/objects/73/c63bcf89a317ff882ba74ecb132b01c374a66f": "6ae390f0843274091d1e2838d9399c51",
".git/objects/73/a478576e622bfe3287146f93075362bdd33d70": "205be5a4d53a51bffa1655643b1ace69",
".git/objects/73/4c544f660f5adc337535d6719aa1023edabf00": "b059c86024e9b13d017dfc13c0805693",
".git/objects/1a/d7683b343914430a62157ebf451b9b2aa95cac": "94fdc36a022769ae6a8c6c98e87b3452",
".git/objects/81/792343d4fea8d35020a5356a833b9dbf71ff14": "e68328b0c672e26f8d621faa5e297dfd",
".git/objects/86/0a99a6b54fae90e46fac689dba45e2e11c5c19": "3a61c6e8591a834cd04b12019cea4b15",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/07/3aa32c2c86313c215e764294115ed66f14acf3": "9936a1dc7b10aeca8de570e8c2d20059",
".git/objects/38/2bbe112746de82877c200d591e24dceb0598b1": "a79965293b5d49ba2b3362e2df6f098e",
".git/objects/38/d02b9205847ffc78206b7ba42cddddb3041af9": "189a829b1c33ba178a1f1f9c22747d40",
".git/objects/38/ebdfb666c06790092841f2111ddb421386a64d": "265e2e0e516e876905c31b9f6c14b278",
".git/objects/5c/4c514abfe970357157dc67ffa2c11f711f5af5": "af38ac2a01b16a7c2352413f45523414",
".git/objects/5d/52d0e7bf75f9496932033f143807d64a0cfb40": "d33407b4f7ba6c04c37f2b2bb0b37a27",
".git/objects/91/64e620ad2eb1a32c656b27afad59f352dd5015": "c924dd87f36f24772d01c80ba7d63344",
".git/objects/96/e5ee6e5208ff72acc043acd5cdd63d585f771a": "e34d91fc8ca38e069846e58b18c09374",
".git/objects/96/58ea4c80a57df9657761b68e6b94da15787502": "49dc7d14554dd61f6fd5e91672e7f765",
".git/objects/96/d08c1fad62e6d564f4c19ea23ac5b5f843543d": "f443c83acc527c472a62be9836ea154c",
".git/objects/54/b4a4796974dc37a26a6f69934d5947e7b588ac": "2e28f25c52b94e7542c2bad21ecbc493",
".git/objects/53/18a6956a86af56edbf5d2c8fdd654bcc943e88": "a686c83ba0910f09872b90fd86a98a8f",
".git/objects/53/3d2508cc1abb665366c7c8368963561d8c24e0": "4592c949830452e9c2bb87f305940304",
".git/objects/5b/7c4d676d0c13987add9d878264b60c4d892483": "e09b7fdcf998dacaa85af74c35153987",
".git/objects/5b/a8aa3fcc8ef395fb37fb703932bb0c21e765b6": "52baef44fda2bcaf29796d17122f378e",
".git/objects/08/a1ee68192844e378fe56d980df286e5f0af25f": "f1de352db1212e071769f7c77002238e",
".git/objects/6d/77353e82cc5535422f57cdb082968292a3de80": "56ec2bb91d40e0cc5ba35447ada41dc2",
".git/objects/06/fbf9a11412d5b3dd59339f368420949be0c593": "72aba801b64c5122e3754aa19ec421af",
".git/objects/99/003709f71b5871b9a8a3bb9e52cf76df69c8cf": "25279c1bd3f9edd0ec6fd9df24ea5236",
".git/objects/52/a94e8fe6d7b15ff199e3950a406d3afaa96ff2": "82be9222ad561b923565c300f83f06e6",
".git/objects/55/f8044b2767f0f6efd731f7b81bc827cd97806a": "03965efd2b0d8da0cdb2a4e7bd1d9023",
".git/objects/64/8ec805bfa506ed4c36fe533bd7831c430ecb33": "8a3a82871000aba8465caa04cbb2026b",
".git/objects/64/02ea9682053272fb8cac8e4caf388e817febc8": "703a676a10dda5cbed27ea4cc2b3738c",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d4/ff6709731bfaff7f17628cb126f997c3e08c45": "86d1472a01eccfb1ec7f8eaf12fac409",
".git/objects/dc/11fdb45a686de35a7f8c24f3ac5f134761b8a9": "761c08dfe3c67fe7f31a98f6e2be3c9c",
".git/objects/a9/86f1b431806fc81432f3489c963e37a5b7363f": "2eeec4a77bd01c4af114ecac8f3f1ac6",
".git/objects/a9/d62fa5e9607a3776733f4db7798672a82508fd": "27e271f9041b63f5d1f07458739fe756",
".git/objects/aa/05122927d0477ca4257ee8af0650750fb58528": "2bc604e98eacffb03f63f4b36a2848c6",
".git/objects/b7/5e9b2a5a53acf602caee23b68dc84d865cf268": "eb5d0a1d6c3bceea0182243673b63e7e",
".git/objects/b0/c8c68619202488bc7b77446cf36f1f4c9cb7f7": "b5ee7acb5b77da915e24d7b64ea828e9",
".git/objects/b0/fb523806c6ec09b92dd6e56b145e3df07ca132": "ef96ff86a7b337b307752313450cb808",
".git/objects/b9/6a5236065a6c0fb7193cb2bb2f538b2d7b4788": "4227e5e94459652d40710ef438055fe5",
".git/objects/e6/27fe20001414860f830267e5dbdb8796051626": "945c8b3cfbf10e69f6638123e40d6ba2",
".git/objects/f0/a81638d7754a0e52ef6cd43ae85c1cab323795": "b3b84a2336b086767315e6fda3b2e1c1",
".git/objects/f7/61aa61b403f8ac9b7e8cc9c46843d27b360594": "0d2f5fbe04a844eface7b2199ee95d51",
".git/objects/f6/e62f1b3342bdd8d26e2caa52dc1d44406fa1b5": "dd4df684afe7f978c8904f56e9a0cb68",
".git/objects/f6/00011751d8c8674b97c12d10a30f15db36fe6b": "fa0ae3401517b727e6c56fd04d270c3c",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/e9/c4e17c639240fe1c7dbfc49482803465bc2483": "09c9f24213043c4a31fd0f3b7adbe350",
".git/objects/f1/5317dda13bf2baa5b3d081ab5cc9a71aefbbe7": "978e9bd8877cfec30f9a2cf5e5dc3db7",
".git/objects/e0/7ac7b837115a3d31ed52874a73bd277791e6bf": "74ebcb23eb10724ed101c9ff99cfa39f",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/1b/6778311f816d0356aef4816e226e63867174e3": "7e4e04b53b0a9f5b202ab474ff198f77",
".git/objects/70/a234a3df0f8c93b4c4742536b997bf04980585": "d95736cd43d2676a49e58b0ee61c1fb9",
".git/objects/70/7932058db40745269d600a4450eb5576ccda07": "e69d131715ca6898f82a5eafca52814c",
".git/objects/70/a3b3cfcb1bbcce1fa85a38a9332b6e6e371706": "43de2665fcf2b07e67725a1224a61a86",
".git/objects/4f/3bc2a828e42ce4a9ce85ec50b081d4fee6f571": "9b290c6bf67179588401c4d1065bf9e2",
".git/objects/82/1ccf46553e4b3637ce302389c880fd46fa2920": "bbf950b0308ce29543423bd02520c722",
".git/objects/49/4765c02335ce8a9175b431491cbbe9477b2409": "31b2b40df8b91b6bc7b70ab0a28dc643",
".git/objects/47/4ba56f5c4a0a44b5963f72880c0143b1b95ead": "97a9627079395d27983bcd4919c0fb24",
".git/objects/78/47f84b84adaf999b5d2f83308c3ff1f5fe9c75": "789424bfcc00697cee49d6c6a39ee4ef",
".git/objects/8b/b8af3c18e355bac2567d50c59d0920988c058e": "1b4a7a150949870d473d283887b93730",
".git/objects/13/47b0df99b6b7cd4a795118e6c8ff7443b9ffc7": "907a3f6379b4b8a3a874e2c350832692",
".git/objects/7a/4e906ff95df59c332cead2190fc20109e876e3": "ed439f2371a3166412cd615b2bc7ee54",
".git/objects/8e/a12ea2c7bf000d9d1470361905d7e29062bfed": "4e8e9d6a40cc89583fb5992c4652c084",
".git/objects/22/536e6301d250b939dfa684f661a9b44e4516c5": "80abcb5bd427ec3271d08f65edc554e3",
".git/objects/25/dcad6c08f5cbd2cb4c46c7128bce7ccb2fb8b7": "6ad684901b4757ff494aa7a06fafd46d",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "bac96e90d3753f8fc7020b209b388e96",
".git/logs/refs/heads/gh-pages": "5afe9dc2ced0feb04240206bbe28be45",
".git/logs/refs/remotes/origin/gh-pages": "8d58842d869ab8375d0aa4fc61424140",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/refs/heads/gh-pages": "8afee7408806421e94421b80179b704c",
".git/refs/remotes/origin/gh-pages": "8afee7408806421e94421b80179b704c",
".git/index": "573147e2d904d8ae88084c1abe947333",
".git/COMMIT_EDITMSG": "e88b8b09b370e3dcd8659c1f93ba74c6",
"assets/AssetManifest.json": "5e467ba0303b750e81b8feeac2d0833b",
"assets/NOTICES": "daaff9bd02e402f720b9861ab157b797",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "d8b702544263b25931e6959266c5844f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "03be4226cce54bcd9a7c019b568ddf38",
"assets/fonts/MaterialIcons-Regular.otf": "278de603263c310310b9780db790ef0d",
"assets/assets/google_weather_icons/v4/snow_with_cloudy_light.svg": "a0584597bf9025c2374b102ad347f51e",
"assets/assets/google_weather_icons/v4/icy.svg": "1ecc9dc29e309324c51c4ef3a77dbaa2",
"assets/assets/google_weather_icons/v4/moderate_rain_showers.svg": "1482d5702338626044c7e1e5943cbe7e",
"assets/assets/google_weather_icons/v4/tropical_storm_hurricane.svg": "fd2be5dac09e0b9d517fc910fca35482",
"assets/assets/google_weather_icons/v4/windy.svg": "f19b7c1f0796762b5a163db7602cbd00",
"assets/assets/google_weather_icons/v4/isolated_scattered_thunderstorms_day.svg": "2f726b853c3f03c6181df2521441bb7e",
"assets/assets/google_weather_icons/v4/slight_snow.svg": "bacea524081014f81b8c29634254a731",
"assets/assets/google_weather_icons/v4/rain_with_cloudy_light.svg": "fdbc92563ebcd34af52bfefcc5b6aa73",
"assets/assets/google_weather_icons/v4/sunny_with_cloudy_light.svg": "111ee3a20e96447dc4949f03c89c0f32",
"assets/assets/google_weather_icons/v4/umbrella.svg": "5d4e1ffa0e37a41962c1275f86f88146",
"assets/assets/google_weather_icons/v4/rain_with_sunny_light.svg": "6add86a99189ddb079b82a1022613ccd",
"assets/assets/google_weather_icons/v4/showers_snow.svg": "fee84f5cb9756564496adc631c0288d4",
"assets/assets/google_weather_icons/v4/very_hot.svg": "a906bd825969a41eca75e2d17885fc49",
"assets/assets/google_weather_icons/v4/snow_with_sunny_light.svg": "93eba3eb6e080982c1d5d0a1e717c5ab",
"assets/assets/google_weather_icons/v4/cloudy_with_rain_light.svg": "6d50a72a6c0ca5ab1b505c7334d7b861",
"assets/assets/google_weather_icons/v4/snow_with_rain_light.svg": "db5e29aea340ca2c3f792081b0d38b0a",
"assets/assets/google_weather_icons/v4/tornado.svg": "8cb61c28d22b47be1c0778d751011c48",
"assets/assets/google_weather_icons/v4/mixed_rain_snow.svg": "ab01723377d0c1cfae0fb95850d24d60",
"assets/assets/google_weather_icons/v4/mostly_cloudy_day.svg": "37871399465d85ca177c0071730aaf25",
"assets/assets/google_weather_icons/v4/heavy_snow.svg": "b1f6d071867b6ba5f9e8baba0d3d56ec",
"assets/assets/google_weather_icons/v4/scattered_snow_showers_day.svg": "5f45aff1d4fb2b5820eb6358da453c02",
"assets/assets/google_weather_icons/v4/scattered_showers_day.svg": "f2ef7e8140c2435201b6bf6cce90ec64",
"assets/assets/google_weather_icons/v4/slight_rain_showers.svg": "b48a7099cbffd2e6953b508e75667280",
"assets/assets/google_weather_icons/v4/partly_cloudy_day.svg": "a51edb721d94941c90f87d5912a5c197",
"assets/assets/google_weather_icons/v4/cloudy_with_sunny_light.svg": "01c15a673b0537c81ec132a97e21624c",
"assets/assets/google_weather_icons/v4/sunny_with_rain_light.svg": "bce4519e43746b648256127a500f20ec",
"assets/assets/google_weather_icons/v4/mostly_clear_day.svg": "05022abb50adb1756dc07ff961ca756a",
"assets/assets/google_weather_icons/v4/mixed_rain_hail_sleet.svg": "00fcc178e42cf45a776413c5ef0eaf93",
"assets/assets/google_weather_icons/v4/sleet_hail.svg": "ca11de070e20d84d86bd4d45cbee9bbf",
"assets/assets/google_weather_icons/v4/moderate_drizzle.svg": "84e6d80a4824ef7c0d7df5013b221d88",
"assets/assets/google_weather_icons/v4/showers_rain.svg": "a2febf601016afaa23056eb97505caf1",
"assets/assets/google_weather_icons/v4/drizzle.svg": "a906ea648e6fc6f6207984dc79e70d44",
"assets/assets/google_weather_icons/v4/sunny_with_snow_light.svg": "3cccbaeabc55975aa4d4d31b35570111",
"assets/assets/google_weather_icons/v4/flurries.svg": "bacea524081014f81b8c29634254a731",
"assets/assets/google_weather_icons/v4/very_cold.svg": "d0c9850ae8342485666902cb892eebc4",
"assets/assets/google_weather_icons/v4/isolated_thunderstorms.svg": "255d629e772716bbc8b3fc7a6aa20a21",
"assets/assets/google_weather_icons/v4/slight_rain.svg": "a906ea648e6fc6f6207984dc79e70d44",
"assets/assets/google_weather_icons/v4/blowing_snow.svg": "595ee77f77d9e4d4dd8710379ed435d2",
"assets/assets/google_weather_icons/v4/heavy_rain.svg": "3d06fb2222eec018e3184373857dbc2c",
"assets/assets/google_weather_icons/v4/strong_thunderstorms.svg": "d336b05073939b66e3e66bcba725a28e",
"assets/assets/google_weather_icons/v4/cloudy_with_snow_light.svg": "db698a8ac559e4f24df28b216b3b89e1",
"assets/assets/google_weather_icons/v4/blizzard.svg": "3a5779e27bfda0ccf75067bea3e15b47",
"assets/assets/google_weather_icons/v4/light_drizzle.svg": "f73b6a82f5bd45dd9dadcd5151c42fc2",
"assets/assets/google_weather_icons/v4/dense_drizzle.svg": "8cd2867ef39999f888f15d3b394a3d7b",
"assets/assets/google_weather_icons/v4/rain_with_snow_light.svg": "aa0e557c855efc206b525a9ea4293d0c",
"assets/assets/google_weather_icons/v4/cloudy.svg": "d90284e2092644cf6ec39a57b3ce5bc7",
"assets/assets/google_weather_icons/v4/clear_day.svg": "071dabc4b19c140c856956ed4d78601e",
"assets/assets/google_weather_icons/v4/haze_fog_dust_smoke.svg": "2ae216c574222d5906105b8970109430",
"assets/assets/google_weather_icons/v4/violent_rain_showers.svg": "b72b1f1bfd2a4d9f987766091417ef0d",
"assets/assets/data/climatologie_sarrebruck_04336.csv": "f83a131134771b852e3a7363d1b26265",
"assets/assets/data/climatologie_berus_00460.csv": "6cc0dd7b478938db6700a11062f4d049",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
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
