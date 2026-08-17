Projenin kök dizininde yer alacak README.md dosyası için kapsamlı, profesyonel ve teknik detay içeren dokümantasyonu hazırladım. Bu metni projenin README.md dosyasına doğrudan yapıştırabilirsin.MUK OPTIMIZER 🚀MUK OPTIMIZER, Windows işletim sistemlerinde ve Android (ADB) cihazlarında sistem gecikmesini (input lag & network latency) minimize etmek, arka plan hizmetlerini temizlemek, gizliliği artırmak ve donanım performansını en üst seviyeye çıkarmak için geliştirilmiş modüler bir optimizasyon paketidir.📌 Özellikler⚡ Düşük Gecikme (Low Latency): TCP/IP, DNS, Ağ Bağdaştırıcısı ve Giriş Gecikmesi (Input Lag) ayarlarını en düşük seviyeye indirir.🧹 Bloatware & Hizmet Temizliği: Arka planda RAM ve CPU tüketen gereksiz sistem hizmetlerini, telemetri araçlarını ve hazır gelen uygulamaları devre dışı bırakır.🔒 Gizlilik & Telemetri Engelleme: İşletim sistemlerinin veri toplama modüllerini kapatır, izleyicileri ve reklam kimliklerini engeller.📱 Android ADB Desteği: Android cihazlar için özel profil seçenekleri (Balanced, Extra Boost, Power Saving, Vulkan, Qualcomm) sunar.🛡️ Güvenli İşlem: Tüm değişiklikler geri alınabilir yapıdadır ve sistem geri yükleme noktası oluşturma seçeneği içerir.📂 Proje YapısıPlaintextmuk-optimizer/
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
🛠️ Nasıl Çalışır? & Kurulum Rehberi1. Windows Optimizasyonu (PowerShell & Batch)Windows tarafındaki scriptler, regedit (Kayıt Defteri) ayarlarını günceller, gereksiz Windows servislerini durdurur ve güç planlarını yüksek performansa ayarlar.PowerShell Scriptini Çalıştırma:PowerShell'i Yönetici Olarak açın.Komut çalıştırma politikasını geçici olarak izinli hale getirin:PowerShellSet-ExecutionPolicy Unrestricted -Scope Process
Modülün bulunduğu dizine geçip scripti çalıştırın:PowerShellcd commands/ps1/
.\winoptimizer.ps1
Batch Dosyalarını Çalıştırma:commands/bat/ klasöründeki ihtiyacınıza uygun .bat dosyasına sağ tıklayıp Yönetici Olarak Çalıştır demeniz yeterlidir.2. Android Optimizasyonu (ADB Scriptleri)Android tarafında Root yetkisi gerekmeden ADB (Android Debug Bridge) shell komutları aracılığıyla arka plan kısıtlamaları, render motoru tercihleri (Vulkan/OpenGL) ve cihaz modları uygulanır.Ön Gereksinimler:Bilgisayarınızda ADB Tools kurulu olmalıdır.Telefonunuzda Geliştirici Seçenekleri > USB Hata Ayıklama (USB Debugging) açık olmalıdır.Kurulum ve Çalıştırma Adımları:Cihaz Bağlantısını Kontrol Edin:Bashadb devices
(Ekranda cihaz kodunuzun ve "device" ibaresinin göründüğünden emin olun.)İstediğiniz Modu Uygulayın:Linux/macOS veya WSL kullanıyorsanız (.sh dosyaları):Bashcd commands/sh/
chmod +x Extra_Boost.sh
./Extra_Boost.sh
Windows CMD/PowerShell kullanıyorsanız (.bat dosyaları):DOScd commands/bat
Extra_Boost.bat
⚙️ Mod Yapılandırma ProfilleriModAçıklamaExtra_BoostMaksimum performans, varsayılan sistem kısıtlamalarını kaldırma ve en düşük gecikme.BalancedPerformans ve pil ömrü arasında ideal denge sağlayan günlük kullanım profili.Power_SavingPil ömrünü maksimuma çıkarmak için arka plan işlemlerini sınırlandırır.VulkanOyun ve grafik işlemlerinde GPU render motorunu Vulkan API'sine zorlar.Qualcomm_onlySnapdragon işlemcili cihazlara özel GPU ve işlemci optimizasyonları.CompileUygulama derleme ve DEX optimizasyonlarını tetikler (Android speed-profile).⚠️ Önemli Uyarı ve Yasal Sorumluluk ReddiYasal Uyarı: Bu araçlar sistem kaynaklarını yüksek seviyede manipüle eder. Scriptleri çalıştırmadan önce Windows üzerinde bir Sistem Geri Yükleme Noktası (System Restore Point) oluşturmanız ve Android cihazınızın yedeğini almanız şiddetle tavsiye edilir. Oluşabilecek sistem kararsızlıklarından kullanıcı sorumludur
