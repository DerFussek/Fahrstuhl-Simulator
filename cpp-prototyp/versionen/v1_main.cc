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

    TargetList.insert(TargetList.begin() + upperLimit + 1, NewTarget);
    upperLimit++;

    //Am Ende Sortieren
    SortBetweenLimits(lowerLimit, upperLimit, TargetList, dir);
    return upperLimit;
}

void AddTargetToList(Target newElement, std::vector<Target>& TargetList, int gondelPosition, bool& TuerAufCmd) {
    
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

    //Anfahrbarkeit
    bool isReachable = false;
    if((gondelPosition > newElement.level && !startDirection) || (gondelPosition < newElement.level && startDirection)) {
        isReachable = true;
    }
    
    if(rWechsel1 == -1 && rWechsel2 == -1) { //Keine Richtungswechsel
        TargetList.push_back(newElement);
        size_t nTargets = TargetList.size();
        if(newElement.direction == startDirection && isReachable) SortBetweenLimits(0, nTargets-1, TargetList, startDirection);
    } else if(rWechsel1 != -1 && rWechsel2 == -1) { // 1. Richtungswechsel
        if(newElement.direction == startDirection && isReachable) {
            InsertBetweenLimits(newElement, 0, rWechsel1, TargetList, startDirection);
        } else if(newElement.direction == startDirection && !isReachable) {
            TargetList.push_back(newElement);
        } else {
            size_t nTargets = TargetList.size();
            InsertBetweenLimits(newElement, rWechsel1+1, nTargets-1, TargetList, !startDirection);
        }
    } else if (rWechsel1 != -1 && rWechsel2 != -1) { // 2. Richtungswechsel
        size_t nTargets = TargetList.size();
        if(newElement.direction == startDirection && !isReachable) {
            InsertBetweenLimits(newElement, rWechsel2,  nTargets-1, TargetList, startDirection);
        } else if (newElement.direction == startDirection && isReachable) {
            InsertBetweenLimits(newElement, 0,  rWechsel1, TargetList, startDirection);
        } else {
            InsertBetweenLimits(newElement, rWechsel1+1,  rWechsel2-1, TargetList, !startDirection);
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

int main() {
    std::vector<Target> TargetList;
    bool TuerAufCmd = false;
    int GondelPos = 3;

    for (const Target& a : TargetList) {
        std::cout << "Etage " << a.level
                  << ", Richtung " << DirectionToString(a.direction) << "\n";
    }

    return 0;
}