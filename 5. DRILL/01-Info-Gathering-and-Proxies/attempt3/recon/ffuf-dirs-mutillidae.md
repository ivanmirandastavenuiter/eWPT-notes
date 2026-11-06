# FFUF Report

  Command line : `ffuf -u http://meta2/mutillidae/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt -e php -mc all -fc 404 -ac -t 10 -o recon/ffuf-dirs-mutillidae -of all`
  Time: 2026-11-06T12:21:37&#43;01:00

  | FUZZ | URL | Redirectlocation | Position | Status Code | Content Length | Content Words | Content Lines | Content Type | Duration | ResultFile | ScraperData | Ffufhash
  | :- | :-- | :--------------- | :---- | :------- | :---------- | :------------- | :------------ | :--------- | :----------- | :------------ | :-------- |
  | .htaccesscAVjPDIu | http://meta2/mutillidae/includes | http://meta2/mutillidae/includes/ | 9 | 301 | 317 | 21 | 10 | text/html; charset=iso-8859-1 | 278.183µs |  |  | 0c38d9
  | login | http://meta2/mutillidae/login |  | 17 | 200 | 4102 | 225 | 130 | text/html | 21.479116ms |  |  | 0c38d11
  | installation | http://meta2/mutillidae/installation |  | 69 | 200 | 8138 | 978 | 150 | text/html | 17.124013ms |  |  | 0c38d45
  | register | http://meta2/mutillidae/register |  | 49 | 200 | 1823 | 92 | 60 | text/html | 18.083848ms |  |  | 0c38d31
  | inc | http://meta2/mutillidae/inc |  | 195 | 200 | 386260 | 38538 | 9004 | text/plain | 969.502µs |  |  | 0c38dc3
  | styles | http://meta2/mutillidae/styles | http://meta2/mutillidae/styles/ | 295 | 301 | 315 | 21 | 10 | text/html; charset=iso-8859-1 | 113.104µs |  |  | 0c38d127
  | classes | http://meta2/mutillidae/classes | http://meta2/mutillidae/classes/ | 377 | 301 | 316 | 21 | 10 | text/html; charset=iso-8859-1 | 100.347µs |  |  | 0c38d179
  | javascript | http://meta2/mutillidae/javascript | http://meta2/mutillidae/javascript/ | 417 | 301 | 319 | 21 | 10 | text/html; charset=iso-8859-1 | 102.716µs |  |  | 0c38d1a1
  | home | http://meta2/mutillidae/home |  | 279 | 200 | 2930 | 141 | 54 | text/html | 15.672077ms |  |  | 0c38d117
  | images | http://meta2/mutillidae/images | http://meta2/mutillidae/images/ | 5 | 301 | 315 | 21 | 10 | text/html; charset=iso-8859-1 | 61.073287ms |  |  | 0c38d5
  | index | http://meta2/mutillidae/index |  | 31 | 200 | 24216 | 1035 | 564 | text/html | 61.720846ms |  |  | 0c38d1f
  | favicon | http://meta2/mutillidae/favicon |  | 773 | 200 | 1150 | 4 | 5 | image/x-icon | 603.684µs |  |  | 0c38d305
  | footer | http://meta2/mutillidae/footer |  | 629 | 200 | 450 | 21 | 16 | text/html | 16.424783ms |  |  | 0c38d275
  | header | http://meta2/mutillidae/header |  | 623 | 200 | 19879 | 764 | 481 | text/html | 16.604096ms |  |  | 0c38d26f
  | phpMyAdmin | http://meta2/mutillidae/phpMyAdmin |  | 949 | 200 | 174 | 7 | 10 | text/html | 17.216566ms |  |  | 0c38d3b5
  | robots | http://meta2/mutillidae/robots |  | 1319 | 200 | 160 | 8 | 7 | text/plain | 715.93µs |  |  | 0c38d527
  | . | http://meta2/mutillidae/. |  | 799 | 200 | 24216 | 1035 | 564 | text/html | 64.873311ms |  |  | 0c38d31f
  | page-not-found | http://meta2/mutillidae/page-not-found |  | 1739 | 200 | 705 | 52 | 25 | text/html | 23.416714ms |  |  | 0c38d6cb
  | phpinfo | http://meta2/mutillidae/phpinfo |  | 1897 | 200 | 48785 | 2449 | 677 | text/html | 16.224161ms |  |  | 0c38d769
  | documentation | http://meta2/mutillidae/documentation | http://meta2/mutillidae/documentation/ | 2335 | 301 | 322 | 21 | 10 | text/html; charset=iso-8859-1 | 86.51µs |  |  | 0c38d91f
  | notes | http://meta2/mutillidae/notes |  | 3319 | 200 | 1721 | 176 | 38 | text/html | 19.222898ms |  |  | 0c38dcf7
  | credits | http://meta2/mutillidae/credits |  | 5007 | 200 | 509 | 39 | 20 | text/html | 19.349867ms |  |  | 0c38d138f
  | passwords | http://meta2/mutillidae/passwords | http://meta2/mutillidae/passwords/ | 8903 | 301 | 318 | 21 | 10 | text/html; charset=iso-8859-1 | 130.645µs |  |  | 0c38d22c7
  | framing | http://meta2/mutillidae/framing |  | 50161 | 200 | 1426 | 96 | 49 | text/html | 19.181591ms |  |  | 0c38dc3f1
  | .project | http://meta2/mutillidae/.project |  | 66617 | 200 | 712 | 3 | 29 | text/plain | 4.776105ms |  |  | 0c38d10439
  | framer | http://meta2/mutillidae/framer |  | 77051 | 200 | 1437 | 87 | 41 | text/html | 4.546603ms |  |  | 0c38d12cfb
  