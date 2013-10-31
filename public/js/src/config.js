require.config({
    paths: {
        'jquery': 'vendor/jquery-1.10.2',
        'leaflet': 'vendor/leaflet/leaflet-custom-src',
        'leaflet.markercluster': 'vendor/leaflet/leaflet.markercluster',
        'leaflet.hash': 'vendor/leaflet/leaflet-hash',
        'jquery.dataTables': 'vendor/datatables/jquery.dataTables.min',
        'dataTables.foundation': 'vendor/datatables/dataTables.foundation',
        'foundation': 'vendor/foundation.min'
    },
    shim: {
        'jquery': { exports: '$' },
        'leaflet.markercluster': {
            exports: 'L.MarkerClusterGroup',
            deps: ['leaflet']
        },
        'leaflet.hash': {
            exports: 'L.Hash',
            deps: ['leaflet']
        }
    }
});