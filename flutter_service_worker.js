'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "418a607f77ea2f341187412ab5212429",
"version.json": "ecdf215c2c8254c024d3b10eefead19f",
"index.html": "0a6c9a499327c11d3000a2b362040176",
"/": "0a6c9a499327c11d3000a2b362040176",
"main.dart.js": "d5b9f0dbcd892c909f126cb38b2a9e94",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "39cefc6fe4af3c508365d8670947372d",
"main.dart.mjs": "a469df4c583d19706cc747c2dd4b7f9d",
"icons/Icon-192.png": "39cefc6fe4af3c508365d8670947372d",
"icons/Icon-maskable-192.png": "a15cb5fe5d824f9adc2e33b7c70e6550",
"icons/Icon-maskable-512.png": "49d869b9b4b6e099a9509416db96c25b",
"icons/Icon-512.png": "39cefc6fe4af3c508365d8670947372d",
"coi-serviceworker.js": "12cf3e8ef3deac5151098b970f08e763",
"manifest.json": "8a0cca5366bf447f036e22977c708970",
"main.dart.wasm": "cad876d302bfdbeeb0c834690e5d3419",
".git/config": "0a8ae2f66751282ae6cd6a886c459673",
".git/objects/61/1f19507418a50dfda731353be62f2e4d6a632c": "f6e553e84462a8d36f96423b8493f7b0",
".git/objects/95/c21fd7c08b0550e2fd83aeb96a4372f8df4caf": "3415f873b3343fabe6eab8660659d9c9",
".git/objects/95/a3ab24e04940cd4c9ed11b879979cfbd2050b3": "34df471db626a30bac29a8fe11652b20",
".git/objects/59/cb9ef4c5e29a34ca489803faeefffcd8f8ec44": "0e6f65a8325b8fd9803945ea4efadba3",
".git/objects/92/6a038ae71d8216b6e1de936c2246f5c9d7776e": "93e841e45f89a83920630394c2d0d113",
".git/objects/92/fd570a6c1e2197b8adbdaea325d6ee8c49580f": "5b95a54f7255aa08b0012ee243f08cec",
".git/objects/0c/1b1d21339652459fd420c7a61e7e9e9893d512": "7b1accf564a5134c8e73dd451dd5c2cd",
".git/objects/0c/309591bdbd94aaa93ab53ea91bbc2a8a0eb430": "e3db0f12e0d83e354124dd0ba42b1a5d",
".git/objects/3e/58b69b203a80fa55156ab21a733aa93f7acc73": "6fdf8aaf71c99adbd2f83bc61043393e",
".git/objects/3e/d91fce3d14aa048ff084dafeab91ab3aee6091": "c0cc825251942ae475fead6e316a1701",
".git/objects/50/08ddfcf53c02e82d7eee2e57c38e5672ef89f6": "d18c553584a7393b594e374cfe29b727",
".git/objects/50/42549dbd78d18a5c6fc5b1aaa611a03800911f": "7d2ab384d6173a99ee935ac5b4a1974c",
".git/objects/68/43fddc6aef172d5576ecce56160b1c73bc0f85": "2a91c358adf65703ab820ee54e7aff37",
".git/objects/57/d085d57cd40b617f99eab88c15c021ca975a45": "711ed86a1eb227a45e1e06a6170c8ef6",
".git/objects/3b/1e055cfe68ee01e027a46897aefac66ee8f42b": "7cdb96ea9ac26bbce7e256ea8bffb56d",
".git/objects/6f/2c68addbae8b90f4c26903c4be62cd04630cf7": "f148a51537a14e46596b98791a837f9f",
".git/objects/6f/7661bc79baa113f478e9a717e0c4959a3f3d27": "985be3a6935e9d31febd5205a9e04c4e",
".git/objects/6f/3ca4fe805b79e1ccc27edb99ae45e22ab8c6ee": "e0b14eb83fc607090a09c5a9f9e5ec36",
".git/objects/6a/be2c9e4fb9c5078267534081e3b063305b820b": "ed3d34e00dbe6bbe572ba9bd11ed19cc",
".git/objects/32/399f156251d4b55a122a0247e6ca8c397d22c0": "1705ef9b5f53e208b865889a49193f0c",
".git/objects/32/7bbab29ae2539739861a007bdcdd4f2184b59c": "29b2c29598d3ccfc2940da2a5002926e",
".git/objects/69/dab5947b7e62fd718af7b5e2faa94139fc7e00": "41796446fd8da737b67350a1563f1299",
".git/objects/69/b2023ef3b84225f16fdd15ba36b2b5fc3cee43": "6ccef18e05a49674444167a08de6e407",
".git/objects/3c/a4b702944f5594c375eae7c501db8d869d01b5": "81cff8d391ee641f3d5c90afde5bbf29",
".git/objects/56/ca7338f4f1130a9f50e746ac9fbc0ebfb0d43e": "e828b6e8447a13efc40eff7f5ea33470",
".git/objects/51/03e757c71f2abfd2269054a790f775ec61ffa4": "d437b77e41df8fcc0c0e99f143adc093",
".git/objects/67/8618c38c10d16e556cce7c62de9cab107148b9": "b5e1c0a1aaf52b1d5361f5eb8866a1a2",
".git/objects/93/b363f37b4951e6c5b9e1932ed169c9928b1e90": "c8d74fb3083c0dc39be8cff78a1d4dd5",
".git/objects/0e/4eb7938a3ec8a9821c451bb2fdd50c4b227bfe": "93b7651c1edf95f21d36ff98e89bc12f",
".git/objects/60/059b3e7b37866629b5fe016c174a9737852d1e": "d6a8a9a347bcfa599ebd163db24f980a",
".git/objects/60/5300e8e749fb9315f5fcd9ac19806dddb1ea68": "1c8be219d5f261083d4943e8975fc04a",
".git/objects/34/8c56670f5d922ef043efce1abdd61ac13481da": "619c89af8eb69db5b8001461ed3510fc",
".git/objects/5a/b7562fa21e47da12313ec3753e4fdc44e9302a": "bd4aadb6b6e0fa95077eacd8cc59c0a9",
".git/objects/33/f869e561d33a62e3137ada0c19ec69d6ab2849": "c344140f1b82e399f32b4ab4233885b2",
".git/objects/02/7d6bd88e8884ec433754fab4e0fed4c23bc241": "f7b7880d64b8c962a95878572f7a8474",
".git/objects/02/411393e50a94c9eaf3696beebe5a8beceaf93b": "76f22a4fe2f9dd7adbd2155d5c530750",
".git/objects/b5/968673919d3ccd8819a0196b200737860cf279": "3f1bd28f00a159d905c78dc935d0cf24",
".git/objects/b5/fb7aa1851765a9c54364ed230671cec20a9259": "f735c10466545e8f1358b0c466830c59",
".git/objects/d9/5b1d3499b3b3d3989fa2a461151ba2abd92a07": "a072a09ac2efe43c8d49b7356317e52e",
".git/objects/ad/ace8df502cea5f5584a3af1cec373753be7d87": "9fa00c958acc8f10c2a0cf3cdf8f6b6b",
".git/objects/ad/ced61befd6b9d30829511317b07b72e66918a1": "37e7fcca73f0b6930673b256fac467ae",
".git/objects/bb/1f5f90c0b018f055d29095f7b1ed4352c2c79a": "cd5f533045d825470050ba92f126b886",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/d0/abd5c79350ad79965c0d19811295c8f83bf13e": "7f840832353a5e8afd102d4e981fc3a7",
".git/objects/df/a2a266087d2d58bdd5705b4c4abd3879cfaff9": "b8a0380403789cb895993ac5d9ed025c",
".git/objects/da/9cc682868f646f058e0c51b1a37efb65d0b6c1": "bee77d43058e7dad06485f7e43087a6e",
".git/objects/da/ace2fec9b566eba5db9b5abdd4b7ffd7715f2b": "482b715d6b67bc53989830d21afd2f39",
".git/objects/da/788e1035f2f2702076d92f9fa43b2022d1cfd4": "6e81509ebba0412c0d9f528d753d9d0c",
".git/objects/a2/61a9de58a24fcfa7f50309ed56d9f167936b17": "5223412931e5dad72288fe86c728f12c",
".git/objects/d6/0d4a827920b7c13ca7d63d392108f8d3928512": "cb3955614863c313aefa9e73a939505b",
".git/objects/d6/c96a9d5befa47bfc4b5de10108822248143c97": "fd63edaedce9a994324bb3608a785f96",
".git/objects/ae/c84fddeb15305a9b69470e3ab8900ce10add6a": "990c4842344ae710490d15982b02d6fa",
".git/objects/e2/4c7e76a48956ae48f5fede4f36fe36149e95ea": "901ca2c38bd79e589301e056e640e789",
".git/objects/e2/048264503df6e787036993583eb6cd024d40fb": "cf060d91e44b23fda201cefa968fc9de",
".git/objects/f3/3e0726c3581f96c51f862cf61120af36599a32": "afcaefd94c5f13d3da610e0defa27e50",
".git/objects/eb/7f0f91c171bb33c03e8c90b59f97b0d3a13681": "a3172cc58b7e50ff8da08eff752f6eca",
".git/objects/eb/d433dab3e0819ab0854a7a3e917ba26237917f": "6bd196e9fea894029e2076092c603b35",
".git/objects/c7/85c84c83295a2c19a0ff31048ec3feeb804343": "088d4ad6950efafcebb4445c03953d93",
".git/objects/ee/5d7d73a7dba4747e6e7c0d25973d67ed5fafa0": "04a1a9d416b97bc7e74bf5da5153a30f",
".git/objects/fd/05cfbc927a4fedcbe4d6d4b62e2c1ed8918f26": "5675c69555d005a1a244cc8ba90a402c",
".git/objects/fd/a432cb78fe4f1b655a3baeb177d9d7a77df48b": "c0fae1ed9259dfaa506f9a11267dc03f",
".git/objects/fd/a32217eaec1a1e682c6b39be08c67639b0c4da": "f48712acea582987d137999a883e4eb9",
".git/objects/fd/ec2ae44aceca68f32c5ca61fb118dcb780c9a7": "89c4602231f852fc1face7f2b4486bde",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f5/7206ab8ede37ec47344904e0e2f1c071e77f3a": "b7e427d2f6a12e39d83707a4e152cc36",
".git/objects/e3/45c3e2af27847d6ac7712b5d552149492782a8": "0c4b72f0e074957510b299b06f80b37e",
".git/objects/e4/460f57f1e19fb64af6607025f4f301198fbdfe": "656e7f66a6a5b917d246aa599c7a0ad4",
".git/objects/c8/3af99da428c63c1f82efdcd11c8d5297bddb04": "144ef6d9a8ff9a753d6e3b9573d5242f",
".git/objects/fb/162b3b914bfc2ed4d97b576e65f848d9de0cd2": "b16102f7ffc1b6a566cbc3ff186987a4",
".git/objects/ed/2bc0ff3d006f9021ef9f98a9f16dc5f85b5fc8": "1b897f97dbba7a032f9b785e25c53746",
".git/objects/18/447156a46dd418fb8bb282b9d4ffc13df630dd": "c3179debf0a4c47a50d5989d211269af",
".git/objects/4b/04c8fd48cde58161746497624dee2001b406d8": "20515bb1a79501ec661c83a7c33775a8",
".git/objects/11/559d58aac223b602886b33331c1a07da466218": "a92f4378a64a5488b6afa80c7f95142d",
".git/objects/7d/a23db19cf22839c77acea5f8ef4503ad22a3ce": "121b54339eef3fe3044218ba1ee0ee7c",
".git/objects/7d/99ff5749afa0651de1d9e5fe25aafd9e05c151": "f8eaa655a2d655c179efd337cc6c7143",
".git/objects/29/cef45f4d2a143160f09191519d72243f67edfb": "9594593a928741ba19a4ea2d39c0ad3e",
".git/objects/7c/3463b788d022128d17b29072564326f1fd8819": "37fee507a59e935fc85169a822943ba2",
".git/objects/16/2d4d2b88d1b13be8cd1d883c8fcc32022154ab": "b71fc6467b45c5189fa81631cff3b3c7",
".git/objects/73/4c544f660f5adc337535d6719aa1023edabf00": "b059c86024e9b13d017dfc13c0805693",
".git/objects/87/d6a6c7b8e847ed8839d29c8b11439c5b5a9285": "137f7538da6790477901e04038e30400",
".git/objects/17/6a6178f220f27fa7be4757190b412003558295": "fe759cbe566b30cba7f660aadf3e6ede",
".git/objects/4d/ed612e3831df0b2574aa33e3c38427e3f332b9": "a00b48772cc373c0dde3136077572d0c",
".git/objects/81/4d72c5969a31e6ebda8e374d4b4be60313075f": "22b738d35dfb59e5a6bbade9ca381f0c",
".git/objects/86/d7d6fb8f8881c1e0d25dc7fb442b41189e4952": "2190a036cd47bffd3b0cd462f0649855",
".git/objects/2a/a86093324a173b17b68485f31e18212d7261e0": "14cef8045bae4b1bf9249dd8d35d8132",
".git/objects/43/15c4fdbafbd504412f618a8146a82cd7555d9e": "d3c35a6b51f39c0e9ae564de864a3676",
".git/objects/6b/1eb46c91c7b42ec9b3a029f57262aadeb60e44": "03308940f946b5a52b0120ac4ca50531",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/07/3aa32c2c86313c215e764294115ed66f14acf3": "9936a1dc7b10aeca8de570e8c2d20059",
".git/objects/38/d02b9205847ffc78206b7ba42cddddb3041af9": "189a829b1c33ba178a1f1f9c22747d40",
".git/objects/6e/4220168e81a5204206b827a4f90a01a488ba6e": "9a5a6b7034bce5de10d0dd477a5a396d",
".git/objects/36/875cd397c34cfc7cf32f7d7ee6058b8fe740a2": "4a45c92cbec85f14337b610df980fb76",
".git/objects/36/fa99602e30961b2ec1d56a59fc50079f675427": "0b39399c36d871832afbdfd580799030",
".git/objects/36/f9d6dc1760ea049a896fed0aa176e022faa59e": "67c7237c26e7c4c659a37da2a73ee708",
".git/objects/5c/4c514abfe970357157dc67ffa2c11f711f5af5": "af38ac2a01b16a7c2352413f45523414",
".git/objects/5c/a694f232fdbb06e3a021101e78f1950288504f": "3e0ddd3202dae2077398e896c8d80fa1",
".git/objects/5d/52d0e7bf75f9496932033f143807d64a0cfb40": "d33407b4f7ba6c04c37f2b2bb0b37a27",
".git/objects/91/64e620ad2eb1a32c656b27afad59f352dd5015": "c924dd87f36f24772d01c80ba7d63344",
".git/objects/62/fd3591cda9fcb036ed60a801c57f59c9b765ab": "2a9494bb0474057dd51ee1744155da28",
".git/objects/96/58ea4c80a57df9657761b68e6b94da15787502": "49dc7d14554dd61f6fd5e91672e7f765",
".git/objects/96/20c271219b0f21f06cf51c04b4cc3c989dff69": "ebb49bafd8c2f24aab3009dcf8894b6f",
".git/objects/3a/8cda5335b4b2a108123194b84df133bac91b23": "1636ee51263ed072c69e4e3b8d14f339",
".git/objects/54/b4a4796974dc37a26a6f69934d5947e7b588ac": "2e28f25c52b94e7542c2bad21ecbc493",
".git/objects/98/a61d0b6c6aee36f083769d9610a0d7f48b3994": "c1369d94962400a1036af89b3763e39c",
".git/objects/5e/b6268da5177422a6b6d2de9906e6fd8fe0ab38": "346336b5a8444a96ad140963828ff066",
".git/objects/5e/a34dbd567533bfb3ef98fa85d8228c406f6e29": "2fa4614f3b3c82e7407a40eb84152954",
".git/objects/5b/7c4d676d0c13987add9d878264b60c4d892483": "e09b7fdcf998dacaa85af74c35153987",
".git/objects/5b/a8aa3fcc8ef395fb37fb703932bb0c21e765b6": "52baef44fda2bcaf29796d17122f378e",
".git/objects/08/27c17254fd3959af211aaf91a82d3b9a804c2f": "360dc8df65dabbf4e7f858711c46cc09",
".git/objects/06/77b29eb3bdf40196f3215b243d84cc0db48c29": "1d1f04556378f953898014629a4eb6d1",
".git/objects/06/fbf9a11412d5b3dd59339f368420949be0c593": "72aba801b64c5122e3754aa19ec421af",
".git/objects/99/24059043297799dd4fc043d4eeb38ac66cc48d": "974360cdcf6123d3cff39fa0280a25d7",
".git/objects/99/003709f71b5871b9a8a3bb9e52cf76df69c8cf": "25279c1bd3f9edd0ec6fd9df24ea5236",
".git/objects/52/a94e8fe6d7b15ff199e3950a406d3afaa96ff2": "82be9222ad561b923565c300f83f06e6",
".git/objects/52/6dc17239e4187a54d05369e3ff866f10135263": "27dc6532e676cc70022fab6736bca32e",
".git/objects/64/8ec805bfa506ed4c36fe533bd7831c430ecb33": "8a3a82871000aba8465caa04cbb2026b",
".git/objects/64/02ea9682053272fb8cac8e4caf388e817febc8": "703a676a10dda5cbed27ea4cc2b3738c",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d4/ff6709731bfaff7f17628cb126f997c3e08c45": "86d1472a01eccfb1ec7f8eaf12fac409",
".git/objects/d4/c7b7a86b04fb0a9355dd5a1e7048ea7140d3e9": "79ad3e70f6c6d9ba4e8f939a9f3539f3",
".git/objects/b1/f85883d4722ca1d1b8c52c6422e3f849b78e13": "55a556f30048b390c40ae65ba54aeb3e",
".git/objects/b1/719fc5698b839460512c74a5046ffe35ecf24e": "2082ad6516935847b1ef97107614a9a2",
".git/objects/b1/45fdbd86e67b1d93b0aa1f37370b927cdeac84": "4cfa10fe710163708d3b5d928c92688f",
".git/objects/dd/470cfbd8214b6454248561c884a6860e458ad8": "ca0b3eec386b0aeba5d53a98e1f18262",
".git/objects/a9/86f1b431806fc81432f3489c963e37a5b7363f": "2eeec4a77bd01c4af114ecac8f3f1ac6",
".git/objects/d5/179f461c1ce6fe076ea11e2b5e465add9b55de": "6b92c170f2104eb49d12fb35c041f4f3",
".git/objects/d5/85eac21bec2fedf562f6a7ae0c7321b900a991": "7001bcb00aa0ec32db6e9bfc2938a6a4",
".git/objects/aa/05122927d0477ca4257ee8af0650750fb58528": "2bc604e98eacffb03f63f4b36a2848c6",
".git/objects/b7/c4844d88b91924bbff473c06e4032691a92198": "7e16ce4cbe69f553582004f58000b0f4",
".git/objects/db/ad69ee5ce3f86696a8571b8a76b0d7cdc39af3": "fee7f5ad921fa41458f5356b23e287df",
".git/objects/de/4de74d29634eddfe2261ddb52e098935a781fe": "83d06ac108c81bf499bdf1045c8b5cc3",
".git/objects/b0/d16ad027db56108630b3b91ea7ed66e14b938a": "c73a542b97ea439f2ecac744e4ac1513",
".git/objects/b0/2859eab4820661267f5cefbfbcd185d9899e3d": "71ae62e8e569e3056654818e05103945",
".git/objects/b0/fb523806c6ec09b92dd6e56b145e3df07ca132": "ef96ff86a7b337b307752313450cb808",
".git/objects/b9/3e39bd49dfaf9e225bb598cd9644f833badd9a": "666b0d595ebbcc37f0c7b61220c18864",
".git/objects/a1/4e0e9e66bab821e0e911db6bcda1318da560cc": "735e1626d3831a05005b8da2962b678a",
".git/objects/cc/e88bdc860a54a2f3f8dfdeab16bf4fec578504": "4be03bede78020b190127730a6e767b2",
".git/objects/e6/8cd1092afd3396f205d21807d20044fb2a9e43": "02e0ec147e36edb7c087d9c04c019b6a",
".git/objects/e6/eb8f689cbc9febb5a913856382d297dae0d383": "466fce65fb82283da16cdd7c93059ff3",
".git/objects/e6/9de29bb2d1d6434b8b29ae775ad8c2e48c5391": "c70c34cbeefd40e7c0149b7a0c2c64c2",
".git/objects/f0/1c87c5fa42e7546399b8f557d8a69dc9cc1cc4": "1539df8f93378395cd89b749034c6741",
".git/objects/f7/61aa61b403f8ac9b7e8cc9c46843d27b360594": "0d2f5fbe04a844eface7b2199ee95d51",
".git/objects/e8/7917edadbc1deef98d0f442d9ac1f4b543d93b": "40feda56b6f84a9820eb7889436cd378",
".git/objects/ff/a80326039c7f2787ff01d80a150474f3fab3b0": "071b9ca64d1fccb908eba30365e7a562",
".git/objects/c2/af51af23802c4c0c3c8f3f7c6422b515b7de18": "278947f2dda2f32b4678c994271c344c",
".git/objects/c2/178cfea2c5902e7a69edd6fcbdabad1d62981c": "1e27134f54735a971214b943ccc93076",
".git/objects/f6/00011751d8c8674b97c12d10a30f15db36fe6b": "fa0ae3401517b727e6c56fd04d270c3c",
".git/objects/f6/e6c75d6f1151eeb165a90f04b4d99effa41e83": "95ea83d65d44e4c524c6d51286406ac8",
".git/objects/e9/a8430db138aef8678ce2ba824b24c91c4b3264": "5c37be73d5d77c5e05516a50f0433b50",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/e9/c4e17c639240fe1c7dbfc49482803465bc2483": "09c9f24213043c4a31fd0f3b7adbe350",
".git/objects/cb/eaab1b42e9da1a1916f6ea03a395023ed23065": "8db5cc61467b66d1f390f38fc981b888",
".git/objects/cb/5ab4a31f7dd7c0df7383466c549bef2dfbe76f": "30defa0bbfbd344e0c19b4b506ba36d4",
".git/objects/ce/fe57574ea5317fc81ad083318d4c77c07d9d6a": "3af250d0b48e0f15bf14e10b9fc69093",
".git/objects/e0/e5fc90b3c0ce2a68c12a3cd4e58d437fc6415b": "13358a3b905fcbc3352310864b30d6d0",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/2c/71dde801a9f00a6bc9d4c550f1dcaa71c280b7": "0881e81cf70f275930b6c0d4f875fe05",
".git/objects/2d/0b602915d2b08f71d36813590b0b23d267de67": "1ae144a05f6ec0ba6c0c9c728c1f36c3",
".git/objects/83/6710a0814b5d388139672d72269eb9c4e1b9a0": "14eb85dc7e2d0a7c90b9bfdc4ea7d099",
".git/objects/48/82893d0ccfa660fcbaf588c42d2022af3d6807": "9c9b7834c972a80de99551756fe306f2",
".git/objects/24/2481fd52125f799dea800e98b170175e1663fe": "3afac39a71274424cdc5650d5d562a81",
".git/objects/8d/eb0f1d5e18af76543f9e84e09b02d1321ce6a8": "46777d2cdfdd0a4f287aead82f451e2a",
".git/objects/8d/ada5a860b34a6696dade72b4f0ba505503f06b": "7a6f78acbc89d165123f2a3f29e3fd4e",
".git/objects/85/948b9e8600dfd9310bee2ae124437892a0cee6": "d12676213a1ada23877c190988d1da29",
".git/objects/85/63aed2175379d2e75ec05ec0373a302730b6ad": "997f96db42b2dde7c208b10d023a5a8e",
".git/objects/1d/39626da7e743216d22ceac39b55e1cff878a89": "74117fc9d23d1c6389eb40c27d358957",
".git/objects/71/f0405ef4953c28b69bf06bacd5ecb7025f9cb7": "697249a022cb8276b6826ff3136e8fd4",
".git/objects/1c/1dced01ac14926c137a8797af228f43fc189f9": "bc4dbb21c0517ed9277dbe7f2ccbd391",
".git/objects/82/e736565b7db3c6621331dd9445f7ec48d6c678": "72a48251d6ef6084b47f0758d2681cad",
".git/objects/82/1ccf46553e4b3637ce302389c880fd46fa2920": "bbf950b0308ce29543423bd02520c722",
".git/objects/49/4765c02335ce8a9175b431491cbbe9477b2409": "31b2b40df8b91b6bc7b70ab0a28dc643",
".git/objects/2b/70063f313e01662b890cf91c656acdbdc4c779": "53ecd93c3dcd7cea205b47a68559a48e",
".git/objects/8b/b8af3c18e355bac2567d50c59d0920988c058e": "1b4a7a150949870d473d283887b93730",
".git/objects/13/47b0df99b6b7cd4a795118e6c8ff7443b9ffc7": "907a3f6379b4b8a3a874e2c350832692",
".git/objects/7a/4e906ff95df59c332cead2190fc20109e876e3": "ed439f2371a3166412cd615b2bc7ee54",
".git/objects/8e/a12ea2c7bf000d9d1470361905d7e29062bfed": "4e8e9d6a40cc89583fb5992c4652c084",
".git/objects/25/dcad6c08f5cbd2cb4c46c7128bce7ccb2fb8b7": "6ad684901b4757ff494aa7a06fafd46d",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "c738f35236f22521300e416209b37f46",
".git/logs/refs/heads/gh-pages": "adfa2ff262d81d3ec667be63fb53af43",
".git/logs/refs/remotes/origin/gh-pages": "f1b83558d0aa30935de0421dac547df5",
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
".git/refs/heads/gh-pages": "c24724fa0588cf7517b03b6ce5454d4d",
".git/refs/remotes/origin/gh-pages": "c24724fa0588cf7517b03b6ce5454d4d",
".git/index": "c7925396b607dfc479c310c5a1a974b0",
".git/COMMIT_EDITMSG": "9a6557796ef00e1c1fffdb297b754b3f",
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
