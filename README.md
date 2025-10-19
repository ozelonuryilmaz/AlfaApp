# AlfaApp: iOS Film Keşif ve Oynatma Platformu

AlfaApp, modüler **Clean Architecture** ve **MVVM-C** prensipleri üzerine inşa edilmiş, performans ve güvenlik odaklı modern bir iOS uygulamasıdır. Bu proje, kullanıcıların filmleri keşfetmesini sağlayan `MovieExplorer` ve özel `AlfaPlayerKit (AVPlayer)` ile video oynatma deneyimi sunan `MoviePlayer` modüllerini içermektedir.

<div style="display: flex; gap: 10px;">
  <img src="https://raw.githubusercontent.com/ozelonuryilmaz/AlfaApp/tree/main/AlfaApp/AppCore/Resources/Assets/MovieExplorer.gif" alt="MovieExplorer" width="300"/>
  <img src="https://raw.githubusercontent.com/ozelonuryilmaz/AlfaApp/tree/main/AlfaApp/AppCore/Resources/Assets/MoviePlayer.gif" alt="MoviePlayer" width="300"/>
</div>

---

## 🚀 Öne Çıkan Özellikler

* **Modüler Film Keşfi**: Kategoriler arası yatay (swipe) geçiş ve dikeyde sonsuz kaydırma (pagination) ile zengin bir keşif deneyimi.
* **Durum Koruma**: Kategori geçişlerinde scroll pozisyonu ve yüklenen sayfa (page) korunur, kullanıcı kaldığı yerden devam eder.
* **Gelişmiş Cache**: Kategori verileri cache'lenir; REST API istekleri optimize edilerek gereksiz ağ çağrılarının önüne geçilir.
* **Özel Video Oynatıcı**: `AlfaPlayerKit` (Local SPM) ile geliştirilmiş, ileri/geri sarma, duraklatma, ve yatay mod desteği sunan tam özellikli video oynatıcı.
* **Güvenli Veri Erişimi**: API Key ve video URL'leri gibi hassas veriler, `Firebase Cloud Functions` ve `Secret Manager` üzerinden güvenli bir şekilde alınır.
* **Gelişmiş Güvenlik**: Jailbreak tespiti, SSL Pinning ve kod gizleme gibi çok katmanlı güvenlik önlemleri.
* **Modern Arayüz**: Programmatic UIKit, Dark/Light Mode, iPhone/iPad (Evrensel) ve Landscape desteği.
* **Otomatize Kaynak Yönetimi**: `SwiftGen` ile localize edilebilir metinler ve renk paletleri otomatik olarak yönetilir.

---

## 🏛️ Mimari ve Tasarım

Proje, sürdürülebilir ve ölçeklenebilir bir yapı sağlamak için endüstri standardı prensiplere dayanmaktadır.

* **Clean Architecture**: Sorumluluklar `App` (Presentation), `Domain` ve `Data` katmanlarına net bir şekilde ayrılmıştır.
* **MVVM-C**: Sunum katmanı, UI (`ViewController` + `RootView`), durum yönetimi (`ViewModel`), iş mantığı (`VMLogic`) ve navigasyon (`Coordinator`) arasında net bir sorumluluk ayrımı ile MVVM-C mimarisini uygular.
* **Modülerlik**: Her özellik (feature) kendi modülü içinde geliştirilmiştir. Yeni modüller, `AppCore` altında tanımlı `AlfaDevModule` template'i kullanılarak hızlıca oluşturulur.
* **Dependency Injection (DI)**: Modül bağımlılıkları `Builder` deseni kullanılarak enjekte edilir, bu da test edilebilirliği ve esnekliği artırır.
* **Reaktif Programlama**: Kullanıcı etkileşimleri ve veri akışları `Combine` framework'ü ile reaktif olarak yönetilir. Modern asenkron operasyonlar için `Async/await` kullanılır.
* **Protokol Odaklı Programlama (POP)**: Soyutlamalar ve esneklik için `IViewModel`, `IRepository`, `ICoordinator` gibi protokoller yaygın olarak kullanılır.

---

## 🛠️ Teknoloji Yığını

