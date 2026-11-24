// Systematischer Test von AddTargetToList (aus ../main.cc)
// Notation: U5 = Ruf in Etage 5 Richtung hoch (Up), D5 = Ruf in Etage 5 Richtung runter (Down). Etage 1 = EG.
// Referenz: unabhaengige Umsetzung der Regel
//   Abschnitt 1: Fahrtrichtung (zum ersten Ziel), erreichbare Rufe mit passendem Pfeil + Umkehrpunkt
//   Abschnitt 2: Gegenrichtung (Pfeil passt), Abschnitt 3: Rest (nicht mehr erreichbar) -> wiederholt.
#include <iostream>
#include <vector>
#include <string>
#include <cstdio>
#include <algorithm>
#include <cstdlib>
#define main main_orig
#ifndef FUNKTION
#define FUNKTION "../main.cc"
#endif
#include FUNKTION
#undef main

typedef std::vector<Target> L;
static std::string S(const L& l){ if(l.empty()) return "(leer)"; std::string s; for(size_t i=0;i<l.size();i++){ if(i) s+=" "; s+=(l[i].direction==Rauf?"U":"D"); s+=std::to_string(l[i].level);} return s; }
static L P(const char* t){ L v; std::string s=t; for(size_t i=0;i+1<s.size();i++) if(s[i]=='U'||s[i]=='D'){ Target x; x.direction=s[i]=='U'?Rauf:Runter; x.level=s[i+1]-'0'; v.push_back(x);} return v; }

// ---- Referenz ----
static L Ref(int pos, bool hoch, L rest){
    L out;
    while(!rest.empty()){
        std::vector<int> idx;
        int ende = hoch ? 0 : 99; bool found=false;
        for(size_t i=0;i<rest.size();i++){
            bool voraus = hoch ? rest[i].level>=pos : rest[i].level<=pos;
            if(!voraus) continue;
            found=true;
            if(hoch) ende=std::max(ende,rest[i].level); else ende=std::min(ende,rest[i].level);
        }
        if(found){
            std::vector<Target> sweep; std::vector<Target> restNeu;
            for(size_t i=0;i<rest.size();i++){
                bool voraus = hoch ? rest[i].level>=pos : rest[i].level<=pos;
                bool pfeil  = hoch ? rest[i].direction==Rauf : rest[i].direction==Runter;
                if(voraus && (pfeil || rest[i].level==ende)) sweep.push_back(rest[i]); else restNeu.push_back(rest[i]);
            }
            std::stable_sort(sweep.begin(),sweep.end(),[&](const Target&a,const Target&b){ if(a.level!=b.level) return hoch ? a.level<b.level : a.level>b.level; bool pa=(hoch?a.direction==Rauf:a.direction==Runter), pb=(hoch?b.direction==Rauf:b.direction==Runter); return pa && !pb; });
            for(auto&t:sweep) out.push_back(t);
            rest=restNeu; pos=ende;
        }
        hoch=!hoch;
    }
    return out;
}
static L Norm(L l){ // gleiche Etage: Reihenfolge U/D egal (beide halten dort)
    for(size_t i=0;i+1<l.size();i++) if(l[i].level==l[i+1].level && l[i].direction<l[i+1].direction) std::swap(l[i],l[i+1]);
    return l; }
static bool gleich(const L&a,const L&b){ return S(Norm(a))==S(Norm(b)); }
static int cat[5]={0,0,0,0,0}; // 0 aktuelle Etage, 1 erstes Ziel verdraengt, 2 Mitnahme verpasst, 3 sonstige Reihenfolge
// Ref-Einfuegen: gleiche Vorgaben wie die Funktion (Duplikat/voll ignorieren, Richtung aus erstem Ziel)
static L RefAdd(L l, Target n, int pos){
    if(l.empty()){ l.push_back(n); return l; }
    if(l.size()>=10) return l;
    for(auto&t:l) if(t==n) return l;
    bool hoch = l[0].level>pos ? true : (l[0].level<pos ? false : l[0].direction==Rauf);
    l.push_back(n);
    return Ref(pos,hoch,l);
}
static bool verpasst(const L& l,int pos){   // Rufe auf dem Weg mit passendem Pfeil, die spaeter bedient werden
    int cur=pos;
    for(size_t i=0;i<l.size();i++){
        int z=l[i].level; if(z==cur) continue; bool up=z>cur; int lo=std::min(cur,z),hi=std::max(cur,z);
        for(size_t j=i+1;j<l.size();j++) if((l[j].direction==Rauf)==up && l[j].level>lo && l[j].level<hi) return true;
        cur=z; }
    return false; }

