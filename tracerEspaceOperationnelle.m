
%% Fonction qui affiche les espaces opérationnels avec et sans indicateur de performance%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Variables d'entrée : 
% MXete : Vecteur 1D contenant les points de puissances réactives en été               
% MWete : Vecteur 1D contenant les points de puissances actives en été
% MXhiver : Vecteur 1D contenant les points de puissances réactives en hiver               
% MWhiver : Vecteur 1D contenant les points de puissances actives en hiver  
% MXcap_ete : Abscisses des points de la courbe de capacité en été
% MWcap_ete : Ordonnées des points de la courbe de capacité en été
% MXcap_hiv : Abscisses des points de la courbe de capacité en hiver
% MWcap_hiv : Ordonnées des points de la courbe de capacité en hiver
% nomCentraletGroupe : Vecteur 1D de variables booléennes des instances d'été
% pourcentageMotorisation : Pourcentage de temps passé en motorisation
%beta_ete_global :  Indice de fiabilité global en été (plus grand des indices
%de fiabilité au stator ou au rotor
%beta_hiver_global : Indice de fiabilité global en hiver (plus grand des indices
%de fiabilité au stator ou au rotor 
%tauDepassement : taux de dépassement en dehors des limites de conception 
%nbAlarmes : nombre d'alarmes en Itot
%PDegradationEte : Approximation du 1er ordre de la probabilité de séjour en
%zone de dégradation en été
%PDegradationHiver : Approximation du 1er ordre de la probabilité de séjour en
%zone de dégradation en hiver

%% Variables de sortie : 
% tauMotorisation : taux de motorisation             
% tauDepassement  : taux de dépassement des limites physiques 


function [fig_carac,fig_sansCarac]=tracerEspaceOperationnelle(MXete,MWete,MXhiver,MWhiver,MXcap_ete,MWcap_ete,MXcap_hiv,MWcap_hiv,nomCentraletGroupe,pourcentageMotorisation,...
    beta_ete_global,beta_hiver_global,tauDepassement,nbAlarmes,PDegradationEte,PDegradationHiver)


    %% Tracé de l'espace opérationnel avec affichage des indicateurs de performance
    fig_carac=figure('visible','off')   ;
    scatter(MXete,MWete,10,"red","filled")
    hold on
    scatter(MXhiver,MWhiver,10,"blue","filled")
    hold on
    scatter(MXcap_ete,MWcap_ete,10,"green","filled")
    hold on 
    scatter(MXcap_hiv,MWcap_hiv,10,"black","filled")

   
    % Affichages des caractéristiques de la figure
    xlabel("Puissance Réactive [MVAR]")
    ylabel("Puissance Active [MW]")
    title(sprintf(...
        "Espace opérationnel 2010-2017 : " + nomCentraletGroupe +...
        " \n Pourcentage de motorisation = " + convertCharsToStrings(num2str(pourcentageMotorisation))+...
        " \n Indice de fibabilité en Été = " + convertCharsToStrings(num2str(beta_ete_global))+...
        " \n Indice de fibabilité en Hiver = " + convertCharsToStrings(num2str(beta_hiver_global))+...
        " \n Tau de Dépassement = " + convertCharsToStrings(num2str(tauDepassement))+...
        " \n Nombre Alarmes = " + convertCharsToStrings(num2str(nbAlarmes))+...
        " \n Probabilité de dégradation Été :" + convertCharsToStrings(num2str(PDegradationEte))+...
        " \n Probabilité de dégradation Hiver :" + convertCharsToStrings(num2str(PDegradationHiver))))

        
        
      %         " \n SORM Été :" + convertCharsToStrings(num2str(SORMEte))+...
%         " \n SORM Hiver :" + convertCharsToStrings(num2str(SORMHiver))...
%     legend("Une heure d'opération (été)","Une heure d'opération (hiver)","Capacité du groupe (été)","Capacité du groupe (hiver)")
    grid on 

   
    
    %% Tracé de l'espace opérationnel sans affichage des indicateurs de performance
    fig_sansCarac = figure('visible','off')  ; 
    scatter(MXete,MWete,10,"red","filled")
    hold on
    scatter(MXhiver,MWhiver,10,"blue","filled")
    hold on
    scatter(MXcap_ete,MWcap_ete,10,"green","filled")
    hold on 
    scatter(MXcap_hiv,MWcap_hiv,10,"black","filled")

   
    % Affichages des caractéristiques de la figure
    xlabel("Puissance Réactive [MVAR]")
    ylabel("Puissance Active [MW]")
    title(sprintf(...
        "Espace opérationnel Itot : " + nomCentraletGroupe ...
        ))
       
%   legend("Une heure d'opération (été)","Une heure d'opération (hiver)","Capacité du groupe (été)","Capacité du groupe (hiver)")



end



 