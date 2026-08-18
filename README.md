# MUK OPTIMIZER 🚀

![Version](https://img.shields.io/badge/version-2.0.0-emerald)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android-blue)
![License](https://img.shields.io/badge/license-MIT-green)

**MUK OPTIMIZER**, Windows işletim sistemlerinde ve Android (ADB) cihazlarında sistem gecikmesini (input lag & network latency) minimize etmek, arka plan hizmetlerini temizlemek, gizliliği artırmak ve donanım performansını en üst seviyeye çıkarmak için geliştirilmiş modüler bir optimizasyon paketidir.

---

## 🚀 Hızlı Kurulum & Kullanım Guide

Kullanıcıların komut satırı ile uğraşmasına gerek yoktur. Tüm işlemler otomatik bir arayüz/başlatıcı üzerinden yürütülür.

### Adım Adım Kurulum:
1. Sağ tarafta bulunan **[Releases](../../releases)** bölümüne gidin.
2. En son sürüme ait `.zip` arşivini indirin.
3. İndirdiğiniz `.zip` dosyasını bir klasöre çıkarın (ayıklayın).
4. Klasör içerisindeki **`LauncherApp.exe`** uygulamasını **Yönetici Olarak** çalıştırın.
5. Açılan arayüzden uygulamak istediğiniz optimizasyon modunu (Windows veya Android ADB) seçin. Otomatik kurulum tamamlanacaktır.

---

## 📌 Özellikler

* **⚡ Düşük Gecikme (Low Latency):** TCP/IP, DNS, Ağ Bağdaştırıcısı ve Giriş Gecikmesi (Input Lag) ayarlarını en düşük seviyeye indirir.
* **🧹 Bloatware & Hizmet Temizliği:** Arka planda RAM ve CPU tüketen gereksiz sistem hizmetlerini, telemetri araçlarını ve hazır gelen uygulamaları devre dışı bırakır.
* **🔒 Gizlilik & Telemetri Engelleme:** İşletim sistemlerinin veri toplama modüllerini kapatır, izleyicileri ve reklam kimliklerini engeller.
* **📱 Android ADB Desteği:** Android cihazlar için özel profil seçenekleri (Balanced, Extra Boost, Power Saving, Vulkan, Qualcomm) sunar.
* **🛡️ Güvenli İşlem:** Tüm değişiklikler geri alınabilir yapıdadır ve sistem geri yükleme noktası oluşturma seçeneği içerir.

---

## ⚙️ Mod Yapılandırma Profilleri

`LauncherApp.exe` üzerinden seçebileceğiniz hazır profiller:

| Mod | Açıklama |
| :--- | :--- |
| **Extra_Boost** | Maksimum performans, varsayılan sistem kısıtlamalarını kaldırma ve en düşük gecikme. |
| **Balanced** | Performans ve pil ömrü arasında ideal denge sağlayan günlük kullanım profili. |
| **Power_Saving** | Pil ömrünü maksimuma çıkarmak için arka plan işlemlerini sınırlandırır. |
| **Vulkan** | Oyun ve grafik işlemlerinde GPU render motorunu Vulkan API'sine zorlar. |
| **Qualcomm_only** | Snapdragon işlemcili cihazlara özel GPU ve işlemci optimizasyonları. |
| **Compile** | Uygulama derleme ve DEX optimizasyonlarını tetikler (Android speed-profile). |

---

## 📂 Proje Yapısı

```text
muk-optimizer/
├── LauncherApp.exe           # Ana Otomatik Başlatıcı Uygulaması
└── commands/
    ├── bat/                  # Windows & Android Batch Komutları
    ├── ps1/                  # Windows PowerShell Modülleri
    └── sh/                   # Android Shell (ADB) Modülleri
```

---

## ⚠️ Önemli Uyarı ve Yasal Sorumluluk Reddi

> **Yasal Uyarı:** Bu araçlar sistem kaynaklarını yüksek seviyede manipüle eder. Optimizasyonu uygulamadan önce Windows üzerinde bir **Sistem Geri Yükleme Noktası (System Restore Point)** oluşturmanız ve Android cihazınızın yedeğini almanız tavsiye edilir. Oluşabilecek sistem kararsızlıklarından kullanıcı sorumludur.

---

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında korunmaktadır. İstediğiniz gibi geliştirebilir, değiştirebilir ve dağıtabilirsiniz.
