#include <iostream>
#include <vector>

enum Direction { Runter, Rauf };

struct Target {
    Direction direction;
    int level;

    bool operator==(const Target& other) const {
        return direction == other.direction && level == other.level;
    }
};

// Sortiert TargetList[lowerLimit..upperLimit] (beide Grenzen inklusive) nach Floor.
// dir = true  -> aufsteigend (1, 2, 3, ...)
// dir = false -> absteigend  (5, 4, 3, ...)
void SortBetweenLimits(int lowerLimit, int upperLimit, std::vector<Target>& TargetList, bool dir) {
    // Grenzen absichern
    if (lowerLimit < 0) lowerLimit = 0;
    if (upperLimit > (int)TargetList.size() - 1) upperLimit = (int)TargetList.size() - 1;
    if (lowerLimit >= upperLimit) return;   // 0 oder 1 Element: nichts zu tun

    // Insertion Sort
    for (int i = lowerLimit + 1; i <= upperLimit; i++) {
        Target aktuell = TargetList[i];
        int j = i - 1;

        while (j >= lowerLimit &&
               (dir ? TargetList[j].level > aktuell.level
                    : TargetList[j].level < aktuell.level)) {
            TargetList[j + 1] = TargetList[j];   // nach rechts schieben
            j--;
        }
        TargetList[j + 1] = aktuell;
    }
}

int InsertBetweenLimits(Target NewTarget, int lowerLimit, int upperLimit,
                        std::vector<Target>& TargetList, bool dir) {
    int n = (int)TargetList.size();
    if (lowerLimit < 0) lowerLimit = 0;
    if (lowerLimit > n) lowerLimit = n;
    if (upperLimit > n - 1) upperLimit = n - 1;
    if (upperLimit < lowerLimit - 1) upperLimit = lowerLimit - 1;   // leerer Abschnitt

    // Ans Ende des Abschnitts einfuegen ...
    TargetList.insert(TargetList.begin() + upperLimit + 1, NewTarget);
    upperLimit++;

    // ... und den Abschnitt (jetzt ein Element groesser) sortieren
    SortBetweenLimits(lowerLimit, upperLimit, TargetList, dir);
    return upperLimit;
}

void AddTargetToList(Target newElement, std::vector<Target>& TargetList, int gondelPosition, bool& /*TuerAufCmd*/) {
    
    //Wenn Liste Leer
    if(TargetList.empty()) {
        TargetList.push_back(newElement);
        return;
    }

    //Wenn identischer Aufruf vorhanden --> Ignorieren
    for(Target curTarget : TargetList) {
        if(curTarget == newElement) return;
    }

    
    //Marker erstellen
    int rWechsel1 = -1; 
    int rWechsel2 = -1;
    Direction startDirection = TargetList[0].direction;
    
    //Erster Richtungswechsel
    for(int i = 1; i < (int)TargetList.size(); i++) {
        if(TargetList[i].direction != startDirection || (TargetList[i].direction == Rauf && TargetList[i-1].level > TargetList[i].level) 
            || (TargetList[i].direction == Runter && TargetList[i-1].level < TargetList[i].level)) {
            
            rWechsel1 = i-1;
            break;
        }
    }

    //Zweiter Richtungswechsel
    if(rWechsel1 != -1) {
        for(int i = rWechsel1 + 1; i < (int)TargetList.size(); i++) {
            if(TargetList[i].direction == startDirection) {
                rWechsel2 = i;
                break;
            }
        }
    }

    //Anfahrbarkeit: liegt das neue Ziel noch vor der Kabine?
    bool aufsteigend = (startDirection == Rauf);
    bool gleicheRichtung = (newElement.direction == startDirection);
    bool isReachable = (aufsteigend  && newElement.level > gondelPosition) ||
                       (!aufsteigend && newElement.level < gondelPosition);
    int nTargets = (int)TargetList.size();

    if (rWechsel1 == -1) {                       // Keine Richtungswechsel: nur Abschnitt 1
        if (gleicheRichtung && isReachable) {
            InsertBetweenLimits(newElement, 0, nTargets - 1, TargetList, aufsteigend);
        } else {
            TargetList.push_back(newElement);    // wird Abschnitt 2 bzw. 3
        }
    } else if (rWechsel2 == -1) {                // 1. Richtungswechsel: Abschnitt 1 + 2
        if (gleicheRichtung && isReachable) {
            InsertBetweenLimits(newElement, 0, rWechsel1, TargetList, aufsteigend);
        } else if (gleicheRichtung) {
            TargetList.push_back(newElement);    // wird Abschnitt 3
        } else {
            InsertBetweenLimits(newElement, rWechsel1 + 1, nTargets - 1, TargetList, !aufsteigend);
        }
    } else {                                     // 2. Richtungswechsel: Abschnitt 1 + 2 + 3
        if (gleicheRichtung && isReachable) {
            InsertBetweenLimits(newElement, 0, rWechsel1, TargetList, aufsteigend);
        } else if (gleicheRichtung) {
            InsertBetweenLimits(newElement, rWechsel2, nTargets - 1, TargetList, aufsteigend);
        } else {
            InsertBetweenLimits(newElement, rWechsel1 + 1, rWechsel2 - 1, TargetList, !aufsteigend);
        }
    }
}

//Anzeige
const char* DirectionToString(Direction d) {
    switch (d) {
        case Rauf:   return "hoch";
        case Runter: return "runter";
    }
    return "?";
}

void show(const std::vector<Target>& l){ for(auto&x:l) std::cout<<" "<<(x.direction==Rauf?"R":"A")<<x.level; }
void T(const char* name, std::vector<Target> l, int pos, Target neu){
  bool tuer=false; std::cout<<name<<"  vorher:"; show(l); AddTargetToList(neu,l,pos,tuer); std::cout<<"  -> nachher:"; show(l); std::cout<<"\n"; }
int main(){
  T("1 kein Wechsel, Gegenrichtung A3 (Pos 1)     ", {{Rauf,2},{Rauf,4}}, 1, {Runter,3});
  T("2 ein Wechsel, gleiche Richtung R3 (Pos 1)   ", {{Rauf,2},{Rauf,4},{Runter,5},{Runter,1}}, 1, {Rauf,3});
  T("3 ein Wechsel, Gegenrichtung A3 (Pos 1)      ", {{Rauf,2},{Rauf,4},{Runter,5},{Runter,1}}, 1, {Runter,3});
  T("4 zwei Wechsel, Gegenrichtung A3 (Pos 2)     ", {{Rauf,4},{Rauf,5},{Runter,4},{Runter,2},{Rauf,1}}, 2, {Runter,3});
  T("5 zwei Wechsel, Start Runter, R4 (Pos 5)     ", {{Runter,4},{Runter,2},{Rauf,3},{Rauf,5},{Runter,6}}, 5, {Rauf,4});
  T("6 zwei Wechsel, gleiche Ri. hinten R2 (Pos 3)", {{Rauf,4},{Rauf,5},{Runter,3},{Rauf,1}}, 3, {Rauf,2});
}