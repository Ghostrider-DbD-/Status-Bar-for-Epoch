/*

	Based on osefStatusbar by 
	Adapted for Epoch by DarthRougue
	Some code (BP, temperature) from Ignatz_Statusbar by HeMan
	Further Modified by GhostriderGRG to display icons for earplugs and infinite running.
	
*/

waitUntil {alive vehicle player};    
waitUntil {typeOF player != "VirtualMan_EPOCH"};
waitUntil {!(isNull (findDisplay 46))};
diag_log "playerBar.sqf Loading Now";
disableSerialization;

_rscLayer = "osefStatusBar" call BIS_fnc_rscLayer;
_rscLayer cutRsc["osefStatusBar","PLAIN"];
private _admin = ["76561197995799489","76561198206211968"];
[] spawn 
{
		//set the color values.
		//Additional color codes can be found here:  http://html-color-codes.com/
		private _colourDefault = parseText "#F0F0F0"; //"#adadad"; //set your default colour here
		_colour100 		= parseText "#336600";
		_colour90 		= parseText "#339900";
		_colour80 		= parseText "#33CC00";
		_colour70 		= parseText "#33FF00";
		_colour60 		= parseText "#66FF00";
		_colour50 		= parseText "#CCFF00";
		_colour40 		= parseText "#CCCC00";
		_colour30 		= parseText "#CC9900";
		_colour20 		= parseText "#CC6600";
		_colour10 		= parseText "#CC3300";
		_colour0 		= parseText "#CC0000";
		_colourDead 	= parseText "#000000";
		_colourBlack	= _colourDead;
		_colourTempLowest	= parseText '#0000CC';	
		_colourTempLower	= parseText '#9600CC';	
		_colourTempMid		= parseText '#336600';	
		_colourTempHigher	= parseText '#CC0055';	
		_colourTempHighest	= parseText '#FF0000';			
		_colorEarplugs = parseText "#38eeff";
		_colorPlayerCount = _colorEarplugs;
		_colorAutoRun = parseText "#F2913D";
		_firstAidColor  = parseText "#FF0000";
		
		_restartInterval = 240;
		_blinkTimer = diag_tickTime;
		_blinkInterval = 2;  // 2 seconds
		_blinkSetBlack = false;
		
	while {true} do 
	{
		sleep 1;
		if(isNull ((uiNamespace getVariable "osefStatusBar")displayCtrl 55555)) then
		{
			diag_log "statusbar is not created";
			disableSerialization;
			_rscLayer = "osefStatusBar" call BIS_fnc_rscLayer;
			_rscLayer cutRsc["osefStatusBar","PLAIN"];
		};		
		
		//initialize variables and set values
		_serverFPS = "###";
		if (!isNil "blck_serverFPS") then {_serverFPS = blck_serverFPS};
		_unit = _this select 0;
		_damage = round ((1 - (damage player)) * 100);
		//_damage = (round(_damage * 100));
		_hunger = round((EPOCH_playerHunger/5000) * 100);
		_thirst = round((EPOCH_playerThirst/2500) * 100);
		_wallet = EPOCH_playerCrypto;
		_stamina = round(EPOCH_playerStamina * 100) / 100;
		_fatigue = round(getFatigue player * 100); 
		_toxPercent = round (EPOCH_playerToxicity);
		_percentNuclear = EPOCH_playerRadiation;
		//_bloodpressure = round (EPOCH_playerBloodP);	
		_temp = round((EPOCH_playerTemp-32) * (5/9));
		_energy = round(EPOCH_playerEnergy);
		_energyPercent =  floor((_energy / 2500 ) * 100);
		_fps = format["%1", diag_fps];
		_grid = mapGridPosition  player; 
		_xx = (format[_grid]) select  [0,3]; 
		_yy = (format[_grid]) select  [3,3];  
		_time = (round(_restartInterval-(serverTime)/60));  //edit the '240' value (60*4=240) to change the countdown timer if your server restarts are shorter or longer than 4 hour intervals
		_hours = (floor(_time/60));
		_minutes = (_time - (_hours * 60));
		//diag_log format["status bar: radiation = %1 | toxicit  = %2",_percentNuclear,_toxPercent];
		if ((diag_tickTime - _blinkTimer) > _blinkInterval) then {
			_blinkSetBlack = !_blinkSetBlack; 
			_blinkTimer = diag_tickTime;
		};
				_colorRestart = _colourDefault;
		switch true do {
			case ((_hours == 0) && ((_minutes >= 10) && (_minutes < 15))):{_colorRestart = _colour60};
			case ((_hours == 0) && ((_minutes >= 5) && (_minutes < 10))):{_colorRestart = _color80};
			case ((_hours == 0) && (_minutes < 5)): {_colorRestart = _color100};
		};
		
		switch(_minutes) do	{
			case 9: {_minutes = "09"};
			case 8: {_minutes = "08"};
			case 7: {_minutes = "07"};
			case 6: {_minutes = "06"};
			case 5: {_minutes = "05"};
			case 4: {_minutes = "04"};
			case 3: {_minutes = "03"};
			case 2: {_minutes = "02"};
			case 1: {_minutes = "01"};
			case 0: {_minutes = "00"};
		};				

		//Colour coding
		//Damage
		_colourDamage = _colourDefault;
		switch true do {
			case(_damage >= 100) : {_colourDamage = _colour100;};
			case((_damage >= 90) && (_damage < 100)) : {_colourDamage =  _colour90;};
			case((_damage >= 80) && (_damage < 90)) : {_colourDamage =  _colour80;};
			case((_damage >= 70) && (_damage < 80)) : {_colourDamage =  _colour70;};
			case((_damage >= 60) && (_damage < 70)) : {_colourDamage =  _colour60;};
			case((_damage >= 50) && (_damage < 60)) : {_colourDamage =  _colour50;};
			case((_damage >= 40) && (_damage < 50)) : {_colourDamage =  _colour40;};
			case((_damage >= 30) && (_damage < 40)) : {_colourDamage =  _colour30;};
			case((_damage >= 20) && (_damage < 30)) : {_colourDamage =  _colour20;};
			case((_damage >= 10) && (_damage < 20)) : {_colourDamage =  _colour10;};
			case((_damage >= 1) && (_damage < 10)) : {_colourDamage =  _colour0;};
			//case(_damage < 1) : {_colourDamage =  _colourDead;};
		};
		/*
		switch true do {
			case (_bloodpressure < 110) : {_colourBloodP =  _colour100;};
			case ((_bloodpressure >= 110) && (_bloodpressure < 120)) : {_colourBloodP =  _colour90;};
			case ((_bloodpressure >= 120) && (_bloodpressure < 130)) : {_colourBloodP =  _colour80;};
			case ((_bloodpressure >= 130) && (_bloodpressure < 140)) : {_colourBloodP =  _colour70;};
			case ((_bloodpressure >= 140) && (_bloodpressure < 150)) : {_colourBloodP =  _colour50;};
			case ((_bloodpressure >= 150) && (_bloodpressure < 160)) : {_colourBloodP =  _colour40;};
			case ((_bloodpressure >= 160) && (_bloodpressure < 170)) : {_colourBloodP =  _colour30;};
			case ((_bloodpressure >= 170) && (_bloodpressure < 180)) : {_colourBloodP =  _colour20;};
			case ((_bloodpressure >= 180) && (_bloodpressure < 190)) : {_colourBloodP =  _colour10;};
			case (_bloodpressure >= 190) : {_colourBloodP =  _colourDead;};
		};
		*/
		_colourTemp = _colourTempMid;
		switch true do {
			case (_temp < 35.5) : {_colourTemp =  _colourTempLowest;};
			case ((_temp >= 35.5) && (_temp < 36.5)) : {_colourTemp =  _colourTempLower;};
			case ((_temp >= 36.5) && (_temp < 37.5)) : {_colourTemp =  _colourTempMid;};
			case ((_temp >= 37.5) && (_temp < 38.5)) : {_colourTemp =  _colourTempHigher;};
			case (_temp > 38.5) : {_colourTemp =  _colourTempHighest;};
		};
						
		//Hunger
		_colourHunger = _colourDefault;
		switch true do {
			case(_hunger >= 100) : {_colourHunger = _colour100;};
			case((_hunger >= 90) && (_hunger < 100)) :  {_colourHunger =  _colour90;};
			case((_hunger >= 80) && (_hunger < 90)) :  {_colourHunger =  _colour80;};
			case((_hunger >= 70) && (_hunger < 80)) :  {_colourHunger =  _colour70;};
			case((_hunger >= 60) && (_hunger < 70)) :  {_colourHunger =  _colour60;};
			case((_hunger >= 50) && (_hunger < 60)) :  {_colourHunger =  _colour50;};
			case((_hunger >= 40) && (_hunger < 50)) :  {_colourHunger =  _colour40;};
			case((_hunger >= 30) && (_hunger < 40)) :  {_colourHunger =  _colour30;};
			case((_hunger >= 20) && (_hunger < 30)) :  {_colourHunger =  _colour20;};
			case((_hunger >= 10) && (_hunger < 20)) :  {_colourHunger =  _colour10;};
			case((_hunger >= 1) && (_hunger < 10)) :  {_colourHunger =  _colour0;};
			//case(_hunger < 1) : {_colourHunger =  _colourDead;};
		};
		
		//Thirst
		_colourThirst = _colourDefault;	
		switch true do{
			case(_thirst >= 100) : {_colourThirst = _colour100;};
			case((_thirst >= 90) && (_thirst < 100)) :  {_colourThirst =  _colour90;};
			case((_thirst >= 80) && (_thirst < 90)) :  {_colourThirst =  _colour80;};
			case((_thirst >= 70) && (_thirst < 80)) :  {_colourThirst =  _colour70;};
			case((_thirst >= 60) && (_thirst < 70)) :  {_colourThirst =  _colour60;};
			case((_thirst >= 50) && (_thirst < 60)) :  {_colourThirst =  _colour50;};
			case((_thirst >= 40) && (_thirst < 50)) :  {_colourThirst =  _colour40;};
			case((_thirst >= 30) && (_thirst < 40)) :  {_colourThirst =  _colour30;};
			case((_thirst >= 20) && (_thirst < 30)) :  {_colourThirst =  _colour20;};
			case((_thirst >= 10) && (_thirst < 20)) :  {_colourThirst =  _colour10;};
			case((_thirst >= 1) && (_thirst < 10)) :  {_colourThirst =  _colour0;};
			//case(_thirst < 1) : {_colourThirst =  _colourDead;};
		};
		
		//Energy
		_colourEnergy = _colourDefault;
		switch true do{
			case(_energyPercent >= 100) : {_colourEnergy = _colour100;};
			case((_energyPercent >= 90) && (_energyPercent < 100)) :  {_colourEnergy =  _colour90;};
			case((_energyPercent >= 80) && (_energyPercent < 90)) :  {_colourEnergy =  _colour80;};
			case((_energyPercent >= 70) && (_energyPercent < 80)) :  {_colourEnergy =  _colour70;};
			case((_energyPercent >= 60) && (_energyPercent < 70)) :  {_colourEnergy =  _colour60;};
			case((_energyPercent >= 50) && (_energyPercent < 60)) :  {_colourEnergy =  _colour50;};
			case((_energyPercent >= 40) && (_energyPercent < 50)) :  {_colourEnergy =  _colour40;};
			case((_energyPercent >= 30) && (_energyPercent < 40)) :  {_colourEnergy =  _colour30;};
			case((_energyPercent >= 20) && (_energyPercent < 30)) :  {_colourEnergy =  _colour20;};
			case((_energyPercent >= 10) && (_energyPercent < 20)) :  {_colourEnergy =  _colour10;};
			case((_energyPercent >= 1) && (_energyPercent < 10)) :  {_colourEnergy =  _colour0;};
			//case(_energyPercent < 1) : {_colourEnergy =  _colour0;};
		};
		
		//Toxicity
		_colourToxicity = _colourDefault;
		switch true do{
			case(_toxPercent >= 100) : {_colourToxicity = _colourDead;};
			case((_toxPercent >= 90) && (_toxPercent < 100)) :  {_colourToxicity =  _colour0;};
			case((_toxPercent >= 80) && (_toxPercent < 90)) :  {_colourToxicity =  _colour10;};
			case((_toxPercent >= 70) && (_toxPercent < 80)) :  {_colourToxicity =  _colour20;};
			case((_toxPercent >= 60) && (_toxPercent < 70)) :  {_colourToxicity =  _colour30;};
			case((_toxPercent >= 50) && (_toxPercent < 60)) :  {_colourToxicity =  _colour40;};
			case((_toxPercent >= 40) && (_toxPercent < 50)) :  {_colourToxicity =  _colour50;};
			case((_toxPercent >= 30) && (_toxPercent < 40)) :  {_colourToxicity =  _colour60;};
			case((_toxPercent >= 20) && (_toxPercent < 30)) :  {_colourToxicity =  _colour70;};
			case((_toxPercent >= 10) && (_toxPercent < 20)) :  {_colourToxicity =  _colour80;};
			case((_toxPercent >= 1) && (_toxPercent < 10)) :  {_colourToxicity =  _colour90;};
			case(_toxPercent < 1) : {_colourToxicity =  _colour100;};
		};
		_colorNuclear = _colourDefault;
		switch true do{
			case(_percentNuclear >= 100) : {_colorNuclear = _colour0;};
			case((_percentNuclear >= 90) && (_percentNuclear < 95)) :  {_colorNuclear =  _colour0;};
			case((_percentNuclear >= 80) && (_percentNuclear < 90)) :  {_colorNuclear =  _colour10;};
			case((_percentNuclear >= 70) && (_percentNuclear < 80)) :  {_colorNuclear =  _colour20;};
			case((_percentNuclear >= 60) && (_percentNuclear < 70)) :  {_colorNuclear =  _colour30;};
			case((_percentNuclear >= 50) && (_percentNuclear < 60)) :  {_colorNuclear =  _colour40;};
			case((_percentNuclear >= 40) && (_percentNuclear < 50)) :  {_colorNuclear =  _colour50;};
			case((_percentNuclear >= 30) && (_percentNuclear < 40)) :  {_colorNuclear =  _colour60;};
			case((_percentNuclear >= 20) && (_percentNuclear < 30)) :  {_colorNuclear =  _colour70;};
			case((_percentNuclear >= 10) && (_percentNuclear < 20)) :  {_colorNuclear =  _colour80;};
			case((_percentNuclear >= 1) && (_percentNuclear < 10)) :  {_colorNuclear =  _colour90;};
			case(_percentNuclear < 1) : {_colorNuclear =  _colour100;};
		};		
		//Stamina
		_colourStamina = _colourDefault;
		
		// Fatigue
		_colourFatigue = _colourDefault;
		switch true do{
			case(_fatigue > 100) : {_colourFatigue = _colourDead;};
			case((_fatigue > 90) && (_fatigue <= 100)) :  {_colourFatigue =  _colour0;};
			case((_fatigue >= 80) && (_fatigue <=90)) :  {_colourFatigue =  _colour10;};
			case((_fatigue >= 70) && (_fatigue < 80)) :  {_colourFatigue =  _colour20;};
			case((_fatigue >= 60) && (_fatigue < 70)) :  {_colourFatigue =  _colour30;};
			case((_fatigue >= 50) && (_fatigue < 60)) :  {_colourFatigue =  _colour40;};
			case((_fatigue >= 40) && (_fatigue < 50)) :  {_colourFatigue =  _colour50;};
			case((_fatigue >= 30) && (_fatigue < 40)) :  {_colourFatigue =  _colour60;};
			case((_fatigue >= 20) && (_fatigue < 30)) :  {_colourFatigue =  _colour70;};
			case((_fatigue >= 10) && (_fatigue < 20)) :  {_colourFatigue =  _colour80;};
			case((_fatigue >= 0) && (_fatigue < 10)) :  {_colourFatigue =  _colour90;};
		};		

		// Restart
		_colourRestart = _colourDefault;
		_serverTime = serverTime/60;
		switch (true) do {
			case {(_restartInterval - _serverTime) <= 15 && (_restartInterval - _serverTime) > 5} : {_colourRestart = _colour50;};
			case {(_restartInterval - _serverTime) <= 5} : {_colourRestart = _colour90;};
		};
		
		if (_blinkSetBlack) then
		{
			//if (_damage < 10) then {_colourDamage = _colourDead;};
			//if (_hunger < 10) then {_colourHunger = _colourDead;};
			//if (_thirst < 10) then {_colourThirst = _colourDead;};
			//if ((_restartInterval - _serverTime) < 5) then {_colourRestart = _colourDead;};
		};
		
		private ["_displayFormat"];
		_displayFormat = "<t shadow='1' shadowColor='#000000' color='%2'><img size='1.6'  shadowColor='#000000' image='addons\status_bar\images\players.paa' color='%3'/> %4  </t> ";
		_displayFormat = _displayFormat + "<t shadow='1' shadowColor='#000000' color='%2'><img size='1.4'  shadowColor='#000000' image='addons\status_bar\images\health.paa' color='%5'/> %6%1  </t>";
		_displayFormat = _displayFormat + "<t shadow='1' shadowColor='#000000' color='%2'><img size='1.6'  shadowColor='#000000' image='addons\status_bar\images\hunger.paa' color='%7'/> %8%1  </t>";
		_displayFormat = _displayFormat + "<t shadow='1' shadowColor='#000000' color='%2'><img size='1.6'  shadowColor='#000000' image='addons\status_bar\images\thirst.paa' color='%9'/> %10%1  </t>";
		_displayFormat = _displayFormat + "<t shadow='1' shadowColor='#000000' color='%2'><img size='1.2'  shadowColor='#000000' image='addons\status_bar\images\biohazard.paa' color='%11'/> %12  </t>";
		_displayFormat = _displayFormat + "<t shadow='1' shadowColor='#000000' color='%2'><img size='1.2'  shadowColor='#000000' image='addons\status_bar\images\nuclear.paa' color='%13'/> %14  </t>";
		_displayFormat = _displayFormat + "<t shadow='1' shadowColor='#000000' color='%2'><img size='1.2'  shadowColor='#000000' image='addons\status_bar\images\temp.paa' color='%15'/> %16  </t>";
		//_displayFormat = _displayFormat + "<t shadow='1' shadowColor='#000000' color='%2'><img size='1.2'  shadowColor='#000000' image='addons\status_bar\images\nuclear.paa' color='%13'/> %14  </t>";
		
		_displayFormat = _displayFormat + "<t shadow='1' shadowColor='#000000' color='%2'><img size='1.6'  shadowColor='#000000' image='addons\status_bar\images\energy.paa' color='%17'/> %18  </t>";
		_displayFormat = _displayFormat +"<t shadow='1' shadowColor='#000000' color='%2'>    |    </t>";		
		_displayFormat = _displayFormat + "<t shadow='1' shadowColor='#000000' color='%2'> [F4] Earplugs [WW] Autorun<t/>";
		_displayFormat = _displayFormat +"<t shadow='1' shadowColor='#000000' color='%2'>    |    </t>";		
		_displayFormat = _displayFormat + "<t shadow='1' shadowColor='#000000' color='%2'><img size='1.6'  shadowColor='#000000' image='addons\status_bar\images\krypto.paa' color='%2'/> %19  </t>";
		_displayFormat = _displayFormat + "<t shadow='1' shadowColor='#000000' color='%2'><img size='1.6'  shadowColor='#000000' image='addons\status_bar\images\restart.paa' color='%2'/>%21:%22  </t>";
		_displayFormat = _displayFormat + "<t shadow='1' shadowColor='#000000' color='%2'>  FPS: %23 </t>";		
		if ((getplayerUID player) in ["76561197995799489","76561198206211968"]) then
		{
			//_displayFormat = _displayFormat + "<t shadow='1' shadowColor='#000000' color='%2'> SFPS: %24  </t>";
		};

		
		//display the information 
		((uiNamespace getVariable "osefStatusBar")displayCtrl 55555)ctrlSetStructuredText parseText 
			format[_displayFormat,
					"%", 			  	//  1
					_colourDefault,		// 2					
					_colorPlayerCount,	// 3
					count allPlayers, 	// 4
					_colourDamage,		 // 5				
					_damage,			 // 6
					_colourHunger,		 // 7
					_hunger, 			 // 8	
					_colourThirst,		 // 9					
					_thirst, 			 // 10
					_colourToxicity,	 // 11
					_toxPercent,		 // 12
					_colorNuclear,		 // 13
					_percentNuclear,	 // 14
					_colourTemp,			// 15
					_temp,				// 16
					_colourEnergy,		 // 17
					_energyPercent, 	 // 18							
					_wallet, 			 // 19
					_colorRestart,		 // 20
					_hours,				 // 21
					_minutes,			 // 22
					round diag_fps//, 	 // 23
					//round _serverFPS // 24
					
					/*
					_stamina,			 // 9
					_colourStamina,		 // 15
					_fatigue,			 // 20
					_colourFatigue,		 // 21
					_colorEarplugs,		 // 22
					_colorAutoRun,		// 23
					_firstAidColor,		// 24
					_colourDefault,		// 25
					*/

				];
	}; 
};