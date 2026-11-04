#include <iostream>
#include <vector>

enum Direction { Hoch, Runter, Stehen };

struct Target {
    Direction direction;
    int Floor;

    bool operator==(const Target& other) const {
        return direction == other.direction && Floor == other.Floor;
    }
};

void AddTargetToList(Target newElement, std::vector<Target>& TargetList, int gondelPosition, bool& TuerAufCmd) {
    
    //Wenn Liste Leer
    if(TargetList.size() == 0) {
        TargetList.push_back(newElement);
        return;
    }

    //Wenn identischer Aufruf vorhanden --> Ignorieren
    for(Target curTarget : TargetList) {
        if(curTarget == newElement) return;
    }

    //Marker erstellen
    int Marker1 = -1; 
    int Marker2 = -1;
    Direction StartDirection = TargetList[0].direction;
    for(int i = 0; i < 10; i++) {
        if(TargetList[i].direction != StartDirection) {
            Marker1 = i-1;
            break;
        }
    }

    for(int i = Marker1; i < 10; i++) {
        if(TargetList[i].direction == StartDirection) {
            Marker2 == i;
            break;
        }
    }

}

//Anzeige
const char* DirectionToString(Direction d) {
    switch (d) {
        case Hoch:   return "hoch";
        case Runter: return "runter";
        case Stehen: return "stehen";
    }
    return "?";
}

int main() {
    std::vector<Target> TargetList = {
        {Hoch, 3},
        {Hoch, 4},
        {Hoch, 5},
        {Runter, 4},
        {Runter, 3},
        {Runter, 2},
        {Hoch, 1},
    };
    bool TuerAufCmd = false;
    int GondelPos = 3;

    for (const Target& a : TargetList) {
        std::cout << "Etage " << a.Floor
                  << ", Richtung " << DirectionToString(a.direction) << "\n";
    }

    return 0;
}