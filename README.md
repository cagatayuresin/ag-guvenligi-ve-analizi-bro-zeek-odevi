# 🔍 DNS Tünelleme Tespiti - Zeek/Bro Analizi

[![Zeek](https://img.shields.io/badge/Zeek-5.0+-blue.svg)](https://zeek.org/)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Network Security](https://img.shields.io/badge/Security-Network%20Analysis-red.svg)](https://github.com/cagatayuresin/ag-guvenligi-ve-analizi-bro-zeek-odevi)

> Zeek (eski adıyla Bro) kullanarak DNS tünelleme saldırılarının tespiti ve analizi

## 📋 İçindekiler

- [Proje Hakkında](#-proje-hakkında)
- [Özellikler](#-özellikler)
- [Kurulum](#-kurulum)
- [Kullanım](#-kullanım)
- [Tespit Yöntemleri](#-tespit-yöntemleri)
- [Örnek Çıktılar](#-örnek-çıktılar)
- [Dosya Yapısı](#-dosya-yapısı)
- [Kaynaklar](#-kaynaklar)

## 🎯 Proje Hakkında

Bu proje, Zeek (Bro) ağ analiz aracı kullanarak DNS tünelleme saldırılarını tespit etmek için geliştirilmiştir. DNS tünelleme, kötü niyetli aktörlerin DNS protokolünü kullanarak güvenlik duvarlarını atlatmak ve veri sızdırmak için kullandığı bir tekniktir.

Proje kapsamında **dnscat2** DNS tünelleme trafiği analiz edilmiş ve çeşitli tespit yöntemleri uygulanmıştır.

## ✨ Özellikler

- 🔎 **Uzun Domain İsimleri Tespiti**: Anormal uzunluktaki domain isimlerini algılar (>50 karakter)
- 📊 **TXT Sorgu Analizi**: Şüpheli TXT kayıt sorgularını tespit eder
- 📈 **Yüksek Sorgu Oranı Tespiti**: Belirli zaman aralığında aşırı DNS sorgusu yapan kaynakları belirler
- 🐳 **Docker Desteği**: Kolay kurulum ve taşınabilir çalışma ortamı
- 📝 **Otomatik Loglama**: Tespit edilen anomaliler otomatik olarak loglanır
- 📄 **CSV Export**: Sonuçları CSV formatında dışa aktarma

## 🚀 Kurulum

### Gereksinimler

- Docker
- Docker Compose

### Adımlar

1. Repoyu klonlayın:
```bash
git clone https://github.com/cagatayuresin/ag-guvenligi-ve-analizi-bro-zeek-odevi.git
cd ag-guvenligi-ve-analizi-bro-zeek-odevi
```

2. Docker container'ı başlatın:
```bash
docker-compose up -d
```

3. Container'a bağlanın:
```bash
docker exec -it zeek bash
```

## 💻 Kullanım

### PCAP Analizi

Zeek container içinde PCAP dosyasını analiz edin:

```bash
cd /usr/local/zeek
zeek -C -r /pcap/dnscat2_dns_tunneling_24hr.pcap scripts/dns_tunnel_detect.zeek
```

### Sonuçları İnceleme

**Notice loglarını görüntüleyin:**
```bash
cat notice.log | zeek-cut ts id.orig_h id.resp_h note msg
```

**TXT sorgularını filtreleyin:**
```bash
cat dns.log | zeek-cut ts id.orig_h id.resp_h qtype_name query | grep TXT
```

**Uzun domain isimlerini bulun:**
```bash
cat dns.log | zeek-cut ts id.orig_h id.resp_h query | awk 'length($4) > 30'
```

### CSV Export

Logları CSV formatına çevirin:

```bash
# TSV formatına çevir
cat notice.log | zeek-cut ts id.orig_h id.resp_h note msg > notice_clean.tsv

# CSV'ye dönüştür
tr '\t' ',' < notice_clean.tsv > notice_clean.csv

# Host sisteme kopyala
docker cp zeek:/usr/local/zeek/notice_clean.csv .
```

## 🎯 Tespit Yöntemleri

### 1. Uzun Domain İsmi Tespiti
DNS tünelleme sırasında veri, domain isimlerinde kodlanarak gönderilir. Bu nedenle anormal uzunluktaki domain isimleri şüphelidir.

```zeek
if ( |domain| > LONG_DOMAIN_THRESHOLD )
    NOTICE([$note=DNS_TUNNELING_DETECTED, ...])
```

### 2. TXT Kayıt Sorguları
TXT kayıtları, DNS tünellemede sıkça kullanılır çünkü daha fazla veri taşıyabilir.

```zeek
if ( qtype == 16 )  # TXT record type
    NOTICE([$note=DNS_TUNNELING_DETECTED, ...])
```

### 3. Yüksek Sorgu Oranı
Normal DNS trafiğine göre çok daha yüksek oranda sorgu yapan kaynaklar tespit edilir.

```zeek
if ( query_count[src] > QUERY_THRESHOLD )
    NOTICE([$note=DNS_TUNNELING_DETECTED, ...])
```

## 📊 Örnek Çıktılar

Analiz sonucunda `notice.log` dosyasında şu tür uyarılar oluşur:

```
[LONG DOMAIN] 192.168.1.100 -> a3f8d9e2c1b4567890abcdef1234567890abcdef.example.com
[TXT QUERY] 192.168.1.100 -> tunnel.malicious.com
[HIGH QUERY RATE] 192.168.1.100 made 150 queries in 10 seconds
```

## 📁 Dosya Yapısı

```
.
├── docker-compose.yaml          # Docker yapılandırması
├── LICENSE                      # Lisans dosyası
├── README.md                    # Bu dosya
├── sunum-komutlari.md          # Sunum için kullanılan komutlar
├── notice_clean.csv            # Export edilen CSV sonuçları
├── logs/                       # Zeek log dosyaları
├── pcap/                       # Analiz için PCAP dosyaları
│   ├── dns_tunnel_demo.pcap
│   └── dnscat2_dns_tunneling_24hr.pcap
└── scripts/                    # Zeek script'leri
    └── dns_tunnel_detect.zeek  # DNS tünelleme tespit script'i
```

## 📚 Kaynaklar

- [Zeek Documentation](https://docs.zeek.org/)
- [DNS Tunneling Analysis with dnscat2](https://www.activecountermeasures.com/malware-of-the-day-dnscat2-dns-tunneling/)
- [Zeek DNS Analysis](https://docs.zeek.org/en/master/scripts/base/protocols/dns/main.zeek.html)

## 🤝 Katkıda Bulunma

Katkılarınızı memnuniyetle karşılıyorum! Pull request göndermekten çekinmeyin.

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

<p align="center">
  <img src="https://img.shields.io/badge/Made%20with-Zeek-blue?style=for-the-badge" alt="Made with Zeek"/>
  <img src="https://img.shields.io/badge/Network-Security-red?style=for-the-badge" alt="Network Security"/>
</p>

<p align="center">
  Geliştirici: <a href="https://github.com/cagatayuresin">@cagatayuresin</a>
</p>