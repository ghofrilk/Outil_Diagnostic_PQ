
%% Fonction qui affiche les espaces op�rationnels avec et sans indicateur de performance%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Variables d'entr�e : 
% MXete : Vecteur 1D contenant les points de puissances r�actives en �t�               
% MWete : Vecteur 1D contenant les points de puissances actives en �t�
% MXhiver : Vecteur 1D contenant les points de puissances r�actives en hiver               
% MWhiver : Vecteur 1D contenant les points de puissances actives en hiver  
% MXcap_ete : Abscisses des points de la courbe de capacit� en �t�
% MWcap_ete : Ordonn�es des points de la courbe de capacit� en �t�
% MXcap_hiv : Abscisses des points de la courbe de capacit� en hiver
% MWcap_hiv : Ordonn�es des points de la courbe de capacit� en hiver
% nomCentraletGroupe : Vecteur 1D de variables bool�ennes des instances d'�t�
% pourcentageMotorisation : Pourcentage de temps pass� en motorisation
%beta_ete_global :  Indice de fiabilit� global en �t� (plus grand des indices
%de fiabilit� au stator ou au rotor
%beta_hiver_global : Indice de fiabilit� global en hiver (plus grand des indices
%de fiabilit� au stator ou au rotor 
%tauDepassement : taux de d�passement en dehors des limites de conception 
%nbAlarmes : nombre d'alarmes en Itot
%PDegradationEte : Approximation du 1er ordre de la probabilit� de s�jour en
%zone de d�gradation en �t�
%PDegradationHiver : Approximation du 1er ordre de la probabilit� de s�jour en
%zone de d�gradation en hiver

%% Variables de sortie : 
% tauMotorisation : taux de motorisation             
% tauDepassement  : taux de d�passement des limites physiques 


function [fig_carac,fig_sansCarac]=tracerEspaceOperationnelle(MXete,MWete,MXhiver,MWhiver,MXcap_ete,MWcap_ete,MXcap_hiv,MWcap_hiv,nomCentraletGroupe,pourcentageMotorisation,...
    beta_ete_global,beta_hiver_global,tauDepassement,nbAlarmes,PDegradationEte,PDegradationHiver)


    %% Trac� de l'espace op�rationnel avec affichage des indicateurs de performance
    fig_carac=figure('visible','off')   ;
    scatter(MXete,MWete,10,"red","filled")
    hold on
    scatter(MXhiver,MWhiver,10,"blue","filled")
    hold on
    scatter(MXcap_ete,MWcap_ete,10,"green","filled")
    hold on 
    scatter(MXcap_hiv,MWcap_hiv,10,"black","filled")

   
    % Affichages des caract�ristiques de la figure
    xlabel("Puissance R�active [MVAR]")
    ylabel("Puissance Active [MW]")
    title(sprintf(...
        "Espace op�rationnel 2010-2017 : " + nomCentraletGroupe +...
        " \n Pourcentage de motorisation = " + convertCharsToStrings(num2str(pourcentageMotorisation))+...
        " \n Indice de fibabilit� en �t� = " + convertCharsToStrings(num2str(beta_ete_global))+...
        " \n Indice de fibabilit� en Hiver = " + convertCharsToStrings(num2str(beta_hiver_global))+...
        " \n Tau de D�passement = " + convertCharsToStrings(num2str(tauDepassement))+...
        " \n Nombre Alarmes = " + convertCharsToStrings(num2str(nbAlarmes))+...
        " \n Probabilit� de d�gradation �t� :" + convertCharsToStrings(num2str(PDegradationEte))+...
        " \n Probabilit� de d�gradation Hiver :" + convertCharsToStrings(num2str(PDegradationHiver))))

        
        
      %         " \n SORM �t� :" + convertCharsToStrings(num2str(SORMEte))+...
%         " \n SORM Hiver :" + convertCharsToStrings(num2str(SORMHiver))...
%     legend("Une heure d'op�ration (�t�)","Une heure d'op�ration (hiver)","Capacit� du groupe (�t�)","Capacit� du groupe (hiver)")
    grid on 

   
    
    %% Trac� de l'espace op�rationnel sans affichage des indicateurs de performance
    fig_sansCarac = figure('visible','off')  ; 
    scatter(MXete,MWete,10,"red","filled")
    hold on
    scatter(MXhiver,MWhiver,10,"blue","filled")
    hold on
    scatter(MXcap_ete,MWcap_ete,10,"green","filled")
    hold on 
    scatter(MXcap_hiv,MWcap_hiv,10,"black","filled")

   
    % Affichages des caract�ristiques de la figure
    xlabel("Puissance R�active [MVAR]")
    ylabel("Puissance Active [MW]")
    title(sprintf(...
        "Espace op�rationnel Itot : " + nomCentraletGroupe ...
        ))
       
%   legend("Une heure d'op�ration (�t�)","Une heure d'op�ration (hiver)","Capacit� du groupe (�t�)","Capacit� du groupe (hiver)")



end



 