### Core
* **Platform**: iOS 15.0+
* **Dil**: Swift 5.x
* **UI**: Programmatic UIKit (Auto Layout)
* **Concurrency**: Combine, Async/await, Thread Management

### Mimari ve Prensipler
* MVVM-C (Model-View-ViewModel-Coordinator)
* Clean Architecture (Data, Domain, Presentation katmanları)
* Dependency Injection (DI)
* SOLID, OOP, POP
* State Management

### Bağımlılıklar (Swift Package Manager)

#### Locale Paketler
* **AlfaPlayerKit**: `AVPlayer` üzerine inşa edilmiş, özel kontroller sunan video oynatıcı kütüphanesi.
* **AlfaData**: Data katmanı bileşenlerini ve modellerini içerir.
* **AlfaDomain**: Domain katmanı varlıklarını (entities) ve protokollerini içerir.

#### Remote Paketler
* **Kingfisher**: Görüntü yükleme ve cache'leme işlemlerini performanslı bir şekilde yönetir.
* **Firebase**:
    * `FirebaseFunctions`: Güvenli backend işlemleri ve `Secret Manager` erişimi için kullanılır.
    * `FirebaseAppCheck`: Uygulama doğrulama (App Attest, DeviceCheck) entegrasyonu.
* **SecurityKit**: Jailbreak, debugger ve reverse engineering tespiti sağlar.
* **TrustKit**: MITM (Man-in-the-Middle) saldırılarına karşı SSL Pinning uygular.
* **ConfidentialKit**: Kod içerisindeki kritik verilerin gizlenmesi (obfuscation) için kullanılır.

### Araçlar (Tooling)
* **SwiftGen**: `strings`, `colors` gibi kaynak dosyalarını otomatik olarak `enum`'lara dönüştürür.
* **Git**: Sürüm kontrolü.

---

## 🔐 Güvenlik Katmanı

Uygulama, hem cihaz hem de ağ düzeyinde kapsamlı güvenlik önlemleri ile donatılmıştır:

1.  **Cihaz Güvenliği (`SecurityKit`)**:
    * Jailbreak tespiti.
    * Reverse engineering girişimlerini engelleme.
    * Debugger (hata ayıklayıcı) ve MSHookFunction tespiti.

2.  **Ağ Güvenliği (`TrustKit`)**:
    * **SSL Pinning**: Ağ isteklerinin yalnızca güvenilir, pin'lenmiş sertifikalara sahip sunucularla yapılmasını zorunlu kılarak MITM saldırılarını engeller.

3.  **Hassas Veri Yönetimi (`Firebase`)**:
    * API Key ve Video URL'leri gibi hassas veriler, `Firebase Cloud Functions` aracılığıyla `Secret Manager`'dan çekilir.
    * Bu veriler cihazda veya In-Memory'de tutulmadan doğrudan kullanılır.

4.  **İstek Doğrulama (`App Check`)**:
    * `App Attest` ve `DeviceCheck` entegrasyonları (Apple Geliştirici Hesabı gereksinimi nedeniyle şu an aktif değil) ile Cloud Function'lara gelen isteklerin yalnızca geçerli ve güvenilir uygulama kopyalarından geldiği doğrulanır.

5.  **Kod Güvenliği (`ConfidentialKit`)**:
    * Kritik öneme sahip kod blokları ve algoritmalar, reverse engineering çabalarını zorlaştırmak için gizlenir (obfuscate).

---

## 🧪 Test Stratejisi

Projenin kararlılığını ve güvenilirliğini sağlamak amacıyla testler yazılmıştır:

* **Unit Testler**:
    * `MovieExplorer` ve `MoviePlayer` modüllerinin `ViewModel` ve `VMLogic` katmanları için Unit Testler.
    * İş mantığı, validasyonlar ve durum geçişleri kapsamlı bir şekilde test edilmiştir.
* **Swift-Testing**:
    * `AlfaPlayerKit` (SPM) kütüphanesinin fonksiyonelliği, yeni nesil `swift-testing` kütüphanesi kullanılarak test edilmiştir.

---

## 📋 Gereksinimler

* iOS 15.0+
* Xcode 14.0+
* Swift 5.7+

