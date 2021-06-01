function [NPC,Wind_cost,Solar_cost,DG_cost,Battery_cost,Inverter_Tcost] = NPC_cost(Nbat,Nw,Nsol,DG_hr,DG_Pro)

% Diesel generator cost calcualtion
DG_hr=sum(DG_hr);% total running hours
DG_Pro=sum(DG_Pro);% total energy production in kwh
DG_c=45000-7143;%capital cost - salvage cost

Fuel_=(8.97*DG_hr)+(DG_Pro*0.222); % total fuel/year% [This formula is given by manufactured to calculate DG fuel consumptioin]

Fuel_c=1.1*Fuel_ ;     % fuel cost per year, 1.1 is fuel cost per litre
OM=9.2*DG_hr; % Operation and maintenance cost per year of Dg
%% ***********************************
%wind cost
Cw =2000; % =capital cost of one wind plant 
W_OM=200; %Wind operation and maintenance cost.
%% solar cost 
Cs =650; % =cost of one PV  module - salvage cost
S_OM=50;

%% battery cost                                       %including 4$/KW for maitenane        
BAT_C=550;% batery unit cost  
BAT_C_r=550;%6500 this cost as per results 
Bat_sal=0;
Bat_OM=10;

% Inverter cost.
INV_C=300;  % inverter cost per kw
INV_Cr=300;%3400; as per results 
INV_sal=0;
INV_OM=50;

%economic index
REAL_INTREST=9;
%life time
PRJ_LF=20;
Wind_L=20;% wind turbine life
Bate_L=10; % battery life
ir=REAL_INTREST/100; 

DG_cost=[(OM+Fuel_c)/((ir*(1+ir).^(20))/(((1+ir).^20)-1))] + DG_c;% salvage cost used from simulation/*

% battery anualized cost
Battery_costC =Nbat*(BAT_C-Bat_sal);
% Battery replacement cost
Battery_cost_r=Nbat*(BAT_C_r);
% Battery OM  cost
 Battery_cost =Battery_costC+Battery_cost_r+ (Nbat*Bat_OM/((ir*(1+ir).^(20))/(((1+ir).^20)-1)));%OK (replacement)
% wind annualized cost
Wind_cost=Nw*[Cw+(W_OM/((ir*(1+ir).^(20))/(((1+ir).^20)-1)))]; %OK
%Solar annualized cost
Solar_cost=Nsol*[Cs+(S_OM/((ir*(1+ir).^(20))/(((1+ir).^20)-1)))]/0.345;  %salvage issue????????????????????????

% inverter cost calcuation
%inverter annaualized cost
Inverter_C=1*(INV_C)*(184/20); %capital cost
Inverter_Cr=1*(INV_Cr)*(184/20);% replacement cost
Inverter_OM=1*(INV_OM)*(184/20)/((ir*(1+ir).^(20))/(((1+ir).^20)-1));% OM cost
Inverter_Tcost=Inverter_C+Inverter_Cr+Inverter_OM ;%Inverter cost

% plot(Grid_p,'DisplayName','purchase')
% hold
% plot(-Grid_sale,'DisplayName','sales')

NPC=DG_cost+Inverter_Tcost+Wind_cost+Battery_cost+Solar_cost ; %Annualized cost.
% 
end
