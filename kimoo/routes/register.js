var express = require('express');
var router = express.Router();

router.get('/', function(req, res, next) {
    if (!req.cookies['user-id']) {
        res.render('register');
    } else {
        res.redirect('/');
    }
});

module.exports = router;
