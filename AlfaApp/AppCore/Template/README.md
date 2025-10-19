## AlfaApp iOS Template Kullanım Rehberi

Bu rehber, Alfa iOS mobil uygulaması için hazırlanan modüler template'’inin nasıl kurulacağı ve geliştirileceği hakkında bilgiler içerir. 
Medium yazımı okumanızı tavsiye ederim. -> https://medium.com/@ozelonuryilmaz/build-faster-and-cleaner-ios-apps-with-a-modular-swift-template-e218b665afc7

---

### 🚀 Kurulum Adımları

1. **Xcode'u kapatın.**
2. Zip içerisindeki dosyalara (`AlfaDevModule.xctemplate`, `AlfaTestModule.xctemplate`) erişin.
3. Şu dizine gidin:
   `/Applications/Xcode.app > Show Package Contents > Contents > Developer > Library > Xcode > Templates > File Templates`
4. Dosyaları bu dizine kopyalayın (yönetici şifresi sorarsa onaylayın).
5. Xcode'u yeniden açın.
6. Yeni dosya oluştururken "module" araması yapın, **AlfaDevModule**'u seçin.
7. Sadece modül adını yazın (örneğin: `MovieExplorer`) → aşağıdaki dosyalar oluşur:

---

### 📆 Oluşan Dosyalar ve Açıklamaları

- **MovieExplorerBuilder.swift**: Modülün tüm bağımlılıklarını (`Repository`, `ViewModel`, `Coordinator`, `Params`) oluşturan yapıdır. Modül başlatılmadan önce gerekli tüm bileşenleri oluşturur ve bağımlılık enjeksiyonu (DI) işlemlerini gerçekleştirir. Bileşen içeriğine Interface(I) Protokolü üzerinden erişim sağlanır.

- **MovieExplorerCoordinator.swift**: Ekranın açılmasını sağlayan ve ekranlar arası geçişleri yöneten yapıdır. `push`, `present`, `dismiss` gibi navigation, present işlemleri burada kontrol edilir. Aynı zamanda bir önceki sayfaya veri iletimi için `outputDelegate` protokolünü taşır.

- **MovieExplorerParams.swift**: Modülün ilk açılışında ihtiyaç duyduğu dış parametreleri (örneğin: id, başlık, önceden seçilmiş veri) tutar. `Builder` aracılığıyla `VMLogic` bileşenine aktarılır.

- **MovieExplorerRepository.swift**: Veriye erişimi soyutlayan yapıdır. API, local database veya cache gibi veri kaynaklarıyla iletişimi burada sağlarsın. `ViewModel` yalnızca bu yapı üzerinden veri çeker, kaynakla doğrudan temas etmez.

- **MovieExplorerRootView.swift**: UI bileşenlerinin (`UIButton`, `UILabel`, `UICollectionView`, `UITextField` vb.) yer aldığı ve sadece görsel katmanı temsil eden sınıftır. Her ekran için özel bir `RootView` oluşturularak, UI ViewController'dan ayrıştırılır.

- **MovieExplorerViewController.swift**: Lifecycle yönetiminin yapıldığı ve RootView(UI) ile ViewModel arasındaki köprüyü kuran sınıftır. Event binding, Combine abonelikleri, outputDelegate ile bir önceki sayfalara veri aktarımı gibi işlemler burada yönetilir.

- **MovieExplorerViewModel.swift**: Ekranın iş akışını yöneten ana sınıftır. Kullanıcı etkileşimlerine tepki verir, `Repository` ile veri alışverişini yönetir, iş mantığını `VMLogic` katmanına devreder ve Combine aracılığıyla UI’a uygun veri üretir. UI'daki tüm veri akışı bu sınıf üzerinden kontrol edilir.

- **MovieExplorerVMLogic.swift**: `ViewModel`’a yardımcı olan, ekranın UI davranışlarını yöneten aktif iş mantığı katmanıdır. Validasyonlar (`isEmailValid`, `isFormComplete`), iş kuralları (max media sayısı, boş alan kontrolü), dönüşümler (entity → UI model) gibi görevleri burada tanımlar.

