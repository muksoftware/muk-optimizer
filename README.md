# MUK OPTIMIZER 🚀

![Version](https://img.shields.io/badge/version-1.0.0-emerald)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android-blue)
![License](https://img.shields.io/badge/license-MIT-green)

**MUK OPTIMIZER**, Windows işletim sistemlerinde ve Android (ADB) cihazlarında sistem gecikmesini (input lag & network latency) minimize etmek, arka plan hizmetlerini temizlemek, gizliliği artırmak ve donanım performansını en üst seviyeye çıkarmak için geliştirilmiş modüler bir optimizasyon paketidir.

---

## 📌 Özellikler

* **⚡ Düşük Gecikme (Low Latency):** TCP/IP, DNS, Ağ Bağdaştırıcısı ve Giriş Gecikmesi (Input Lag) ayarlarını en düşük seviyeye indirir.
* **🧹 Bloatware & Hizmet Temizliği:** Arka planda RAM ve CPU tüketen gereksiz sistem hizmetlerini, telemetri araçlarını ve hazır gelen uygulamaları devre dışı bırakır.
* **🔒 Gizlilik & Telemetri Engelleme:** İşletim sistemlerinin veri toplama modüllerini kapatır, izleyicileri ve reklam kimliklerini engeller.
* **📱 Android ADB Desteği:** Android cihazlar için özel profil seçenekleri (Balanced, Extra Boost, Power Saving, Vulkan, Qualcomm) sunar.
* **🛡️ Güvenli İşlem:** Tüm değişiklikler geri alınabilir yapıdadır ve sistem geri yükleme noktası oluşturma seçeneği içerir.

---

## 📂 Proje Yapısı

```text
muk-optimizer/
├── commands/
│   ├── bat/                  # Windows & Android Batch Komutları
│   │   ├── Balanced.bat
│   │   ├── Compile.bat
│   │   ├── Extra_Boost.bat
│   │   ├── Hardware.bat
│   │   ├── Lite_ps.bat
│   │   ├── Power_Saving.bat
│   │   ├── Qualcomm_only.bat
│   │   └── Vulkan.bat
│   ├── ps1/                  # Windows PowerShell Modülleri
│   │   └── winoptimizer.ps1
│   └── sh/                   # Android Shell (ADB) Modülleri
│       ├── Balanced.sh
│       ├── Compile.sh
│       ├── Extra_Boost.sh
│       ├── Hardware.sh
│       ├── Lite_ps.sh
│       ├── Power_Saving.sh
│       ├── Qualcomm_only.sh
│       └── Vulkan.sh
└── index.html                # Proje Web Landing Page
```

---

## 🛠️ Nasıl Çalışır? & Kurulum Rehberi

### 1. Windows Optimizasyonu (PowerShell & Batch)

Windows tarafındaki scriptler, `regedit` (Kayıt Defteri) ayarlarını günceller, gereksiz Windows servislerini durdurur ve güç planlarını yüksek performansa ayarlar.

#### PowerShell Scriptini Çalıştırma:
1. PowerShell'i **Yönetici Olarak** açın.
2. Komut çalıştırma politikasını geçici olarak izinli hale getirin:
   ```powershell
   Set-ExecutionPolicy Unrestricted -Scope Process
   ```
3. Modülün bulunduğu dizine geçip scripti çalıştırın:
   ```powershell
   cd commands/ps1/
   .\winoptimizer.ps1
   ```

#### Batch Dosyalarını Çalıştırma:
* `commands/bat/` klasöründeki ihtiyacınıza uygun `.bat` dosyasına sağ tıklayıp **Yönetici Olarak Çalıştır** demeniz yeterlidir.

---

### 2. Android Optimizasyonu (ADB Scriptleri)

Android tarafında Root yetkisi gerekmeden ADB (Android Debug Bridge) shell komutları aracılığıyla arka plan kısıtlamaları, render motoru tercihleri (Vulkan/OpenGL) ve cihaz modları uygulanır.

#### Ön Gereksinimler:
* Bilgisayarınızda **ADB Tools** kurulu olmalıdır.
* Telefonunuzda **Geliştirici Seçenekleri > USB Hata Ayıklama (USB Debugging)** açık olmalıdır.

#### Kurulum ve Çalıştırma Adımları:

1. **Cihaz Bağlantısını Kontrol Edin:**
   ```bash
   adb devices
   ```
   *(Ekranda cihaz kodunuzun ve "device" ibaresinin göründüğünden emin olun.)*

2. **İstediğiniz Modu Uygulayın:**
   * **Linux/macOS veya WSL kullanıyorsanız (`.sh` dosyaları):**
     ```bash
     cd commands/sh/
     chmod +x Extra_Boost.sh
     ./Extra_Boost.sh
     ```
   * **Windows CMD/PowerShell kullanıyorsanız (`.bat` dosyaları):**
     ```cmd
     cd commands/bat
     Extra_Boost.bat
     ```

---

## ⚙️ Mod Yapılandırma Profilleri

| Mod | Açıklama |
| :--- | :--- |
| **Extra_Boost** | Maksimum performans, varsayılan sistem kısıtlamalarını kaldırma ve en düşük gecikme. |
| **Balanced** | Performans ve pil ömrü arasında ideal denge sağlayan günlük kullanım profili. |
| **Power_Saving** | Pil ömrünü maksimuma çıkarmak için arka plan işlemlerini sınırlandırır. |
| **Vulkan** | Oyun ve grafik işlemlerinde GPU render motorunu Vulkan API'sine zorlar. |
| **Qualcomm_only** | Snapdragon işlemcili cihazlara özel GPU ve işlemci optimizasyonları. |
| **Compile** | Uygulama derleme ve DEX optimizasyonlarını tetikler (Android speed-profile). |

---

## ⚠️ Önemli Uyarı ve Yasal Sorumluluk Reddi

> **Yasal Uyarı:** Bu araçlar sistem kaynaklarını yüksek seviyede manipüle eder. Scriptleri çalıştırmadan önce Windows üzerinde bir **Sistem Geri Yükleme Noktası (System Restore Point)** oluşturmanız ve Android cihazınızın yedeğini almanız şiddetle tavsiye edilir. Oluşabilecek sistem kararsızlıklarından kullanıcı sorumludur.

---

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında korunmaktadır. İstediğiniz gibi geliştirebilir, değiştirebilir ve dağıtabilirsiniz.
