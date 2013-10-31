require.config({
    paths: {
        'jquery': 'vendor/jquery-1.10.2',
        'leaflet': 'vendor/leaflet/leaflet',
        'leaflet.markercluster': 'vendor/leaflet/leaflet.markercluster',
        'datatables': 'vendor/datatables/jquery.dataTables.min',
        'datatables.foundation': 'vendor/datatables/dataTables.foundation'
    },
    shim: {
        'jquery': { exports: '$' },
        'datatables': {
            deps: ['jquery'],
            exports: ['jQuery.fn.dataTable']
        },
        'datatables.foundation': {
            deps: ['datatables']
        },
        'leaflet.markercluster': {
            deps: ['leaflet']
        }
    }
});