var express = require('express');
const https = require('https');
var router = express.Router();

router.post('/', function(req, res, next) {
  $.ajax({
    method: 'POST',
    data: JSON.stringify(req),
    url: "https://localhost:5001/api/authentification/login",
    contentType: "application/json; charset=utf-8",
    dataType: "json",
    success: function(result) {
      res.json(result);
    },
    error: function(result) {
      res.json({value: -1})
    }    
  });
});


module.exports = router;