static int nr=0, fails=0; static std::string famName=""; static int famFail=0, famCnt=0;
static FILE* protokoll;
static void Fam(const char* n){ if(!famName.empty()) printf("  %-34s %3d Szenarien, %3d Fehler\n",famName.c_str(),famCnt,famFail); famName=n; famFail=0; famCnt=0; }
static void Run(int pos, const L& start, Target n, const L& erwartet0){
    // Ruf in der Gondeletage (neuer Ruf oder erstes Ziel): Liste bleibt, TuerAufCmd = true
    bool dupl=false; for(auto&q:start) if(q==n) dupl=true;
    bool aktEtage = !dupl && (start.empty() ? n.level==pos : (start[0].level==pos || (n.level==pos && n.direction==(start[0].level>pos?Rauf:Runter))));
    L erwartet = aktEtage ? start : erwartet0;
    L l=start; bool t=false; AddTargetToList(n,l,pos,t);
    bool ok = gleich(l,erwartet) && !verpasst(l,pos) && (t==aktEtage);
    nr++; famCnt++;
    if(!ok){ fails++; famFail++;
        bool mit=verpasst(l,pos);
        if(n.level==pos || (!start.empty() && start[0].level==pos)) cat[0]++;
        else if(mit) cat[2]++;
        else if(!start.empty() && !(erwartet[0]==start[0])) cat[1]++;
        else cat[3]++; }
    fprintf(protokoll,"%3d %s Gondel=%d [%s] + %s%d -> [%s] erwartet [%s]%s\n",nr,ok?"OK  ":"FAIL",pos,S(start).c_str(),n.direction==Rauf?"U":"D",n.level,S(l).c_str(),S(erwartet).c_str(),(!ok&&verpasst(l,pos))?"  (Mitnahme verpasst)":"");
}
static void Hand(int pos,const char* start,const char* neu,const char* erw){ Run(pos,P(start),P(neu)[0],P(erw)); }

