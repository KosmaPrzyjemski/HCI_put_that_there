/*
 * Enumération de a Machine à Etats (Finite State Machine)
 *
 *
 */
 
public enum FSM {
  INITIAL, /* Etat Initial */ 
  ATTENTE,
  

  CONCEPT,   // ------------------IL FAUT L'AJOUTER A LA MAE?
  
  CREATE, //OK
  MOUVEMENT,
  CHANGER_COULEUR,
  FORME,
  SELECT_FORME, //OK
  SELECT_FORME_COULEUR,
  COULEUR,
  EMPLACEMENT, //OK
  
  NON_RECONNU,
  TEXTE,

}
