function printNotification() {
    var content =   '<div class=\"map-notification\">' +
                        '<h2 class=\"map-notification-title\">' +
                          'Copilul dumneavoastră a interacționat cu un copil periculos!' +
                        '</h2>' +
                        '<p class=\"map-notification-info\">Adresa: Strada Palat nr. 3, Iași</p>' +
                        '<p class=\"map-notification-info\">Cod poștal: 700259</p>' +
                        '<p class=\"map-notification-info\">' +
                          'Ora: ' + (new Date()).getHours() + ":" + (new Date()).getMinutes() +
                        '</p>' +
                    '</div>';
    showPopUp(content);
}

function testNotification(){
    setTimeout(function(){
        printNotification();
    },3000);
}

var map = new ol.Map({
    target: 'map',
    layers: [
      new ol.layer.Tile({
        source: new ol.source.OSM()
      })
    ],
    view: new ol.View({
      center: ol.proj.fromLonLat([27.6, 47.15]),
      zoom: 13
    })
  });