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

String shape;


void setup()
{
  size(400,100);
  fill(0,255,0);
  f = loadFont("TwCenMT-Regular-24.vlw");
  state = INIT;
  
  textFont(f,18);
  try
  {
    bus = new Ivy("Gestes", "Gestes is ready", null);
    bus.start("127.255.255.255:2010");
    
    bus.bindMsg("ICAR Gesture=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {  
        shape = args[0];
        if (shape.equals("triangle") || shape.equals("rectangle") || shape.equals("cercle") ||shape.equals("diamonde")){
          message = "Vous avez dessine la forme : " + shape;
          shape = "";
          state = TEXTE;
        }

     
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
      message = "Bonjour, veuillez dessiner une forme s'il vous plaît";
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
 
  }
  
  text("** ETAT COURANT **", 20,20);
  text(state, 20, 50);
}
