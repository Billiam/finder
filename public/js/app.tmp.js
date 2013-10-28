(function() {
$(function() {
    var map = L.map('map', {
        attributionControl: false,
        center: [10, -15],
        zoom: 2,
        minZoom: 1,
        maxZoom: 12,
        worldCopyJump: true,
        inertiaMaxSpeed: 1000
    });

    L.tileLayer('http://{s}.tile.stamen.com/toner-background/{z}/{x}/{y}.png', {
        attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://creativecommons.org/licenses/by-sa/3.0">CC BY SA</a>.'
    }).addTo(map);

    var simpleIcon = L.divIcon({className: 'point-icon', iconSize: [16, 16]});

    // Marker layer
    var markers = new L.MarkerClusterGroup({
        showCoverageOnHover: false,
        maxClusterRadius: 60
    });

    var markerList = $.map(point_data, function(dat, i) {
        return L.marker([dat.lat, dat.long], {title: dat.name + " - " + dat.location, icon: simpleIcon});
    });
    markers.addLayers(markerList);
    map.addLayer(markers);

    //export for debugging
    window.map = map;
});
})();