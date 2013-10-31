define(function(require) {

    var leaflet = require('leaflet');
    require('leaflet.markercluster');
    var $ = require('jquery');

    var Map = function(selector, options) {
        var map = null;
        var icon = null;

        this.init(selector, options);
    };

    var defaultOptions = {
        attributionControl: false,
        center: [10, -15],
        zoom: 2,
        minZoom: 1,
        maxZoom: 11,
        worldCopyJump: true,
        inertiaMaxSpeed: 1000
    };

    Map.prototype.init = function(selector, options) {
        this.map = leaflet.map(selector, $.extend({}, defaultOptions, options));
        this.tiles().addTo(this.map);
    };

    Map.prototype.addPoints = function(markers) {
        var icon = this.getIcon();

        var markerList = markers.map(function(dat) {
            var popup = '<strong>' + dat.get('name') + '</strong><br />' + dat.get('place');

            return leaflet.marker(
                [dat.get('latitude'), dat.get('longitude')],
                {
                    title: dat.get('name') + " - " + dat.get('place'),
                    icon: icon
                }
            ).bindPopup(popup);
        });

        var group = new leaflet.MarkerClusterGroup({
            showCoverageOnHover: false,
            maxClusterRadius: 41
        });
        group.addLayers(markerList);

        this.map.addLayer(group);
    };

    Map.prototype.getIcon = function() {
        if ( ! this.icon) {
            this.icon = leaflet.divIcon({
                className: 'point-icon',
                iconSize: [18, 18],
                html: '<div></div>'
            });
        }
        return this.icon;
    };

    Map.prototype.tiles = function() {
        return leaflet.tileLayer('http://{s}.tile.stamen.com/toner-background/{z}/{x}/{y}.png', {
            attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://creativecommons.org/licenses/by-sa/3.0">CC BY SA</a>.'
        });
    };

    return Map;
});