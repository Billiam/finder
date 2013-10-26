(function() {
$(function() {
    var map = L.map('map', {
        attributionControl: false,
        center: [10, -15],
        zoom: 2,
        minZoom: 1,
        maxZoom: 12
    });

    L.tileLayer('http://{s}.tile.stamen.com/toner-background/{z}/{x}/{y}.png', {
        attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://creativecommons.org/licenses/by-sa/3.0">CC BY SA</a>.'
    }).addTo(map);

    //export for debugging
    window.map = map;
});
})();