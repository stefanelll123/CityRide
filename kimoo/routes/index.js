var express = require('express');
var router = express.Router();
const https = require('https');

/* GET home page. */
router.get('/', function(req, res, next) {
    if (!req.cookies['user-id']) {
        res.redirect('/login');
    } else {
        var optionsget = {
            rejectUnauthorized: false,
            host: 'localhost',
            port: 5001,
            path: '/api/borrow?userId=' + req.cookies['user-id'],
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        };

        var reqGet = https.request(optionsget, function(response) {
            console.log(response.statusCode);
            if (response.statusCode >= 400 && response.statusCode < 500) {
                return res.render('home');
            } else if (
                response.statusCode >= 200 &&
                response.statusCode < 300
            ) {
                return res.render('homeReturn');
            }
        });

        reqGet.end();
        reqGet.on('error', function(e) {
            console.error(e);
        });
    }
});

module.exports = router;