// ---------- D: Zufallstests ----------
static bool hatGleicheEtage(const L& l){ for(size_t i=0;i<l.size();i++) for(size_t j=i+1;j<l.size();j++) if(l[i].level==l[j].level) return true; return false; }
static void Zufall(){
    // D1: nur saubere Eingabelisten (aus Referenz aufgebaut), ein neuer Ruf; Ruf/Ziel in aktueller Etage ausgenommen
    // D2: Listen mit der Funktion selbst aufgebaut; Invarianten (Groesse, nichts geht verloren, keine verpasste Mitnahme, Nur-gueltige-Rufe)
    for(int seed=1; seed<=5; seed++){
        srand(seed);
        int d1=0,d1fail=0,d1mit=0,e1=0,e1fail=0,e1mit=0, d2=0,d2size=0,d2lost=0,d2mit=0; std::string bsp1, bsp2;
        for(int it=0; it<100000; it++){
            int pos=1+rand()%6, n=1+rand()%8; L l, f; bool t=false;
            for(int k=0;k<n;k++){ Target x; x.level=1+rand()%6; x.direction=(rand()%2)?Rauf:Runter; if(x.level==6)x.direction=Runter; if(x.level==1)x.direction=Rauf;
                l=RefAdd(l,x,pos); AddTargetToList(x,f,pos,t);
                // D2-Pruefung am Funktionsergebnis
                // (Funktion kann bei Ruf in aktueller Etage ablehnen -> dann ausgenommen)
            }
            // D1
            Target nw; nw.level=1+rand()%6; nw.direction=(rand()%2)?Rauf:Runter; if(nw.level==6)nw.direction=Runter; if(nw.level==1)nw.direction=Rauf;
            if(!l.empty() && !verpasst(l,pos) && nw.level!=pos && l[0].level!=pos){
                L e=RefAdd(l,nw,pos), g=l; bool tt=false; AddTargetToList(nw,g,pos,tt);
                bool oT=!hatGleicheEtage(l); if(oT) e1++; if(oT && !gleich(g,e)) e1fail++; if(oT && verpasst(g,pos)) e1mit++;
                d1++; if(!gleich(g,e)){ d1fail++; if(bsp1.empty()) bsp1="Gondel "+std::to_string(pos)+" ["+S(l)+"] + "+(nw.direction==Rauf?"U":"D")+std::to_string(nw.level)+" -> ["+S(g)+"] erwartet ["+S(e)+"]"; }
                if(verpasst(g,pos)) d1mit++;
            }
            // D2: f ist von der Funktion aufgebaut
            if(!f.empty() && f[0].level!=pos){
                Target x2=nw; if(x2.level==pos) continue;
                L v=f, g=f; bool tt=false; AddTargetToList(x2,g,pos,tt);
                bool dup=false; for(auto&q:v) if(q==x2) dup=true;
                size_t erw=(dup||v.size()>=10)?v.size():v.size()+1;
                d2++;
                if(g.size()!=erw) d2size++;
                else { L a=v; if(!dup&&v.size()<10) a.push_back(x2); auto c=[](const Target&p,const Target&q){return p.level!=q.level?p.level<q.level:p.direction<q.direction;}; L b=g; std::sort(a.begin(),a.end(),c); std::sort(b.begin(),b.end(),c); if(!(a==b)) d2lost++; }
                if(!verpasst(v,pos) && verpasst(g,pos)){ d2mit++; if(bsp2.empty()) bsp2="Gondel "+std::to_string(pos)+" ["+S(v)+"] + "+(x2.direction==Rauf?"U":"D")+std::to_string(x2.level)+" -> ["+S(g)+"]"; }
            }
        }
        printf("  Seed %d  D1 saubere Eingaben: %6d  abweichend %4d  Mitnahme verpasst %4d | ohne gleiche Etage in der Liste: %6d  abweichend %4d  Mitnahme verpasst %4d | D2 selbst aufgebaut: %6d  Groesse %d  Verlust %d  Mitnahme verpasst %d\n",seed,d1,d1fail,d1mit,e1,e1fail,e1mit,d2,d2size,d2lost,d2mit);
        if(seed==1){ if(!bsp1.empty()) printf("     Beispiel D1: %s\n",bsp1.c_str()); if(!bsp2.empty()) printf("     Beispiel D2: %s\n",bsp2.c_str()); }
    }
}
int main(){
    protokoll=fopen("szenarien_log.txt","w");
    printf("Funktion: %s\n",FUNKTION);
    // ---------- A: Handgeschriebene Grundfaelle (Erwartung von Hand abgeleitet) ----------
    Fam("A Grundfaelle");
    Hand(3,"","U5","U5");
    Hand(3,"U5 U6","U5","U5 U6");              // Duplikat
    Hand(3,"U5","U4","U4 U5");                 // einsortieren in Fahrtrichtung
    Hand(5,"D2","D4","D4 D2");
    Hand(3,"U5","D6","U5 D6");                 // Gegenrichtung hinter Umkehrpunkt
    Hand(3,"U5","D4","U5 D4");
    Hand(3,"U5 D4","D6","U5 D6 D4");
    Hand(3,"U5","U2","U5 U2");                 // nicht mehr erreichbar -> Abschnitt 3
    Hand(3,"U5 U2","U1","U5 U1 U2");
    Hand(3,"U5 U2","U4","U4 U5 U2");
    Hand(3,"U5 D4 D2","D3","U5 D4 D3 D2");
    Hand(2,"D1 U4 D4","U5","D1 U4 U5 D4");     // Beispiel des Nutzers
    Hand(3,"U3","U1","U3 U1");                 // Hinweis: Ruf in aktueller Etage (Absicht: zuerst)
    Hand(1,"U3","U1","U1 U3");
    Hand(1,"D5","U3","U3 D5");                 // Mitnahme auf dem Weg
    Hand(3,"U1","D2","D2 U1");
    Hand(4,"D6","U5","U5 D6");
    // ---------- B: Grenzen ----------
    Fam("B Grenzen (leer, voll, Enden)");
    { L v=P("U2 U3 U4 U5 D6 D5 D4 D3 D2 U1"); Run(1,v,P("D6")[0],v); }   // voll (10 = alle moeglichen Rufe): jeder neue Ruf ist Duplikat
    { L v=P("U2 U3 U4 U5 D6 D5 D4 D3 D2"); Target n=P("U1")[0]; L e=v; e.push_back(n); Run(1,v,n,Ref(1,true,e)); }   // 9 Eintraege + 1 = 10 erlaubt
    Hand(1,"","U1","U1"); Hand(6,"","D6","D6"); Hand(1,"U5","D6","U5 D6");
    Hand(6,"U1","U2","U1 U2"); Hand(1,"U2","U3","U2 U3"); Hand(6,"D5","D4","D5 D4");

    // ---------- C: Systematisches Raster ----------
    // Basislisten (Mengen), je Gondelposition zu sauberer Liste sortiert; jeder neue Ruf wird eingefuegt.
    const char* basen[] = { "U5", "D2", "U4 D5", "D3 U2 D4", "U3 D4 U2", "D5 D3 U4" };
    const char* neue[]  = { "U2","D4","U5","D3","U3","D2" };
    for(int pos=1;pos<=6;pos++){
        char name[40]; sprintf(name,"C Raster Gondel %d",pos); Fam(name);
        for(auto b:basen) for(auto nw:neue){
            L set=P(b); L l; for(auto&t:set){ if(t.level==1&&t.direction==Runter) continue; if(t.level==6&&t.direction==Rauf) continue; l=RefAdd(l,t,pos); }
            Target n=P(nw)[0];
            if(verpasst(l,pos)) continue;
            Run(pos,l,n,RefAdd(l,n,pos));
        }
    }
    Fam("");
    printf("\nD Zufallstests (je 5 Seeds x 100000 Laeufe):\n"); Zufall();
    printf("\n%d Szenarien, %d Fehler (Details: szenarien_log.txt)\n",nr,fails);
    printf("Fehlerarten: Ruf/Ziel in aktueller Etage %d | erstes Ziel verdraengt %d | Mitnahme verpasst %d | sonstige Reihenfolge %d\n",cat[0],cat[1],cat[2],cat[3]);
    fclose(protokoll);
    return fails?1:0;
}
