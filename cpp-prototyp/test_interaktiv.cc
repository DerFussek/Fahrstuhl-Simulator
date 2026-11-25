// Interaktiver Test fuer AddTargetToList aus main.cc
// Bauen (MSVC):  cl /EHsc /std:c++17 test_interaktiv.cc
// Bauen (g++):   g++ -std=c++17 test_interaktiv.cc -o test_interaktiv
// Die Datei muss im selben Ordner wie main.cc liegen (sie bindet main.cc ein).
//
// Ablauf: 1. Startstockwerk der Gondel eingeben (1..6, 1 = EG)
//         2. Immer wieder ein neues Ziel eingeben, danach wird die Liste ausgegeben.
//
// Eingabe eines Ziels:  U5 = Etage 5, Richtung hoch (Up)      D3 = Etage 3, Richtung runter (Down)
//                       (Gross/Klein egal, auch "5u" geht. EG nur U, Etage 6 nur D.)
// Befehle:              n = naechstes Stockwerk erreicht (erstes Element wird geloescht, Gondel faehrt dorthin)
//                       g <Etage> = Gondel auf Etage setzen     c = Liste leeren     q = Ende

#define main main_aus_main_cc
#ifndef FUNKTION
#define FUNKTION "main.cc"
#endif
#include FUNKTION
#undef main

#include <cctype>
#include <string>

static std::string Txt(const std::vector<Target>& l) {
    if (l.empty()) return "(leer)";
    std::string s;
    for (size_t i = 0; i < l.size(); i++) {
        if (i) s += "  ";
        s += (l[i].direction == Rauf ? "U" : "D") + std::to_string(l[i].level);
    }
    return s;
}

static bool LiesEtage(const std::string& t, int& etage) {
    if (t.size() != 1 || t[0] < '1' || t[0] > '6') return false;
    etage = t[0] - '0';
    return true;
}

// "U5", "d3", "5u" ...  -> Target
static bool ParseZiel(const std::string& eingabe, Target& ziel) {
    char richtung = 0;
    std::string zahl;
    for (char c : eingabe) {
        if (std::isspace((unsigned char)c)) continue;
        char k = (char)std::toupper((unsigned char)c);
        if (k == 'U' || k == 'D') { if (richtung) return false; richtung = k; }
        else if (std::isdigit((unsigned char)c)) zahl += c;
        else return false;
    }
    int etage;
    if (!richtung || !LiesEtage(zahl, etage)) return false;
    if (richtung == 'U' && etage == 6) { std::cout << "  Etage 6 hat keinen Hoch-Taster.\n"; return false; }
    if (richtung == 'D' && etage == 1) { std::cout << "  Etage 1 (EG) hat keinen Runter-Taster.\n"; return false; }
    ziel.direction = (richtung == 'U') ? Rauf : Runter;
    ziel.level = etage;
    return true;
}

static void Zeige(int pos, const std::vector<Target>& l) {
    std::cout << "  Gondel in Etage " << pos << "   Liste (" << l.size() << "/10): " << Txt(l) << "\n";
}

int main() {
    std::vector<Target> liste;
    bool tuerAufCmd = false;
    int pos = 0;
    std::string zeile;

    while (true) {
        std::cout << "Startstockwerk der Gondel (1-6): ";
        if (!std::getline(std::cin, zeile)) return 0;
        if (LiesEtage(zeile, pos)) break;
        std::cout << "  Bitte eine Zahl von 1 bis 6 eingeben.\n";
    }
    Zeige(pos, liste);

    while (true) {
        std::cout << "\nNeues Ziel (z.B. U5 / D3)  [n | g <Etage> | c | q]: ";
        if (!std::getline(std::cin, zeile)) break;

        size_t a = zeile.find_first_not_of(" \t");
        if (a == std::string::npos) continue;
        zeile = zeile.substr(a);
        char cmd = (char)std::tolower((unsigned char)zeile[0]);

        if (cmd == 'q' && zeile.size() == 1) break;
        if (cmd == 'c' && zeile.size() == 1) { liste.clear(); Zeige(pos, liste); continue; }
        if (cmd == 'n' && zeile.size() == 1) {
            if (liste.empty()) { std::cout << "  Liste ist leer.\n"; continue; }
            pos = liste[0].level;
            liste.erase(liste.begin());
            Zeige(pos, liste);
            continue;
        }
        if (cmd == 'g' && zeile.size() > 1) {
            int e;
            std::string rest = zeile.substr(1);
            size_t b = rest.find_first_not_of(" \t");
            if (b != std::string::npos && LiesEtage(rest.substr(b), e)) { pos = e; Zeige(pos, liste); }
            else std::cout << "  Etage 1-6 angeben, z.B. g 4\n";
            continue;
        }

        Target ziel;
        if (!ParseZiel(zeile, ziel)) {
            std::cout << "  Ungueltig. Beispiele: U5 (Etage 5 hoch), D3 (Etage 3 runter).\n";
            continue;
        }

        size_t vorher = liste.size();
        AddTargetToList(ziel, liste, pos, tuerAufCmd);
        if (liste.size() == vorher) std::cout << "  (Ruf nicht eingefuegt: Duplikat oder Liste voll)\n";
        Zeige(pos, liste);
    }
    return 0;
}
