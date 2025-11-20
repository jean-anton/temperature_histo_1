'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "17dad836038e49cb4f6231d50e45c233",
"version.json": "ecdf215c2c8254c024d3b10eefead19f",
"index.html": "71dab1a092c36c1fe471c5461ec9be9d",
"/": "71dab1a092c36c1fe471c5461ec9be9d",
"main.dart.js": "6ccf2c7e60a8e356e62b378a5bb8a920",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"favicon.png": "a72a69bec94992898e057685950e774f",
"main.dart.mjs": "50de3f9d362f6e48052c48be17afb385",
"icons/Icon-192.png": "a15cb5fe5d824f9adc2e33b7c70e6550",
"icons/Icon-maskable-192.png": "a15cb5fe5d824f9adc2e33b7c70e6550",
"icons/Icon-maskable-512.png": "49d869b9b4b6e099a9509416db96c25b",
"icons/Icon-512.png": "49d869b9b4b6e099a9509416db96c25b",
"manifest.json": "8a0cca5366bf447f036e22977c708970",
"main.dart.wasm": "8df3051368725e7211b220f0eeea4e2e",
".git/config": "0a8ae2f66751282ae6cd6a886c459673",
".git/objects/61/bdd20cc971d1fad95939fc1f025def3b824fad": "cd783637cb2b459a83ae39731db044bd",
".git/objects/61/225cdcfd673aa8e566adb5890abf87ced41400": "c9408eebb1e6fa7c31c2c7a458e7e974",
".git/objects/61/a80d5b4bfa9eba42f099bd801d0193c8c0ba9c": "ca58f057aa677179b6845aeda242a075",
".git/objects/61/1f19507418a50dfda731353be62f2e4d6a632c": "f6e553e84462a8d36f96423b8493f7b0",
".git/objects/0d/75c0fa39e17e6756edd8d24779cdc6d3684859": "cf50c09e4de91ab185d7d1701e18681e",
".git/objects/95/a3ab24e04940cd4c9ed11b879979cfbd2050b3": "34df471db626a30bac29a8fe11652b20",
".git/objects/59/cb9ef4c5e29a34ca489803faeefffcd8f8ec44": "0e6f65a8325b8fd9803945ea4efadba3",
".git/objects/92/6a038ae71d8216b6e1de936c2246f5c9d7776e": "93e841e45f89a83920630394c2d0d113",
".git/objects/92/fd570a6c1e2197b8adbdaea325d6ee8c49580f": "5b95a54f7255aa08b0012ee243f08cec",
".git/objects/0c/1b1d21339652459fd420c7a61e7e9e9893d512": "7b1accf564a5134c8e73dd451dd5c2cd",
".git/objects/0c/309591bdbd94aaa93ab53ea91bbc2a8a0eb430": "e3db0f12e0d83e354124dd0ba42b1a5d",
".git/objects/3e/58b69b203a80fa55156ab21a733aa93f7acc73": "6fdf8aaf71c99adbd2f83bc61043393e",
".git/objects/50/08ddfcf53c02e82d7eee2e57c38e5672ef89f6": "d18c553584a7393b594e374cfe29b727",
".git/objects/50/42549dbd78d18a5c6fc5b1aaa611a03800911f": "7d2ab384d6173a99ee935ac5b4a1974c",
".git/objects/3b/1e055cfe68ee01e027a46897aefac66ee8f42b": "7cdb96ea9ac26bbce7e256ea8bffb56d",
".git/objects/6f/2c68addbae8b90f4c26903c4be62cd04630cf7": "f148a51537a14e46596b98791a837f9f",
".git/objects/9b/ebeb002e67bd44e9b87bec05e726c5e0de23f5": "cfafe06f5d12bfd39e099e204a705d8c",
".git/objects/9b/3ef5f169177a64f91eafe11e52b58c60db3df2": "91d370e4f73d42e0a622f3e44af9e7b1",
".git/objects/9e/3b4630b3b8461ff43c272714e00bb47942263e": "accf36d08c0545fa02199021e5902d52",
".git/objects/04/ab93aab219e05138729cc785026913818e6cfb": "cc2c7681fa9360befeaffb2b03597626",
".git/objects/6a/be2c9e4fb9c5078267534081e3b063305b820b": "ed3d34e00dbe6bbe572ba9bd11ed19cc",
".git/objects/32/399f156251d4b55a122a0247e6ca8c397d22c0": "1705ef9b5f53e208b865889a49193f0c",
".git/objects/32/7bbab29ae2539739861a007bdcdd4f2184b59c": "29b2c29598d3ccfc2940da2a5002926e",
".git/objects/69/dab5947b7e62fd718af7b5e2faa94139fc7e00": "41796446fd8da737b67350a1563f1299",
".git/objects/3c/a4b702944f5594c375eae7c501db8d869d01b5": "81cff8d391ee641f3d5c90afde5bbf29",
".git/objects/3c/715262c044d2c1282737fb2d19a8582c0336f2": "52c77b4a6b9e09311ceea44b9287997e",
".git/objects/67/8618c38c10d16e556cce7c62de9cab107148b9": "b5e1c0a1aaf52b1d5361f5eb8866a1a2",
".git/objects/0b/6b68b8df6aeee981de84d5119fbf85741557aa": "2eccac926d7723b37084b5d782d13bf2",
".git/objects/60/059b3e7b37866629b5fe016c174a9737852d1e": "d6a8a9a347bcfa599ebd163db24f980a",
".git/objects/60/5300e8e749fb9315f5fcd9ac19806dddb1ea68": "1c8be219d5f261083d4943e8975fc04a",
".git/objects/34/8c56670f5d922ef043efce1abdd61ac13481da": "619c89af8eb69db5b8001461ed3510fc",
".git/objects/5f/9e36460de3437acdd44452728e0f1494e70a7f": "7ab85b7ac8af351a008970720719dd82",
".git/objects/33/f869e561d33a62e3137ada0c19ec69d6ab2849": "c344140f1b82e399f32b4ab4233885b2",
".git/objects/02/7d6bd88e8884ec433754fab4e0fed4c23bc241": "f7b7880d64b8c962a95878572f7a8474",
".git/objects/02/411393e50a94c9eaf3696beebe5a8beceaf93b": "76f22a4fe2f9dd7adbd2155d5c530750",
".git/objects/b5/968673919d3ccd8819a0196b200737860cf279": "3f1bd28f00a159d905c78dc935d0cf24",
".git/objects/b5/fb7aa1851765a9c54364ed230671cec20a9259": "f735c10466545e8f1358b0c466830c59",
".git/objects/ad/ace8df502cea5f5584a3af1cec373753be7d87": "9fa00c958acc8f10c2a0cf3cdf8f6b6b",
".git/objects/bb/1f5f90c0b018f055d29095f7b1ed4352c2c79a": "cd5f533045d825470050ba92f126b886",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/df/3d5248b53c2eaf0611eea1d5d243ff2e39dbff": "f0aa09c27b97d2b2991948274a40fa23",
".git/objects/da/9cc682868f646f058e0c51b1a37efb65d0b6c1": "bee77d43058e7dad06485f7e43087a6e",
".git/objects/da/0d5aa44a8c93eda469f7a99ed8feac32d5b19d": "25d25e93b491abda0b2b909e7485f4d1",
".git/objects/da/788e1035f2f2702076d92f9fa43b2022d1cfd4": "6e81509ebba0412c0d9f528d753d9d0c",
".git/objects/b4/4535b07ec835d0bb8ba73d2f94278e31d7aacc": "7e33bc3ef3d79cbe332cecf667c55114",
".git/objects/a2/61a9de58a24fcfa7f50309ed56d9f167936b17": "5223412931e5dad72288fe86c728f12c",
".git/objects/ae/c84fddeb15305a9b69470e3ab8900ce10add6a": "990c4842344ae710490d15982b02d6fa",
".git/objects/d8/8128adaad90d2fd7cdabe7b36eaaaed0d3a25b": "3d15963af0d77c1cd40702fb7c18fa93",
".git/objects/e2/4c7e76a48956ae48f5fede4f36fe36149e95ea": "901ca2c38bd79e589301e056e640e789",
".git/objects/eb/7f0f91c171bb33c03e8c90b59f97b0d3a13681": "a3172cc58b7e50ff8da08eff752f6eca",
".git/objects/eb/d433dab3e0819ab0854a7a3e917ba26237917f": "6bd196e9fea894029e2076092c603b35",
".git/objects/c7/85c84c83295a2c19a0ff31048ec3feeb804343": "088d4ad6950efafcebb4445c03953d93",
".git/objects/ee/5d7d73a7dba4747e6e7c0d25973d67ed5fafa0": "04a1a9d416b97bc7e74bf5da5153a30f",
".git/objects/fc/20a6992b8deaa2428fed339022c91ba4973657": "dc2d57d6a3050000ff5fd45c78c4661d",
".git/objects/fd/a432cb78fe4f1b655a3baeb177d9d7a77df48b": "c0fae1ed9259dfaa506f9a11267dc03f",
".git/objects/fd/a32217eaec1a1e682c6b39be08c67639b0c4da": "f48712acea582987d137999a883e4eb9",
".git/objects/fd/ec2ae44aceca68f32c5ca61fb118dcb780c9a7": "89c4602231f852fc1face7f2b4486bde",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f5/7206ab8ede37ec47344904e0e2f1c071e77f3a": "b7e427d2f6a12e39d83707a4e152cc36",
".git/objects/e3/45c3e2af27847d6ac7712b5d552149492782a8": "0c4b72f0e074957510b299b06f80b37e",
".git/objects/ca/3bba02c77c467ef18cffe2d4c857e003ad6d5d": "316e3d817e75cf7b1fd9b0226c088a43",
".git/objects/e4/460f57f1e19fb64af6607025f4f301198fbdfe": "656e7f66a6a5b917d246aa599c7a0ad4",
".git/objects/fe/3b987e61ed346808d9aa023ce3073530ad7426": "dc7db10bf25046b27091222383ede515",
".git/objects/fb/162b3b914bfc2ed4d97b576e65f848d9de0cd2": "b16102f7ffc1b6a566cbc3ff186987a4",
".git/objects/ed/b55d4deb8363b6afa65df71d1f9fd8c7787f22": "886ebb77561ff26a755e09883903891d",
".git/objects/ed/2bc0ff3d006f9021ef9f98a9f16dc5f85b5fc8": "1b897f97dbba7a032f9b785e25c53746",
".git/objects/20/3a3ff5cc524ede7e585dff54454bd63a1b0f36": "4b23a88a964550066839c18c1b5c461e",
".git/objects/18/447156a46dd418fb8bb282b9d4ffc13df630dd": "c3179debf0a4c47a50d5989d211269af",
".git/objects/4b/04c8fd48cde58161746497624dee2001b406d8": "20515bb1a79501ec661c83a7c33775a8",
".git/objects/11/559d58aac223b602886b33331c1a07da466218": "a92f4378a64a5488b6afa80c7f95142d",
".git/objects/7d/99ff5749afa0651de1d9e5fe25aafd9e05c151": "f8eaa655a2d655c179efd337cc6c7143",
".git/objects/29/cef45f4d2a143160f09191519d72243f67edfb": "9594593a928741ba19a4ea2d39c0ad3e",
".git/objects/29/f22f56f0c9903bf90b2a78ef505b36d89a9725": "e85914d97d264694217ae7558d414e81",
".git/objects/16/a664e63fa4b7438bbad88d418284bf12a39e04": "220ffc1a037d6e27c69fac0db02abe78",
".git/objects/42/d18d9bd1710579902b1f40578f40aef5ca083c": "c7af858f241ce33b9945e67170aa94d9",
".git/objects/89/e70830f3f5ab553a526951c29547c1ded33b25": "8d6b76cff35ab4e509fce16675e96f2e",
".git/objects/1f/b775a73fd117c29a1aa4d7100bd2a1165aea5a": "6cfd30a8074ef7a4efb51b6fc09c7678",
".git/objects/73/4c544f660f5adc337535d6719aa1023edabf00": "b059c86024e9b13d017dfc13c0805693",
".git/objects/7b/5ba976a0f5c841847469de5a0e4fc5de7a57d4": "20c80eee681c2ce6c371273087d8d230",
".git/objects/8f/6cfd19d1de8ce02a42cef42a95a05c6c5859f8": "6109040e310ab6c57e23892c8a8db25d",
".git/objects/19/7e19f3da16e1b8c2b455f8ffdc9b0bb299c7c0": "4f0256ba09477806dc4e165a7a4074eb",
".git/objects/4d/bf9da7bcce5387354fe394985b98ebae39df43": "534c022f4a0845274cbd61ff6c9c9c33",
".git/objects/81/4d72c5969a31e6ebda8e374d4b4be60313075f": "22b738d35dfb59e5a6bbade9ca381f0c",
".git/objects/81/792343d4fea8d35020a5356a833b9dbf71ff14": "e68328b0c672e26f8d621faa5e297dfd",
".git/objects/86/d7d6fb8f8881c1e0d25dc7fb442b41189e4952": "2190a036cd47bffd3b0cd462f0649855",
".git/objects/86/9dfc979b6b730e9b6b23972bc8bdffe7aa66a7": "cb530bb93aeae477425a57f1606ebbad",
".git/objects/43/15c4fdbafbd504412f618a8146a82cd7555d9e": "d3c35a6b51f39c0e9ae564de864a3676",
".git/objects/6b/1eb46c91c7b42ec9b3a029f57262aadeb60e44": "03308940f946b5a52b0120ac4ca50531",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/07/3aa32c2c86313c215e764294115ed66f14acf3": "9936a1dc7b10aeca8de570e8c2d20059",
".git/objects/38/2bbe112746de82877c200d591e24dceb0598b1": "a79965293b5d49ba2b3362e2df6f098e",
".git/objects/38/3f66fb6bb3e105fb572e8f7e60418d99c06906": "80c31293ff3f954a3a746eed9debd8ee",
".git/objects/38/d02b9205847ffc78206b7ba42cddddb3041af9": "189a829b1c33ba178a1f1f9c22747d40",
".git/objects/6e/4220168e81a5204206b827a4f90a01a488ba6e": "9a5a6b7034bce5de10d0dd477a5a396d",
".git/objects/36/fa99602e30961b2ec1d56a59fc50079f675427": "0b39399c36d871832afbdfd580799030",
".git/objects/36/f9d6dc1760ea049a896fed0aa176e022faa59e": "67c7237c26e7c4c659a37da2a73ee708",
".git/objects/5c/4c514abfe970357157dc67ffa2c11f711f5af5": "af38ac2a01b16a7c2352413f45523414",
".git/objects/5c/a694f232fdbb06e3a021101e78f1950288504f": "3e0ddd3202dae2077398e896c8d80fa1",
".git/objects/5d/52d0e7bf75f9496932033f143807d64a0cfb40": "d33407b4f7ba6c04c37f2b2bb0b37a27",
".git/objects/91/64e620ad2eb1a32c656b27afad59f352dd5015": "c924dd87f36f24772d01c80ba7d63344",
".git/objects/62/fd3591cda9fcb036ed60a801c57f59c9b765ab": "2a9494bb0474057dd51ee1744155da28",
".git/objects/96/58ea4c80a57df9657761b68e6b94da15787502": "49dc7d14554dd61f6fd5e91672e7f765",
".git/objects/54/b4a4796974dc37a26a6f69934d5947e7b588ac": "2e28f25c52b94e7542c2bad21ecbc493",
".git/objects/98/a61d0b6c6aee36f083769d9610a0d7f48b3994": "c1369d94962400a1036af89b3763e39c",
".git/objects/98/0d49437042d93ffa850a60d02cef584a35a85c": "8e18e4c1b6c83800103ff097cc222444",
".git/objects/3f/4f2db5a60d716a83e17fd20566669a8950c3d7": "56695d46546ab4c5560e74690f07e5e1",
".git/objects/5e/b6268da5177422a6b6d2de9906e6fd8fe0ab38": "346336b5a8444a96ad140963828ff066",
".git/objects/5e/a34dbd567533bfb3ef98fa85d8228c406f6e29": "2fa4614f3b3c82e7407a40eb84152954",
".git/objects/5b/7c4d676d0c13987add9d878264b60c4d892483": "e09b7fdcf998dacaa85af74c35153987",
".git/objects/5b/a8aa3fcc8ef395fb37fb703932bb0c21e765b6": "52baef44fda2bcaf29796d17122f378e",
".git/objects/06/fbf9a11412d5b3dd59339f368420949be0c593": "72aba801b64c5122e3754aa19ec421af",
".git/objects/99/24059043297799dd4fc043d4eeb38ac66cc48d": "974360cdcf6123d3cff39fa0280a25d7",
".git/objects/99/003709f71b5871b9a8a3bb9e52cf76df69c8cf": "25279c1bd3f9edd0ec6fd9df24ea5236",
".git/objects/52/a94e8fe6d7b15ff199e3950a406d3afaa96ff2": "82be9222ad561b923565c300f83f06e6",
".git/objects/52/fb7ce4773416a07273ef3ba89dee26fa24020f": "c02b18f4455483687930b71ab72bf04d",
".git/objects/64/8ec805bfa506ed4c36fe533bd7831c430ecb33": "8a3a82871000aba8465caa04cbb2026b",
".git/objects/64/02ea9682053272fb8cac8e4caf388e817febc8": "703a676a10dda5cbed27ea4cc2b3738c",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d4/ff6709731bfaff7f17628cb126f997c3e08c45": "86d1472a01eccfb1ec7f8eaf12fac409",
".git/objects/b1/f85883d4722ca1d1b8c52c6422e3f849b78e13": "55a556f30048b390c40ae65ba54aeb3e",
".git/objects/b1/45fdbd86e67b1d93b0aa1f37370b927cdeac84": "4cfa10fe710163708d3b5d928c92688f",
".git/objects/dd/470cfbd8214b6454248561c884a6860e458ad8": "ca0b3eec386b0aeba5d53a98e1f18262",
".git/objects/b6/b8806f5f9d33389d53c2868e6ea1aca7445229": "b14016efdbcda10804235f3a45562bbf",
".git/objects/a9/86f1b431806fc81432f3489c963e37a5b7363f": "2eeec4a77bd01c4af114ecac8f3f1ac6",
".git/objects/d5/179f461c1ce6fe076ea11e2b5e465add9b55de": "6b92c170f2104eb49d12fb35c041f4f3",
".git/objects/d5/85eac21bec2fedf562f6a7ae0c7321b900a991": "7001bcb00aa0ec32db6e9bfc2938a6a4",
".git/objects/d2/656227b01fcc42ab0a0965a3732be7faeaa7cd": "9ca0ff8eca50039c28b16e5fcf27fd90",
".git/objects/aa/05122927d0477ca4257ee8af0650750fb58528": "2bc604e98eacffb03f63f4b36a2848c6",
".git/objects/aa/cd798ee6f5d44359eb5e9f75912e2e3031ec8e": "73d3d640fa4452bf1466511bfa37acdf",
".git/objects/b7/c4844d88b91924bbff473c06e4032691a92198": "7e16ce4cbe69f553582004f58000b0f4",
".git/objects/db/ad69ee5ce3f86696a8571b8a76b0d7cdc39af3": "fee7f5ad921fa41458f5356b23e287df",
".git/objects/b0/2859eab4820661267f5cefbfbcd185d9899e3d": "71ae62e8e569e3056654818e05103945",
".git/objects/b0/fb523806c6ec09b92dd6e56b145e3df07ca132": "ef96ff86a7b337b307752313450cb808",
".git/objects/ef/7a5e4efb75f90ac2dbe0ec37285f4fa756eeed": "0426a4745f083abef9bd2a94c751f666",
".git/objects/c4/016f7d68c0d70816a0c784867168ffa8f419e1": "fdf8b8a8484741e7a3a558ed9d22f21d",
".git/objects/e1/1af2d897324a3a64cb0ae0fc407af7f7307a84": "4166a952d5b4d9986ea10ec3ac6ce419",
".git/objects/e6/8cd1092afd3396f205d21807d20044fb2a9e43": "02e0ec147e36edb7c087d9c04c019b6a",
".git/objects/f0/1c87c5fa42e7546399b8f557d8a69dc9cc1cc4": "1539df8f93378395cd89b749034c6741",
".git/objects/f7/61aa61b403f8ac9b7e8cc9c46843d27b360594": "0d2f5fbe04a844eface7b2199ee95d51",
".git/objects/fa/c55cd1f539367d86bde0de2244c99e8fecb820": "e9c4ade4866d020882977dece8a7c7fe",
".git/objects/ff/a80326039c7f2787ff01d80a150474f3fab3b0": "071b9ca64d1fccb908eba30365e7a562",
".git/objects/c2/af51af23802c4c0c3c8f3f7c6422b515b7de18": "278947f2dda2f32b4678c994271c344c",
".git/objects/f6/0b0caafbd820026404d17d82f7ab936622308e": "9f4d4628b06067456f5feb8c3015cdbd",
".git/objects/f6/00011751d8c8674b97c12d10a30f15db36fe6b": "fa0ae3401517b727e6c56fd04d270c3c",
".git/objects/e9/a8430db138aef8678ce2ba824b24c91c4b3264": "5c37be73d5d77c5e05516a50f0433b50",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/e9/c4e17c639240fe1c7dbfc49482803465bc2483": "09c9f24213043c4a31fd0f3b7adbe350",
".git/objects/cb/eaab1b42e9da1a1916f6ea03a395023ed23065": "8db5cc61467b66d1f390f38fc981b888",
".git/objects/cb/5ab4a31f7dd7c0df7383466c549bef2dfbe76f": "30defa0bbfbd344e0c19b4b506ba36d4",
".git/objects/f8/a573f7da0a038c19837358c8d6419f775f0249": "2d4dae6ab11a9a45517e0b66aeeae01c",
".git/objects/ce/fe57574ea5317fc81ad083318d4c77c07d9d6a": "3af250d0b48e0f15bf14e10b9fc69093",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/2d/0b602915d2b08f71d36813590b0b23d267de67": "1ae144a05f6ec0ba6c0c9c728c1f36c3",
".git/objects/83/6710a0814b5d388139672d72269eb9c4e1b9a0": "14eb85dc7e2d0a7c90b9bfdc4ea7d099",
".git/objects/48/82893d0ccfa660fcbaf588c42d2022af3d6807": "9c9b7834c972a80de99551756fe306f2",
".git/objects/48/22f62d11952ee0ba61c75dd53ce54d093c4a26": "53047aeb960c3893a84024f93bd4e8b6",
".git/objects/84/9dca3a9fceb37ac4731ff421a5df724310e1c4": "3658aeef1f995c86ae5075f546e815c1",
".git/objects/24/2481fd52125f799dea800e98b170175e1663fe": "3afac39a71274424cdc5650d5d562a81",
".git/objects/4f/fbe6ec4693664cb4ff395edf3d949bd4607391": "2beb9ca6c799e0ff64e0ad79f9e55e69",
".git/objects/8d/eb0f1d5e18af76543f9e84e09b02d1321ce6a8": "46777d2cdfdd0a4f287aead82f451e2a",
".git/objects/85/948b9e8600dfd9310bee2ae124437892a0cee6": "d12676213a1ada23877c190988d1da29",
".git/objects/1d/39626da7e743216d22ceac39b55e1cff878a89": "74117fc9d23d1c6389eb40c27d358957",
".git/objects/71/f0405ef4953c28b69bf06bacd5ecb7025f9cb7": "697249a022cb8276b6826ff3136e8fd4",
".git/objects/82/1ccf46553e4b3637ce302389c880fd46fa2920": "bbf950b0308ce29543423bd02520c722",
".git/objects/49/4765c02335ce8a9175b431491cbbe9477b2409": "31b2b40df8b91b6bc7b70ab0a28dc643",
".git/objects/2b/70063f313e01662b890cf91c656acdbdc4c779": "53ecd93c3dcd7cea205b47a68559a48e",
".git/objects/78/83389b19dc9c063319dd69d5e59c7d7c634076": "9a139ed5853eea5e8b3495c18a85de2b",
".git/objects/78/c23256db3eade5765c7d998355979074bc3dc2": "b968f93fda3a1d3da9490925d16f0650",
".git/objects/8b/155a7a470e29e576b1a5d3679cfe4ac9857585": "2ee15e09b890243638c2c62bb0a30c0d",
".git/objects/8b/b8af3c18e355bac2567d50c59d0920988c058e": "1b4a7a150949870d473d283887b93730",
".git/objects/13/47b0df99b6b7cd4a795118e6c8ff7443b9ffc7": "907a3f6379b4b8a3a874e2c350832692",
".git/objects/7a/6c1911dddaea52e2dbffc15e45e428ec9a9915": "f1dee6885dc6f71f357a8e825bda0286",
".git/objects/7a/4e906ff95df59c332cead2190fc20109e876e3": "ed439f2371a3166412cd615b2bc7ee54",
".git/objects/8e/a12ea2c7bf000d9d1470361905d7e29062bfed": "4e8e9d6a40cc89583fb5992c4652c084",
".git/objects/25/dcad6c08f5cbd2cb4c46c7128bce7ccb2fb8b7": "6ad684901b4757ff494aa7a06fafd46d",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "395eb21bc92061eead9313db75da329a",
".git/logs/refs/heads/gh-pages": "c6bafee6c5d134bdae9a8440ad7092bc",
".git/logs/refs/remotes/origin/gh-pages": "61c2cb2c7de71fb6060681a3f30ab339",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
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
".git/refs/heads/gh-pages": "51873a7cf9c042ad4968750a56a5bfb2",
".git/refs/remotes/origin/gh-pages": "51873a7cf9c042ad4968750a56a5bfb2",
".git/index": "360f8a6ab03ed1764cca18a8c8035e6c",
".git/COMMIT_EDITMSG": "b83c9b4087c6e4553cbb622d3a9bac7d",
"assets/AssetManifest.json": "ad815a51bef57f3771cb02e58f1c34e9",
"assets/NOTICES": "ea6d760eecd69256ed0d11dde6cbb843",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "b83c023d4daa6d72a64aa604fcf168db",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "9673714103c7da2d92426853c66bed1f",
"assets/fonts/MaterialIcons-Regular.otf": "f4768660b9763ab6444be399f3f92d04",
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
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b"};
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
