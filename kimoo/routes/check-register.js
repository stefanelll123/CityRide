var express = require('express');
const https = require('https');
var router = express.Router();

router.post('/', function(req, res, next) {
    var content = Object.keys(req.body)[0];

    var optionsget = {
        rejectUnauthorized: false,
        host: 'localhost',
        port: 5001,
        path: '/api/authentification/register',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    };

    var reqGet = https.request(optionsget, function(response) {
        if (response.statusCode >= 400 && response.statusCode < 500) {
            return res.json({
                value: -1
            });
        } else if (response.statusCode >= 200 && response.statusCode < 300) {
            return res.json({
                value: 1
            });
        }
    });

    reqGet.write(content);
    reqGet.end();
    reqGet.on('error', function(e) {
        console.error(e);
    });
});

module.exports = router;
