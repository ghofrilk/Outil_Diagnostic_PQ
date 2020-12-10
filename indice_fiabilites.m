
%% Calcul de la fiabilit� de l'exploitation par approche probabiliste %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Variables d'entr�e : 
% MX : Vecteur 1D contenant les points de puissances r�actives                
% MW : Vecteur 1D contenant les points de puissances actives                                      
% MXcap : Abscisses des points de la courbe de capacit� 
% MWcap : Ordonn�es des points de la courbe de capacit� 
% indiceReactif : indice du vecteur MXcap �  partir duquel la limite
% r�active s'ammorce
% nom : Nom de la Centrale et du groupe en question
% type : chaine de caract�re "�t�" ou "Hiver" pour l'affichage du graphique

%% Variables de sortie : 
% tauMotorisation : taux de motorisation             
% tauDepassement  : taux de d�passement des limites physiques                                      


function [beta,betaReactive,betaActive,PDegradation,fig] = indice_fiabilites(MX,MW,MXcap,MWcap,indiceReactif,nom,type)


%% Mod�lisation probabiliste
[FMXpts,xMXpts]= ecdf (MX); %% Fonction de r�partition empirique sur la distribution de la puissance r�active
U1 = norminv(FMXpts);       %% Transformation iso-probabiliste

[FMWpts,xMWpts]= ecdf (MW); %% Fonction de r�partition empirique sur la distribution de la puissance active
U2 = norminv(FMWpts);       %% Transformation iso-probabiliste

%% Filtrage 
xMXpts = unique (xMXpts);
FMXpts = unique(FMXpts);
FMXpts(end)=[];
xMWpts = unique(xMWpts);
FMWpts = unique(FMWpts);
FMWpts(end)=[];

%% Transformation iso-probabiliste
MXCap_U1 = norminv(interp1(xMXpts,FMXpts,MXcap,'nearest')); %% Transformation iso-probabiliste des �chantillons de la courbe de conception 
MWCap_U2 = norminv(interp1(xMWpts,FMWpts,MWcap,'nearest')); %% Transformation iso-probabiliste des �chantillons de la courbe de conception 



% for i = 1:length(MXCap_U1) 
%     if isnan(MXCap_U1 (i)) && (i < 20) 
%         MXCap_U1 (i) = indiceNonDeterministe;
%     elseif isnan(MXCap_U1 (i)) && (i > 30) 
%         MXCap_U1 (i) = indiceDeterministe;
%     end
%     
% end
% 
% for i = 1:length(MWCap_U2) 
%     if isnan(MWCap_U2 (i)) && (i < 20) 
%         MWCap_U2 (i) = indiceNonDeterministe;
%     elseif isnan(MWCap_U2 (i)) && (i > 30) 
%         MWCap_U2(i) = indiceDeterministe;
%     end
%     
% end


%% Caclul de l'indice beta

%Calcucl des distances entre l'origine et les �chantillions de la courbe de capacit�
distances = sqrt (MXCap_U1.^2 + MWCap_U2.^2); 
%Calcucl de l'indice beta maximal
[beta, indexBeta] = min (distances);
beta = round(beta,2);
% Calcucl de l'indice beta du d�passement de la limite stator
[betaActive, indexBetaActive] = min(distances(1:indiceReactif));
betaActive = round(betaActive,2);
% Calcucl de l'indice beta du d�passement de la limite rotor
[betaReactive, indexBetaReactive] = min(distances(indiceReactif+1:end));   
indexBetaReactive = indexBetaReactive + indiceReactif ; 
betaActive = round(betaActive,2);
%Calcul des coordonn�es du point de conception u* global
indexx_beta_global= MXCap_U1 (indexBeta);
indexy_beta_global= MWCap_U2(indexBeta);

%Calcul des coordonn�es du point de conception u* de la limite stator
indexx_beta_active= MXCap_U1(indexBetaActive);
indexy_beta_active= MWCap_U2 (indexBetaActive);

%Calcul des coordonn�es du point de conception u* de la limite rotor
indexx_beta_reactive= MXCap_U1 (indexBetaReactive);
indexy_beta_reactive= MWCap_U2  (indexBetaReactive);


%% FORM (First Order Reliabilty Method)

% Probabilit� de d�gradation apr�s approximation du 1er ordre
PDegradation = round(mvncdf(-beta),3);

% Lin�aristation de la fonction d'�tat-limite

% Calcul du gradient
MXCap_U1_grad = gradient (MXCap_U1); %tableau du gradient de MXCap
MWCap_U2_grad = gradient (MWCap_U2); %tableau du gradient de MWCap


%Lin�aristion sur u*_active
x1_U1_grad_u_active = MXCap_U1_grad (indexBetaActive); %gradient de MXCap �valu� � u*_active
y1_U2_grad_u_active = MWCap_U2_grad (indexBetaActive); %gradient de MWCap �valu� � u*_active

