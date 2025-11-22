# Sunum Notlari

```bash
cat notice.log | zeek-cut ts id.orig_h id.resp_h note msg
```

```bash
cat dns.log | zeek-cut ts id.orig_h id.resp_h qtype_name query | grep TXT
```

```bash
cat dns.log | zeek-cut ts id.orig_h id.resp_h query | awk 'length($4) > 30'
```

```bash
cat notice.log | zeek-cut ts id.orig_h id.resp_h note msg > notice_clean.tsv
```

```bash
tr '\t' ',' < notice_clean.tsv > notice_clean.csv
```

```bash
docker cp zeek:/usr/local/zeek/notice_clean.csv .
```

```txt
https://www.activecountermeasures.com/malware-of-the-day-dnscat2-dns-tunneling/
```

