# CSV emission: differential results

```
  milliseconds: front-end 64644 interp 109186 compile 10417 cranelift-generic 113340 cranelift 146095 cranelift-unfused 148245
corpus: 850 cases x 5 backends (ok 696, unsupported 148, invalid-utf8 6);  backends disagree 0; recognizer rejects 0; 593.639 s
    lines 850
    csvmodule      696 ok    0 failed
    csvwriter      372 ok    0 failed
    expected       850 ok    0 failed
    incomplete     148 ok    0 failed
    prefix         148 ok    0 failed
    reference      696 ok    0 failed
    strict         696 ok    0 failed
    utf8           264 ok    0 failed
  milliseconds: front-end 4940 interp 482575 compile 34339 cranelift-generic 5315 cranelift 4354 cranelift-unfused 3990
exhaustive (every string of length 0..5 over {a , " CR LF}, in 6 contexts): 23436 cases x 5 backends (ok 23436);  backends disagree 0; recognizer rejects 0; 7.256 s
    lines 23436
    csvmodule    23436 ok    0 failed
    csvwriter     7812 ok    0 failed
    expected     23436 ok    0 failed
    reference    23436 ok    0 failed
    strict       23436 ok    0 failed
    utf8          7812 ok    0 failed
  milliseconds: front-end 15256 interp 11063 compile 1333 cranelift-generic 4553 cranelift 8878 cranelift-unfused 8118
fuzz seed 1: 120 cases x 5 backends (ok 105, unsupported 15);  backends disagree 0; recognizer rejects 0; 49.411 s
    lines 120
    csvmodule      105 ok    0 failed
    csvwriter       75 ok    0 failed
    expected       120 ok    0 failed
    incomplete      15 ok    0 failed
    prefix          15 ok    0 failed
    reference      105 ok    0 failed
    strict         105 ok    0 failed
    utf8            43 ok    0 failed
  milliseconds: front-end 15082 interp 10363 compile 1317 cranelift-generic 5077 cranelift 7660 cranelift-unfused 8620
fuzz seed 2: 120 cases x 5 backends (ok 101, unsupported 19);  backends disagree 0; recognizer rejects 0; 48.331 s
    lines 120
    csvmodule      101 ok    0 failed
    csvwriter       73 ok    0 failed
    expected       120 ok    0 failed
    incomplete      19 ok    0 failed
    prefix          19 ok    0 failed
    reference      101 ok    0 failed
    strict         101 ok    0 failed
    utf8            42 ok    0 failed
  milliseconds: front-end 14591 interp 11214 compile 1580 cranelift-generic 5431 cranelift 9396 cranelift-unfused 8810
fuzz seed 3: 120 cases x 5 backends (ok 104, unsupported 16);  backends disagree 0; recognizer rejects 0; 51.263 s
    lines 120
    csvmodule      104 ok    0 failed
    csvwriter       77 ok    0 failed
    expected       120 ok    0 failed
    incomplete      16 ok    0 failed
    prefix          16 ok    0 failed
    reference      104 ok    0 failed
    strict         104 ok    0 failed
    utf8            45 ok    0 failed
  milliseconds: front-end 16867 interp 11148 compile 1575 cranelift-generic 5527 cranelift 8683 cranelift-unfused 9038
fuzz seed 4: 120 cases x 5 backends (unsupported 16, ok 104);  backends disagree 0; recognizer rejects 0; 53.011 s
    lines 120
    csvmodule      104 ok    0 failed
    csvwriter       75 ok    0 failed
    expected       120 ok    0 failed
    incomplete      16 ok    0 failed
    prefix          16 ok    0 failed
    reference      104 ok    0 failed
    strict         104 ok    0 failed
    utf8            43 ok    0 failed
  milliseconds: front-end 15081 interp 9662 compile 1393 cranelift-generic 5544 cranelift 8962 cranelift-unfused 9249
fuzz seed 5: 120 cases x 5 backends (unsupported 23, ok 97);  backends disagree 0; recognizer rejects 0; 50.107 s
    lines 120
    csvmodule       97 ok    0 failed
    csvwriter       71 ok    0 failed
    expected       120 ok    0 failed
    incomplete      23 ok    0 failed
    prefix          23 ok    0 failed
    reference       97 ok    0 failed
    strict          97 ok    0 failed
    utf8            43 ok    0 failed
  milliseconds: front-end 13721 interp 10308 compile 1419 cranelift-generic 5120 cranelift 8779 cranelift-unfused 9071
fuzz seed 6: 120 cases x 5 backends (ok 102, unsupported 18);  backends disagree 0; recognizer rejects 0; 48.651 s
    lines 120
    csvmodule      102 ok    0 failed
    csvwriter       74 ok    0 failed
    expected       120 ok    0 failed
    incomplete      18 ok    0 failed
    prefix          18 ok    0 failed
    reference      102 ok    0 failed
    strict         102 ok    0 failed
    utf8            43 ok    0 failed
  milliseconds: front-end 17047 interp 10356 compile 1537 cranelift-generic 5985 cranelift 10246 cranelift-unfused 10199
fuzz seed 7: 120 cases x 5 backends (ok 99, unsupported 21);  backends disagree 0; recognizer rejects 0; 55.658 s
    lines 120
    csvmodule       99 ok    0 failed
    csvwriter       71 ok    0 failed
    expected       120 ok    0 failed
    incomplete      21 ok    0 failed
    prefix          21 ok    0 failed
    reference       99 ok    0 failed
    strict          99 ok    0 failed
    utf8            44 ok    0 failed
  milliseconds: front-end 16858 interp 11309 compile 1574 cranelift-generic 5787 cranelift 10043 cranelift-unfused 10493
fuzz seed 8: 120 cases x 5 backends (ok 101, unsupported 19);  backends disagree 0; recognizer rejects 0; 56.261 s
    lines 120
    csvmodule      101 ok    0 failed
    csvwriter       75 ok    0 failed
    expected       120 ok    0 failed
    incomplete      19 ok    0 failed
    prefix          19 ok    0 failed
    reference      101 ok    0 failed
    strict         101 ok    0 failed
    utf8            44 ok    0 failed
total: 25246 cases, 126230 runs; every check passed
```