%Lin�aristion sur u*_active
x1_U1_grad_u_reactive = MXCap_U1_grad (indexBetaReactive); %gradient de MXCap �valu� � u*_reactive
y1_U2_grad_u_reactive = MWCap_U2_grad (indexBetaReactive); %gradient de MWCap �valu� � u*_reactive




if ~isnan(x1_U1_grad_u_active) && ~isinf(x1_U1_grad_u_active) &&  ~isnan(y1_U2_grad_u_active)  &&  ~isinf(y1_U2_grad_u_active) && (x1_U1_grad_u_active~=0 || y1_U2_grad_u_active~=0)
    
    %Calcul du vecteur Alpha dans le domaine Actif
    alphaActive_t = -[x1_U1_grad_u_active ,y1_U2_grad_u_active]/sqrt(x1_U1_grad_u_active.^2 + y1_U2_grad_u_active.^2) ; %Vecteur gradient normalis� sur u1*
    alphaActive = transpose(null(alphaActive_t));
    alphaActive =  [round(alphaActive(1),2),round(alphaActive(2),2)];
    CoordVectBetaActive = [round(indexx_beta_active,2),round(indexy_beta_active,2)];
    
    FORMx_active = linspace(-5,5,500)*alphaActive_t(1)+CoordVectBetaActive(1);
    FORMy_active = linspace(-5,5,500)*alphaActive_t(2)+CoordVectBetaActive(2);
    
    
        

elseif ~isnan(x1_U1_grad_u_reactive) &&  ~isnan(y1_U2_grad_u_reactive) && (x1_U1_grad_u_reactive~=0 || y1_U2_grad_u_reactive~=0)

    %Calcul du vecteur Alpha dans le domaine R�actif
    alphaReactive_t = -[x1_U1_grad_u_reactive ,y1_U2_grad_u_reactive]/sqrt(x1_U1_grad_u_reactive.^2 + y1_U2_grad_u_reactive.^2) ; %Vecteur gradient normalis� sur u1*
    alphaReactive = -transpose(null(alphaReactive_t));
    alphaReactive =  [round(alphaReactive(1),2),round(alphaReactive(2),2)];
    CoordVectBetaReactive = [round(indexx_beta_reactive,2),round(indexy_beta_reactive,2)];
    
    FORMx_Reactive = linspace(-5,5,500)*alphaReactive_t(1)+CoordVectBetaReactive(1);
    FORMy_Reactive = linspace(-5,5,500)*alphaReactive_t(2)+CoordVectBetaReactive(2);
     
else
    return
end


%% Trac� de la courbe de capacit� de l'alternateur dans l'espace Gaussien

fig = figure('visible','off');

sz=10;
scatter(MXCap_U1,MWCap_U2,sz,'black','filled')
hold on


%     plot(indexx_beta_reactive,indexy_beta_reactive,'*')
%     hold on 
    plot(indexx_beta_active,indexy_beta_active,'o')
    hold on 
    
    if exist('FORMx_active','var') && exist('CoordVectBetaActive','var')
         plot(FORMx_active,FORMy_active,'--')
        
        % Trac� du Beta Active
        drawArrow = @(x,y,varargin) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0, varargin{:} );  
        x1 = [0 CoordVectBetaActive(1)];
        y1 = [0 CoordVectBetaActive(2)];
        drawArrow(x1,y1,'linewidth',1,'color','black'); 
        text(0.15,-0.65,"Beta Active = " + num2str(betaActive))
    
        %Trac� du vecteur Alpha Active
        drawArrow = @(x,y,varargin) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0, varargin{:} );  
        x1 = [CoordVectBetaActive(1) CoordVectBetaActive(1)+alphaActive(1)];
        y1 = [CoordVectBetaActive(2) CoordVectBetaActive(2)+alphaActive(2)];
        drawArrow(x1,y1,'linewidth',1,'color','red'); 
        
    elseif exist('FORMx_Reactive','var') && exist('CoordVectBetaReactive','var')
         
         plot(FORMx_Reactive,FORMy_Reactive,'--')
        % Trac� du Beta R�active
        drawArrow = @(x,y,varargin) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0, varargin{:} );  
        x1 = [0 CoordVectBetaReactive(1)];
        y1 = [0 CoordVectBetaReactive(2)];
        drawArrow(x1,y1,'linewidth',1,'color','black'); 
        text(0.15,-0.65,"Beta R�active = " + num2str(betaReactive))
    
        
        %Trac� du vecteur Alpha R�active
        drawArrow = @(x,y,varargin) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0, varargin{:} );  
        x1 = [CoordVectBetaReactive(1) CoordVectBetaReactive(1)+alphaReactive(1)];
        y1 = [CoordVectBetaReactive(2) CoordVectBetaReactive(2)+alphaReactive(2)];
        drawArrow(x1,y1,'linewidth',1,'color','red'); 
    
    end

grid on
xlabel("U1")
ylabel('U2')
xlim([-5 5])
ylim([-5 5])
box off
grid on
title (sprintf("Courbe de capacit� dans l'espace Gaussien"+"\n" + nom + " "+type ))


end