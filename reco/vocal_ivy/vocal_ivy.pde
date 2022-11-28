/*
 *  vocal_ivy -> Demonstration with ivy middleware
 * v. 1.2
 * 
 * (c) Ph. Truillet, October 2018-2019
 * Last Revision: 22/09/2020
 * Gestion de dialogue oral
 */
 
import fr.dgac.ivy.*;

// data

Ivy bus;
PFont f;
String message= "";

int state;
public static final int INIT = 0;
public static final int ATTENTE = 1;
public static final int TEXTE = 2;
public static final int CONCEPT = 3;
public static final int NON_RECONNU = 4;

String confidence;
String action;
String where; 
String forme;
String couleur;
String localisation;


void setup()
{
  size(400,100);
  fill(0,255,0);
  f = loadFont("TwCenMT-Regular-24.vlw");
  state = INIT;
  
  textFont(f,18);
  try
  {
    bus = new Ivy("Reconnaissance_Vocal", " Reconnaissance_Vocal is ready", null);
    bus.start("127.255.255.255:2010");
    
    bus.bindMsg("^sra5 Text=(.*) Confidence=.*", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        message = "Vous avez dit : " + args[0];
        state = TEXTE;
      }        
    });
    
    bus.bindMsg("^sra5 Parsed=(.*) Confidence=(.*) NP=.*", new IvyMessageListener()
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

          
        state = CONCEPT;
      }        
    });
    
    bus.bindMsg("^sra5 Event=Speech_Rejected", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        message = "Malheureusement, je ne vous ai pas compris"; 
        state = NON_RECONNU;
      }        
    });    
  }
  catch (IvyException ie)
  {
  }
}

void draw()
{
  background(0);
  
  switch(state) {
    case INIT:
      message = "Bonjour, veuillez parler s'il vous plaît";
      try {
          bus.sendMsg("ppilot5 Say=" + message); 
      }
      catch (IvyException e) {}
      state = ATTENTE;
      break;
      
    case ATTENTE:
      // cas normal ...
      break;
      
    case TEXTE :
      try {
          bus.sendMsg("ppilot5 Say=" + message); 
      }
      catch (IvyException e) {}
      state = ATTENTE;
      break;
      
     case CONCEPT:  
       try {
          bus.sendMsg("ppilot5 Say=" + message); 
       }
       catch (IvyException e) {}
       state = ATTENTE;
       break; 
       
     case NON_RECONNU:
       state = ATTENTE;
       try {
          bus.sendMsg("ppilot5 Say=" + message); 
       }
       catch (IvyException e) {}
       state = ATTENTE;
       break;
  }
  
  text("** ETAT COURANT **", 20,20);
  text(state, 20, 50);
}
