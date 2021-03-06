var express = require('express');
const https = require('https');
var router = express.Router();

router.post('/', function(req, res, next) {
    var content = Object.keys(req.body)[0];

    var optionsget = {
        rejectUnauthorized: false,
        host: 'localhost',
        port: 5001,
        path: '/api/authentification/login',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    };

    var reqGet = https.request(optionsget, function(response) {
        if (response.statusCode >= 400 && response.statusCode < 500) {
            res.json({
                value: -1
            });
        }

        response.on('data', function(d) {
            var data = JSON.parse(d);

            if (data.value != -1) {
                res.json({
                    value: data.value
                });
            } else {
                res.json({
                    value: -1
                });
            }
        });
    });

    reqGet.write(content);
    reqGet.end();
    reqGet.on('error', function(e) {
        console.error(e);
    });
});

module.exports = router;
