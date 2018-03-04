module.exports =
    {
        doConvert: function(data)
        {
            return convert(data);
        }
    };

function convert(data)
{
    var json = data;

    if(typeof(data) === 'string' || data instanceof String)
    {
        json = JSON.parse(data)
    }

    var converted = {}

    converted.type     = "FeatureCollection";
    converted.features = []

    var featuresJSON = json["features"];

    for(var i = 0; i < featuresJSON.length; i++)
    {
        var feature = {}
        var properties = {}

        feature.type             = "Feature";
        feature.geometry         = featuresJSON[i].geometry;
        properties.name      = featuresJSON[i].properties.Name;
        properties.hours   = featuresJSON[i].properties.ATSTREET;
        properties.type = featuresJSON[i].properties.BUSSTOPNUM;
        properties.ispublic     = featuresJSON[i].properties.DIRECTION;
        properties.address      = featuresJSON[i].properties.description;
        properties.phone    = featuresJSON[i].properties.Phone;
        properties.location        = featuresJSON[i].properties.STATUS;
        properties.count      = featuresJSON[i].properties.CITY_NAME;
        feature.properties       = properties

        converted.features.push(feature)
    }

    return JSON.stringify(converted, null, 4);
}