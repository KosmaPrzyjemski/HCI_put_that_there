/*
 * Palette Graphique - prélude au projet multimodal 3A SRI
 * 4 objets gérés : cercle, rectangle(carré), losange et triangle
 * (c) 05/11/2019
 * Dernière révision : 28/04/2020
 */
 
import java.awt.Point;
import fr.dgac.ivy.*;


ArrayList<Forme> formes; // liste de formes stockées
FSM mae; // Finite Sate Machine
int indice_forme;
PImage sketch_icon;

Ivy bus_parole;
Ivy bus_geste;

PFont f;
String message= "";

String confidence;
String action;
String where; 
String forme;
String couleur;
String localisation;

String shape;


void setup() {
  size(800,600);
  surface.setResizable(true);
  surface.setTitle("Palette multimodale");
  surface.setLocation(20,20);
  sketch_icon = loadImage("Palette.jpg");
  surface.setIcon(sketch_icon);
  
  formes= new ArrayList(); // nous créons une liste vide
  noStroke();
  mae = FSM.INITIAL;
  indice_forme = -1;
  
  //--------------------------------------------------------------
  // RECONNAISANCE VOCAL
  //--------------------------------------------------------------

  try
  {
    bus_parole = new Ivy("Reconnaissance_Vocal", " Reconnaissance_Vocal is ready", null);
    bus_parole.start("127.255.255.255:2010");
    
    bus_geste = new Ivy("Gestes", "Gestes is ready", null);
    bus_geste.start("127.255.255.255:2010");
    
     bus_geste.bindMsg("ICAR Gesture=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {  
        shape = args[0];
        if (shape.equals("triangle") || shape.equals("rectangle") || shape.equals("cercle") ||shape.equals("diamonde")){
          println(shape);
          message = "Vous avez dessine la forme : " + shape;
          shape = "";
          mae = FSM.TEXTE;
        }
      }        
    });
    
    bus_parole.bindMsg("^sra5 Text=(.*) Confidence=.*", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        message = "Vous avez dit : " + args[0];
        mae = FSM.TEXTE;
      }        
    });
    
    bus_parole.bindMsg("^sra5 Parsed=(.*) Confidence=(.*) NP=.*", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        message = "Vous avez prononcé les concepts : " + args[0] + " avec un taux de confiance de " + args[1];
        
        confidence = args[1];

        String[] list = split(args[0], ' ');
        action = list[0].substring(7);
        where = list[1].substring(6);
        forme = list[2].substring(5);
        couleur = list[3].substring(6);
        localisation = list[4].substring(13);
        
        String[] items = new String[5];
        items[0] = action;
        items[1] = where;
        items[2] = forme;
        items[3] = couleur;
        items[4] = localisation;
        
        
        int nb_items = 5;
        for (int i=0; i<=4; i++){
          if (items[i].equals("undefined")){
            nb_items--;
          }
          else{
            println(items[i]);
          }
        }

        println(nb_items);
        println(confidence);

          
        mae = FSM.CONCEPT;
      }        
    });
    
    bus_parole.bindMsg("^sra5 Event=Speech_Rejected", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        message = "Malheureusement, je ne vous ai pas compris"; 
        mae = FSM.NON_RECONNU;
      }        
    });    
  }
  catch (IvyException ie)
  {
  }

  
}

void draw() {
  //println("MAE : " + mae + " indice forme active ; " + indice_forme);
  switch (mae) {
    case INITIAL:  // Etat INITIAL
      background(255);
      fill(0);
      text("Etat initial (c(ercle)/l(osange)/r(ectangle)/t(riangle) pour créer la forme à la position courante)", 50,50);
      text("m(ove)+ click pour sélectionner un objet et click pour sa nouvelle position", 50,80);
      text("click sur un objet pour changer sa couleur de manière aléatoire", 50,110);
      
      message = "Bonjour, veuillez parler et ou dessiner une forme s'il vous plaît";
      try {
          bus_parole.sendMsg("ppilot5 Say=" + message); 
          bus_geste.sendMsg("ppilot5 Say=" + message); 
      }
      catch (IvyException e) {}
      mae = FSM.ATTENTE;
      
      break;
    
    case ATTENTE:
      // cas normal ...
      break;
      
    case TEXTE :
      try {
          bus_parole.sendMsg("ppilot5 Say=" + message); 
      }
      catch (IvyException e) {}
      mae = FSM.ATTENTE;
      break;
      
     case CONCEPT:  
        // items[i]
        // 0 = action
        // 1 = where
        // 2 = forme
        // 3 = couleur
        // 4 = localisation
        
       try {
          bus_parole.sendMsg("ppilot5 Say=" + message); 
       }
       catch (IvyException e) {}
       
       if item[0] == "create":
       
       
       mae = FSM.ATTENTE;
       break; 
       
     case NON_RECONNU:
       mae = FSM.ATTENTE;
       try {
          bus_parole.sendMsg("ppilot5 Say=" + message); 
       }
       catch (IvyException e) {}
       mae = FSM.ATTENTE;
       break;
       
    case CREATE:  
    case SELECT_FORME: 
    case EMPLACEMENT: 
      affiche();
      break;   
      
    default:
      break;
  } 
}

// fonction d'affichage des formes m
void affiche() {
  background(255);
  /* afficher tous les objets */
  for (int i=0;i<formes.size();i++) // on affiche les objets de la liste
    (formes.get(i)).update();
}

void mousePressed() { // sur l'événement clic
  Point p = new Point(mouseX,mouseY);
  
  switch (mae) {
    case CREATE:
      for (int i=0;i<formes.size();i++) { // we're trying every object in the list
        // println((formes.get(i)).isClicked(p));
        if ((formes.get(i)).isClicked(p)) {
          (formes.get(i)).setColor(color(random(0,255),random(0,255),random(0,255)));
        }
      } 
      break;
      
   case SELECT_FORME:
     for (int i=0;i<formes.size();i++) { // we're trying every object in the list        
        if ((formes.get(i)).isClicked(p)) {
          indice_forme = i;
          mae = FSM.EMPLACEMENT;
        }         
     }
     if (indice_forme == -1)
       mae= FSM.CREATE;
     break;
     
   case EMPLACEMENT:
     if (indice_forme !=-1)
       (formes.get(indice_forme)).setLocation(new Point(mouseX,mouseY));
     indice_forme=-1;
     mae=FSM.CREATE;
     break;
     
    default:
      break;
  }
}


void keyPressed() {
  Point p = new Point(mouseX,mouseY);
  switch(key) {
    case 'r':
      Forme f= new Rectangle(p);
      formes.add(f);
      mae=FSM.CREATE;
      break;
      
    case 'c':
      Forme f2=new Cercle(p);
      formes.add(f2);
      mae=FSM.CREATE;
      break;
    
    case 't':
      Forme f3=new Triangle(p);
      formes.add(f3);
       mae=FSM.CREATE;
      break;  
      
    case 'l':
      Forme f4=new Losange(p);
      formes.add(f4);
      mae=FSM.CREATE;
      break;    
      
    case 'm' : // move
      mae=FSM.SELECT_FORME;
      break;
  }
}
