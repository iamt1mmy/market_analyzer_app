# 📊 Market Analyzer Pro — FinTech Comparison Tool

**Market Analyzer Pro** este o aplicație mobilă avansată dezvoltată în **Flutter**, concepută pentru analiza și compararea performanței activelor financiare din piețe diferite (Acțiuni, Criptomonede și Indici). Proiectul rezolvă problema comparării activelor cu valori nominale diferite prin tehnici de **normalizare procentuală** și **conversie valutară în timp real**.

---

## ✨ 1. Caracteristici Principale

| Funcție | Descriere |
| :--- | :--- |
| 📉 Duel Financiar | Compară simultan două active (ex: Bitcoin vs. Apple sau Tesla vs. Nvidia). |
| ⚖️ Normalizare % | Alinierea ambelor active la punctul 0% pentru a evidenția randamentul pur. |
| 💱 Multi-Currency | Suport pentru afișarea prețurilor în **USD**, **EUR** și **RON**. |
| 🌓 Adaptive UI | Design inteligent cu suport pentru **Light Mode** și **Dark Mode**. |
| 📅 Interval Custom | Selectarea unei perioade istorice specifice prin DateRangePicker. |
| 📤 Smart Share | Generarea unui raport de analiză text și partajarea acestuia prin mesagerie. |

---

## 🛠️ 2. Stack Tehnologic (Dependențe)

Proiectul utilizează cele mai noi standarde din ecosistemul Flutter:

* **Framework:** Flutter (Dart)
* **Grafice:** fl_chart — Randare vectorială pentru evoluția prețurilor.
* **Networking:** http — Comunicare RESTful cu serverele Twelve Data.
* **Formatare:** intl — Gestionarea precisă a monedelor și a datelor calendaristice.
* **Sistem:** share_plus — Integrarea funcției de partajare nativă a sistemului.

---

## 📂 3. Arhitectura și Structura Proiectului

Codul este organizat conform principiilor **Clean Architecture**, asigurând o separare clară între Logica de Business și UI:

```text
lib/
│
├── 📁 models/
│   ├── asset_model.dart          # Definirea entității de activ
│   └── chart_data_model.dart     # Logica pentru prețuri și calcul profit
│
├── 📁 services/
│   ├── api_service.dart          # Comunicarea cu Twelve Data (Istoric)
│   ├── currency_service.dart     # Preluarea ratelor de schimb live
│   └── share_service.dart        # Formatarea raportului de analiză
│
├── 📁 screens/
│   ├── compare_screen.dart       # Ecranul principal și gestionarea stării
│   └── 📁 widgets/               # Sub-componente UI reutilizabile
│       ├── chart_widget.dart     # Vizualizarea grafică a datelor
│       ├── control_panel.dart    # Selectorii de active și monedă
│       ├── comparison_table.dart # Tabelul detaliat cu cifrele exacte
│       └── winner_card.dart      # Cardul care indică performanța superioară
│
├── 📁 utils/
│   ├── constants.dart            # API Key, culori și active suportate
│   ├── formatter.dart            # Funcții pentru formatarea monedelor
│   └── helpers.dart              # Algoritmul de normalizare a datelor
│
└── 🚀 main.dart                  # Punctul de intrare și temele Dark/Light

---

## 📈 4. Metodologia de Calcul (Algoritm)

Pentru a asigura o comparație echitabilă între active cu prețuri unitare foarte diferite (ex: Bitcoin la $60,000 și Apple la $180), aplicația implementează un algoritm de **Normalizare la Bază 0**. 

Fiecare punct de pe grafic este transformat dintr-un preț brut într-o variație procentuală față de prima zi a intervalului selectat (P_start), folosind formula:

Variație % = ((P_curent - P_start) / P_start) * 100

Această metodă permite vizualizarea randamentului investiției în termeni de eficiență procentuală, eliminând bariera valorii nominale a activului.

---

## 🚀 5. Instalare și Configurare

Pentru a rula proiectul local, urmați acești pași:

1. **Pregătirea mediului:** Asigurați-vă că aveți Flutter SDK instalat și configurat corect (flutter doctor).
2. **Descărcarea dependințelor:** Deschideți terminalul în folderul rădăcină al proiectului și rulați: flutter pub get
3. **Configurare API Key:** Obțineți o cheie gratuită de la Twelve Data. Deschideți fișierul lib/utils/constants.dart și înlocuiți valoarea existentă cu cheia proprie.
4. **Lansare:** Conectați un dispozitiv fizic sau porniți un emulator și executați: flutter run

---

## 🎓 6. Rolul Proiectului și Obiective

Această aplicație reprezintă componenta practică a **Lucrării de Licență**, având ca obiective fundamentale următoarele puncte:

* **Demonstrarea competențelor tehnice** în dezvoltarea aplicațiilor mobile moderne folosind framework-ul Flutter și limbajul Dart.
* **Gestionarea fluxurilor de date asincrone** prin integrarea API-urilor financiare RESTful.
* **Implementarea managementului de stare** pentru teme dinamice (Dark/Light Mode) și prelucrarea datelor în timp real.
* **Validarea conceptelor matematice** prin vizualizarea grafică a indicatorilor de performanță financiară normalizați.

---
© 2026 - **Market Analyzer Pro** | Proiect Dezvoltat pentru Licență