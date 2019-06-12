var express = require('express');
var router = express.Router();
const https = require('https');

/* GET home page. */
router.get('/', function(req, res, next) {
    if (!req.cookies['user-id']) {
        res.redirect('/login');
    } else {
        var opt = {
            rejectUnauthorized: false,
            host: 'localhost',
            port: 5001,
            path:
                '/api/authentification/users?userId=' + req.cookies['user-id'],
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        };

        var reqGet = https.request(opt, function(response) {
            var data = '';

            response.on('data', chunk => {
                data += chunk;
            });

            response.on('end', function() {
                var userInfo = JSON.parse(data);
                if (userInfo.role == 'user') {
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
                        if (
                            response.statusCode >= 400 &&
                            response.statusCode < 500
                        ) {
                            return res.render('home', {
                                firstName: userInfo.first_name,
                                lastName: userInfo.last_name
                            });
                        } else if (
                            response.statusCode >= 200 &&
                            response.statusCode < 300
                        ) {
                            var options = {
                                rejectUnauthorized: false,
                                host: 'localhost',
                                port: 5001,
                                path:
                                    '/api/borrow/price?userId=' +
                                    req.cookies['user-id'],
                                method: 'GET',
                                headers: {
                                    'Content-Type': 'application/json'
                                }
                            };

                            var reqGet = https.request(options, function(
                                response
                            ) {
                                var data = '';

                                response.on('data', chunk => {
                                    data += chunk;
                                });

                                response.on('end', function() {
                                    return res.render('homeReturn', {
                                        totals: JSON.parse(data),
                                        firstName: userInfo.first_name,
                                        lastName: userInfo.last_name
                                    });
                                });
                            });

                            reqGet.end();
                            reqGet.on('error', function(e) {
                                console.error(e);
                            });
                        }
                    });

                    reqGet.end();
                    reqGet.on('error', function(e) {
                        console.error(e);
                    });
                } else {
                    var op = {
                        rejectUnauthorized: false,
                        host: 'localhost',
                        port: 5001,
                        path: '/api/admin/bicycles',
                        method: 'GET',
                        headers: {
                            'Content-Type': 'application/json'
                        }
                    };

                    var reqGet = https.request(op, function(response) {
                        var data = '';

                        response.on('data', chunk => {
                            data += chunk;
                        });

                        response.on('end', function() {
                            var bicycles = JSON.parse(data);
                            
                            return res.render('homeAdmin', {
                                firstName: userInfo.first_name,
                                lastName: userInfo.last_name,
                                allBicycles: bicycles
                            });
                        });
                    });

                    reqGet.end();
                    reqGet.on('error', function(e) {
                        console.error(e);
                    });
                }
            });
        });

        reqGet.end();
        reqGet.on('error', function(e) {
            console.error(e);
        });
    }
});

module.exports = router;
