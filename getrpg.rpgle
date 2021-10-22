      *  Ejemplo simple de un servicio GET (REST) que
      *  es llamado usando protocolo HTTP cuyo input viene
      *  desde la URL y responde un JSON, ejemplo:
      *
      *        http://x.x.x.x:8500/cust/123
      *
      *
      * Tip para compilar (en 2 pasos):
      *> CRTRPGMOD MODULE(AZANDRES/GETRPG) SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *> CRTPGM PGM(AZANDRES/GETRPG) BNDSRVPGM(QHTTPSVR/QZHBCGI) ACTGRP(AZANDRES)

     H OPTION(*SRCSTMT: *NODEBUGIO)

     FCUSTFILE  IF   E           K DISK

     D getenv          PR              *   extproc('getenv')
     D   var                           *   value options(*string)

     D QtmhWrStout     PR                  extproc('QtmhWrStout')
     D   DtaVar                   65535a   options(*varsize)
     D   DtaVarLen                   10I 0 const
     D   ErrorCode                 8000A   options(*varsize)

     D err             ds                  qualified
     D   bytesProv                   10i 0 inz(0)
     D   bytesAvail                  10i 0 inz(0)


     D CRLF            C                   x'0d25'
     D pos             s             10i 0
     D uri             s           5000a   varying
     D data            s           5000a

     D ID1             c                   '/cust/'
     D ID2             c                   '/custinfo/'

     D LBRACE          C                   u'007b'
     D RBRACE          C                   u'007d'

      /free
          *inlr = *on;

          uri = %str(getenv('REQUEST_URI'));

          monitor;
             select;
             when %scan(ID1: uri) > 0;
               pos = %scan(ID1: uri) + %len(ID1);
             when %scan(ID2: uri) > 0;
               pos = %scan(ID2: uri) + %len(ID2);
             other;
               pos = 0;
             endsl;
             custno = %int(%subst(uri:pos));
          on-error;
             data = 'Status: 500 Invalid URI' + CRLF
                  + 'Content-type: text/json' + CRLF
                  + CRLF
                  + %char(LBRACE) + CRLF
                  + '"success": false,' + CRLF
                  + '"errmsg": "Invalid URI"' + CRLF
                  + %char(RBRACE);
             QtmhWrStout(data: %len(%trimr(data)): err);
             return;
          endmon;

          chain custno CUSTFILE;
          if not %found;
             data = 'Status: 500 Unknown Customer' + CRLF
                  + 'Content-type: text/json' + CRLF
                  + CRLF
                  + %char(LBRACE) + CRLF
                  + '"success": false,' + CRLF
                  + '"errmsg": "Unknown Customer Number"' + CRLF
                  + %char(RBRACE);
             QtmhWrStout(data: %len(%trimr(data)): err);
             return;
          endif;

          data = 'Status: 200 OK' + CRLF
               + 'Content-type: text/json' + CRLF
               + CRLF
               + %char(LBRACE) + CRLF
               + '"custno":'   + %char(custno) + ','
               + '"name":"'     + %trim(name)   + '",'
               + '"street":"'   + %trim(street)  + '",'
               + '"city":"'     + %trim(city)    + '",'
               + '"state":"'    + %trim(state)   + '",'
               + '"postal":"'   + %trim(postal)  + '"'
               + %char(RBRACE);
          QtmhWrStout(data: %len(%trimr(data)): err);
          *inlr = *on;

      /end-free


