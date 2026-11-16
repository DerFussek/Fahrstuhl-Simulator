// 20 Testfaelle fuer AddTargetToList aus main2.cc
// Kompilieren:  g++ -std=c++17 tests.cc -o tests      (oder cl /EHsc tests.cc)
// Notation:     R3 = Ruf Etage 3 Richtung rauf, A3 = Ruf Etage 3 Richtung abwaerts
//               Etagen 1..6 (1 = unterstes Stockwerk, wie in TD_Target)

#define main main_aus_main2      // main() aus main2.cc umbenennen
#include "main.cc"
#undef main

#include <string>

static int bestanden = 0, fehlgeschlagen = 0;

static std::string Txt(const std::vector<Target>& l) {
    std::string s;
    for (const Target& t : l) s += std::string(" ") + (t.direction == Rauf ? "R" : "A") + std::to_string(t.level);
    return l.empty() ? " (leer)" : s;
}

static void Check(int nr, const char* name, std::vector<Target> liste, int pos, Target neu,
                  const std::vector<Target>& soll, bool sollTuerAuf = false) {
    std::string vorher = Txt(liste);
    bool tuerAuf = false;
    AddTargetToList(neu, liste, pos, tuerAuf);

    bool ok = (liste == soll) && (tuerAuf == sollTuerAuf);
    ok ? bestanden++ : fehlgeschlagen++;

    std::printf("%s %2d %-44s Pos %d |%s + %s%d\n", ok ? "[OK]  " : "[FAIL]", nr, name, pos,
                vorher.c_str(), neu.direction == Rauf ? "R" : "A", neu.level);
    if (!ok) {
        std::printf("          soll:%s%s\n", Txt(soll).c_str(), sollTuerAuf ? "  (TuerAufCmd = true)" : "");
        std::printf("          ist: %s%s\n", Txt(liste).c_str(), tuerAuf ? "  (TuerAufCmd = true)" : "");
    }
}

int main() {
    const Direction R = Rauf, A = Runter;

    // --- Grundfaelle ---------------------------------------------------------------
    Check( 1, "Leere Liste",                            {},                 1, {R,3}, {{R,3}});
    Check( 2, "Duplikat wird ignoriert",                {{R,2},{R,4}},      1, {R,4}, {{R,2},{R,4}});
    Check( 3, "Gleiche Etage, andere Richtung",         {{R,2},{R,4}},      1, {A,4}, {{R,2},{R,4},{A,4}});

    // --- Abschnitt 1: gleiche Richtung, noch erreichbar ----------------------------
    Check( 4, "Auf: vorne einfuegen",                   {{R,3},{R,5}},      1, {R,2}, {{R,2},{R,3},{R,5}});
    Check( 5, "Auf: hinten einfuegen",                  {{R,2},{R,3}},      1, {R,5}, {{R,2},{R,3},{R,5}});
    Check( 6, "Ab: in die Mitte einfuegen",             {{A,4},{A,2}},      6, {A,3}, {{A,4},{A,3},{A,2}});
    Check( 7, "Ab: vorne einfuegen",                    {{A,3},{A,1}},      6, {A,5}, {{A,5},{A,3},{A,1}});

    // --- Gleiche Richtung, schon vorbei -> Abschnitt 3 -----------------------------
    Check( 8, "Auf: Etage schon passiert",              {{R,4},{R,5}},      3, {R,2}, {{R,4},{R,5},{R,2}});
    Check( 9, "Ab: Etage schon passiert",               {{A,3},{A,2}},      4, {A,5}, {{A,3},{A,2},{A,5}});

    // --- Gegenrichtung -> Abschnitt 2 ----------------------------------------------
    Check(10, "Gegenrichtung, noch kein Abschnitt 2",   {{R,2},{R,4}},      1, {A,3}, {{R,2},{R,4},{A,3}});
    Check(11, "Gegenrichtung, Mitte von Abschnitt 2",   {{R,2},{R,4},{A,5},{A,1}}, 1, {A,3},
                                                        {{R,2},{R,4},{A,5},{A,3},{A,1}});
    Check(12, "Gegenrichtung, ganz oben (A6)",          {{R,2},{R,4},{A,5},{A,3}}, 1, {A,6},
                                                        {{R,2},{R,4},{A,6},{A,5},{A,3}});
    Check(13, "Start ab, Gegenrichtung R2",             {{A,5},{A,3}},      6, {R,2}, {{A,5},{A,3},{R,2}});
    Check(14, "Start ab, Mitte von Abschnitt 2",        {{A,5},{A,3},{R,2},{R,4}}, 6, {R,3},
                                                        {{A,5},{A,3},{R,2},{R,3},{R,4}});

    // --- Zwei Richtungswechsel (Abschnitt 1 + 2 + 3) -------------------------------
    Check(15, "3 Abschnitte, neu in Abschnitt 1",       {{R,4},{R,5},{A,4},{A,2},{R,1}}, 2, {R,3},
                                                        {{R,3},{R,4},{R,5},{A,4},{A,2},{R,1}});
    Check(16, "3 Abschnitte, neu in Abschnitt 3",       {{R,4},{R,5},{A,4},{A,2},{R,1}}, 3, {R,2},
                                                        {{R,4},{R,5},{A,4},{A,2},{R,1},{R,2}});
    Check(17, "3 Abschnitte, neu in Abschnitt 2 (A6)",  {{R,4},{R,5},{A,4},{A,2},{R,1}}, 2, {A,6},
                                                        {{R,4},{R,5},{A,6},{A,4},{A,2},{R,1}});
    Check(18, "Abschnitt 2 leer, aber 3 vorhanden",     {{R,4},{R,5},{R,2}}, 3, {A,3},
                                                        {{R,4},{R,5},{A,3},{R,2}});

    // --- Randfaelle (Verhalten erst noch festlegen!) -------------------------------
    // Laut Diagramm "Richtungswahl nach Tuerschluss": Ruf in aktueller Etage -> Tuer oeffnen,
    // nicht in die Liste aufnehmen.
    Check(19, "Ruf auf aktueller Etage -> Tuer auf",    {{R,4},{R,5}},      3, {R,3}, {{R,4},{R,5}}, true);

    // vTargets hat in 800xA nur 10 Plaetze. Moeglich sind aber 12 verschiedene Rufe
    // (R1..R6 und A1..A6). Hier angenommen: 11. Ruf wird verworfen.
    Check(20, "Liste voll (10 Plaetze in 800xA)",
          {{R,2},{R,3},{R,4},{R,5},{R,6},{A,5},{A,4},{A,3},{A,2},{A,1}}, 1, {A,6},
          {{R,2},{R,3},{R,4},{R,5},{R,6},{A,5},{A,4},{A,3},{A,2},{A,1}});

    std::printf("\n%d bestanden, %d fehlgeschlagen\n", bestanden, fehlgeschlagen);
    return fehlgeschlagen;
}