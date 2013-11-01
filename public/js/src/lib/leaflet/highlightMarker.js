define(function(define) {
    var leaflet = require('leaflet');
    var ICON_CLASS = 'highlighted';

    return leaflet.Marker.extend({
        highlight: function() {
            if (this._icon) {
                leaflet.DomUtil.addClass(this._icon, ICON_CLASS);
            }
            return this;
        },
        unhighlight: function() {
            if (this._icon) {
                leaflet.DomUtil.removeClass(this._icon, ICON_CLASS);
            }
            return this;
        }
    });
});