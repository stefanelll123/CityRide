var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
  if(!req.cookies['user-id']) {
    res.render('login');
  }
  else {
    res.redirect('/');
  }
});

module.exports = router;
