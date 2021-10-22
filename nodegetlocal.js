// Setting env para driver DB2
// $ export PATH=/QOpenSys/QIBM/ProdData/OPS/Node6/bin:$PATH
// $ export LIBPATH=/QOpenSys/QIBM/ProdData/OPS/Node6/bin:$LIBPATH
// http://x.x.x.x:3030/custno/
//
const express = require('express');
const db = require('/QOpenSys/QIBM/ProdData/OPS/Node6/os400/db2i/lib/db2a');
const dbconn = db.dbconn();
dbconn.conn("*LOCAL");
const stmt = new db.dbstmt(dbconn);

app = express();

app.get('/', function(req, res) {
    res.send('<h1> Testing Node WS...</h1>');
});

app.get('/custno/', function(req, res) {
    res.set('Content-Type', 'text/json'); //
    res.status(200);
    let stmt = new db.dbstmt(dbconn);
    stmt.exec("select * from azandres.custfile", (rs) => { // Query the statement
        res.json(rs);
        stmt.close();
    });
});

app.get('/custno/:id', function(req, res) {
    console.log(req.params.id);
    //res.set('Content-Type', 'text/json'); //
    //res.status(200);
    let stmt = new db.dbstmt(dbconn);
    stmt.exec("select * from azandres.custfile where custno =" + req.params.id, (rs) => {
        console.log('result:' + JSON.stringify(rs));
        if (rs == '') {
            res.status(404).json({ error: 'Cliente no encontrado' });
        } else {
            res.json(rs);
        }
        stmt.close();
    });
});

app.use((req, res, next) => {
    res.status(501).json({ error: 'Something broke!' });
    //    res.send({
    //        error: 'Not found'
    //});
})

var port = 3030;
app.listen(port, function() {
    console.log('Servidor iniciado en ' + port);
    //dbconn.disconn();
    //dbconn.close();
});