---

### 🛠️ Template Genel Mimari Yapısı

```
Presentation Layer:
    - ViewController
    - RootView
    - VMLogic
    - ViewModel

Domain Layer:
    - Protocol tanımları

Data Layer:
    - Repository
    - Service / RemoteData 
    
Coordinator Layer:
    - Coordinator
    - Params / OutputDelegate
```

---

### ✅ Geliştirme Esasları

#### 1. Temel Prensipler

- SOLID, OOP, POP, Design Patterns, Best Practice prensiplerine uygunluk.
- Clean Architecture katman ayrımı.
- MVVM-C mimarisine bağlılık.
- Combine ile reactive yapı kurulumu.
- Memory Management (cancelBag, weak capture list kullanımı).
- Performans odaklı geliştirme (lazy, final, struct kullanımı).


#### 2. Clean Architecture Uyumlu Yapı

- **Builder**: Modül bağımlılıklarını oluşturan ve inject eden yapıdır. DI prensibini uygular.
- **Coordinator**: Navigation mantığını yönetir. Sayfalar arası geçiş, present/dismiss işlemleri burada yapılır.
- **ViewModel**: UI ile iş mantığını birbirinden ayıran, kullanıcı etkileşimlerine tepki vererek veri akışını yöneten katmandır. Combine ile UI'ya veri sağlar.
- **VMLogic**: ViewModel'in iş mantığını destekleyen yardımcı katmandır. Validasyon, karar verme, veri dönüştürme gibi aktif işlemleri yapar.
- **RootView**: Sadece UI bileşenlerini içerir. Görsel düzen, layout ve bileşen yerleşimi dışında hiçbir mantık içermez.
- **Repository**: Veriye erişim (API, local database, cache vb.) işlemlerini soyutlayan yapıdır. ViewModel, veriyi bu yapı üzerinden çeker, detaylardan bağımsız kalır.


#### 3. Performans ve Bellek Yönetimi

- `final`, `lazy`, `weak`, `struct`, `enum` gibi yapılar kullanılarak memory optimizasyonu sağlanır.
- Combine abonelikleri `cancelBag` ile tutulur; `deinit` ile otomatik iptal edilir.
- Ağır işlemler `.subscribe(on:)` ile background queue’a alınır, UI güncellemeleri `.receive(on: .main)` ile yapılır.
- `DispatchQueue.main.async {}` dışı UI güncellemesi yapılmaz.
- `prepareForReuse()` eksikliği scroll performansını bozar; hücreler sade tutulmalı.
- JSON parsing büyükse arka planda yapılmalı; `Decodable` işlemleri CPU’ya bindirilmemeli.
- `shadow`, `maskToBounds`, `cornerRadius` gibi UI efektleri fazla kullanıldığında FPS düşürebilir.
- `killed: 9` veya `Terminated due to memory issue` terminal uyarıları memory leak belirtisidir; `deinit` logları kullanılmalı.
- Xcode → Debug Memory Graph, Instruments (Leaks, Time MovieExplorerr) aktif kullanılmalıdır.


#### 4. Bazı `Design Patterns` Kullanımları

| Pattern                  | Kullanım Yeri |
|--------------------------|---------------|
| Builder                  | Modül üretimi (`Builder.generate(...)`) |
| Coordinator              | Navigation akışı yönetimi |
| MVVM-C                   | Mimarinin genel yapısı |
| Observer                 | Combine üzerinden state/event izleme |
| Dependency Injection     | `Builder` üzerinden bağımlılık aktarımı |
| Factory                  | `Builder` içinde dinamik nesne üretimi |
| Strategy                 | `VMLogic` ile validasyon/karar yapılarının dışa alınması |
| Adapter                  | `Repository` → servis response’larını ViewModel uyumlu hale dönüştürme |
| Template Method          | `BaseViewController` içinde override edilmesi gereken UI akış fonksiyonları |
| Protocol-Oriented        | `IViewModel`, `ICoordinator`, `IRepository` gibi protokollerle esneklik |
| Delegate                 | `outputDelegate` ile bir önceki ekrana veri geri iletimi |


