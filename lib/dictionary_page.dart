import 'package:flutter/material.dart';

class DictionaryPage extends StatelessWidget {
  const DictionaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phrase Dictionary'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search dictionary...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                DictionaryItem('Kamusta', 'Hello'),
                DictionaryItem('Salamat', 'Thank you'),
                DictionaryItem('Gihigugma tika', 'I love you'),
                DictionaryItem('Maayong buntag', 'Good morning'),
                DictionaryItem('Asa ka gikan?', 'Where are you from?'),
                DictionaryItem('Kumusta ka?', 'Kamusta ka?'),
                DictionaryItem('Unsa imong ngalan?', 'Ano ang pangalan mo?'),
                DictionaryItem('Ako si Juan.', 'Ako si Juan.'),
                DictionaryItem('Nalipay ko nga nakaila ko nimo.', 'Masaya akong makilala ka.'),
                DictionaryItem(
                  'Maayong adlaw! Ako si Cat, usa ka estudyante nga gikan sa lungsod sa Laguna. Naga-eskwela ko karon sa usa ka unibersidad sa Cabuyao ug nagtuon ko og Information Technology. Apan dili lang kutob sa classroom ang akong pagkat-on, kay ganahan ko mo-apil sa mga aktibidad sa eskwelahan aron mahasa pa ang akong abilidad sa pakig-istorya ug pagpanguna.',
                  'Magandang araw! Ako si Cat, isang estudyante na galing sa lungsod ng Laguna. Kasalukuyan akong nag-aaral sa isang unibersidad sa Cabuyao at kumukuha ng kursong Information Technology. Ngunit hindi lamang sa loob ng silid-aralan ang aking pagkatuto, dahil mahilig din akong sumali sa mga aktibidad sa paaralan upang mahasa pa ang aking kakayahan sa pakikipag-usap at pamumuno.'
                ),
                DictionaryItem(
                  'Pasensya na, pero pwede ko mangutana kung asa ang pinakadool nga terminal sa jeep? Naa ko sa lugar nga wala pa ko kasuway ug adto, ug medyo naglibog ko kung asa ang paingon padulong sa sentro sa siyudad. Gisulti sa akoang higala nga kinahanglan ko mosakay og jeep nga motuyok sa downtown area, apan wala ko kabalo asa dapit ang sakayan. Tabangi unta ko nimo.',
                  'Pasensya na, pero maaari ba akong magtanong kung saan ang pinakamalapit na terminal ng jeep? Nasa lugar ako na hindi ko pa napupuntahan, at medyo nalilito ako kung saan ang daan papunta sa sentro ng siyudad. Sinabi ng kaibigan ko na kailangan kong sumakay ng jeep na umiikot sa downtown area, ngunit hindi ko alam kung saan ang sakayan. Sana matulungan mo ako.'
                ),
                DictionaryItem(
                  'Pasayloa ko kung nakasamok ko nimo karon, pero nangayo lang unta ko og gamay nga tabang. Naa koy assignment sa programming nga lisod sabton, ug akong gusto unta nga i-review lang nimo gamay kung unsa akong nasabtan. Dili ko ganahan nga kopyahon ra ang imong gibuhat, gusto lang ko nga makasabot sa proseso. Salamat kaayo kung makahatag ka og gamay nga oras.',
                  'Patawad kung nakakaistorbo ako sa iyo ngayon, pero humihingi lang sana ako ng kaunting tulong. Mayroon akong assignment sa programming na mahirap intindihin, at nais ko sanang ipareview sa’yo kahit konti kung tama ang pagkakaintindi ko. Ayoko namang kopyahin lang ang ginawa mo, gusto ko lang talaga maintindihan ang proseso. Maraming salamat kung makakapagbigay ka ng kaunting oras.'
                ),


              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DictionaryItem extends StatelessWidget {
  final String bisaya;
  final String english;

  const DictionaryItem(this.bisaya, this.english, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(bisaya),
        subtitle: Text(english),
        trailing: Icon(Icons.volume_up),
        onTap: () {
          // Handle pronunciation
        },
      ),
    );
  }
}
