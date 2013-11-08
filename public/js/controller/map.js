define(function(require) {

    var leaflet = require('leaflet');
    var Marker = require('lib/leaflet/highlightMarker');
    var eventBus = require('vendor/pubsub');

    require('leaflet.markercluster');
    require('leaflet.hash');
    require('leaflet.minimap');

    var $ = require('jquery');

    var TONER_TILES = 'http://{s}.tile.stamen.com/toner-background/{z}/{x}/{y}.png';

    var Map = function(selector, options) {
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
        this.mapElement = $(selector).get(0);

        this.map = leaflet.map(this.mapElement, $.extend({}, defaultOptions, options));

        this.minimap().addTo(this.map);
        this.tiles().addTo(this.map);
        this.hash = new leaflet.Hash(this.map);

        this.clusterGroup = null;
        this.markerHash = {};
        this.highlightMarker = null;

        var self = this;
        eventBus.subscribe('user-locate', function(method, name) {
            self.mapElement.scrollIntoView();
            self.highlight(name);
        });

        this.setHighlight = function(marker) {
            if (this.highlightMarker) {
                this.highlightMarker.unhighlight();
            }
            this.highlightMarker = marker;
        }
    };

    Map.prototype.addPoints = function(markers) {
        var icon = this.getIcon();
        var map = this;
        var markerList = markers.map(function(dat) {
            var popup = '<strong>' + dat.get('name') + '</strong><br />' + dat.get('place');
            var options = { autoPan: false };

            var marker = new Marker(
                [dat.get('latitude'), dat.get('longitude')],
                {
                    title: dat.get('name') + " - " + dat.get('place'),
                    icon: icon
                }
            ).bindPopup(popup, options);

            map.markerHash[dat.get('name')] = marker;

            return marker;
        });

        this.clusterGroup = new leaflet.MarkerClusterGroup({
            showCoverageOnHover: false,
            maxClusterRadius: 41
        });
        this.clusterGroup.addLayers(markerList);

        this.map.addLayer(this.clusterGroup);
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

    Map.prototype.highlight = function(key) {
        var newMarker = this.markerHash[key];
        if ( ! newMarker) {
            return false;
        }
        this.setHighlight(newMarker);

        this.clusterGroup.zoomToShowLayer(newMarker, function(){
            newMarker.highlight();
            newMarker.openPopup();
        });
    };

    Map.prototype.minimap = function() {
        var layer = new leaflet.TileLayer(TONER_TILES, {minZoom: 0, maxZoom: 2});

        return new leaflet.Control.MiniMap(layer, {
            height: 80,
            width: 170,
            autoToggleDisplay: true
        });
    };

    Map.prototype.tiles = function() {
        return leaflet.tileLayer(TONER_TILES, {
            attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://creativecommons.org/licenses/by-sa/3.0">CC BY SA</a>.'
        });
    };

    return Map;
});