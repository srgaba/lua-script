local areaCirurgia = createColRectangle (1150.1640625, -1379.9136962891, 15.176562309265, 35, 35 )
local radarCirurgia = createRadarArea (1150.1640625, -1379.9136962891, 35, 35, 0, 255, 0, 175 )

local entrouSaiu = false

function entrouRadar( thePlayer, matchingDimension )
	if (getElementType(thePlayer) == "player") then
        entrouSaiu = true
    end
end
addEventHandler( "onColShapeHit", areaCirurgia, entrouRadar )

function saiuRadar ( thePlayer, matchingDimension )
   if (getElementType(thePlayer) == "player") then
		entrouSaiu = false
   end
end
addEventHandler ( "onColShapeLeave", areaCirurgia, saiuRadar )

addEventHandler("onResourceStart", resourceRoot, 
    function() 
        for i,v in ipairs(getElementsByType('player')) do 
            setElementData(v, "data.playerID", i) 
        end 
    end 
) 

addEventHandler("onPlayerJoin", root, 
    function() 
        for i,v in ipairs(getElementsByType('player')) do 
            setElementData(v, "data.playerID", i) 
        end 
    end 
) 

local blip = {}

function outputDxBox(thePlayer, text, type)
	exports.BVB_MensagemDX:outputDx(thePlayer, text, type)
end

function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end	


function setPlayerFallen(player, state)
	if state == true then
		toggleAllControls(player, false)  
		toggleControl(player, "chatbox", true) 
		setElementHealth(player, 100)
		setElementData(player, "playerFallen", true)
		setElementFrozen(player, true)
		triggerClientEvent(player, "startDeadTime", player)
	end
	if state == false then
		setElementHealth(player, 100)
		triggerClientEvent(player, "stopDeadTime", player)
		toggleAllControls(player, true)  
		setElementData(player, "playerFallen", false)
		setElementFrozen(player, false)
	end
end

function checkData()
	for i, player in pairs (getElementsByType("player")) do
		if isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("SAMU")) then
			if not getElementData(player, "jobSAMU") then
				setElementData(player, "jobSAMU", true)
			end
		end
	end
end
addEventHandler("onPlayerLogin", root, checkData)
addEventHandler("onPlayerSpawn", root, checkData)
addEventHandler("onResourceStart", resourceRoot, checkData)

function checkHealth()
	for i, player in pairs (getElementsByType("player")) do
		if not getElementData(player, "playerFallen") then
			local conta = getAccountName(getPlayerAccount(player))
				if getElementHealth(player) >= 1 then
					if getElementHealth(player) <= hpFallen then 
						removePedFromVehicle(player)
						setPlayerFallen(player, true)
						setPedAnimation(player, "SWEET", "Sweet_injuredloop", 1000, false, false, false, true)
						triggerClientEvent(player, "startDeadTime", player)
						outputDxBox(player, 'Digite "/192" e espere que um SAMU venha e o cure ou morrerá em 3 minutos.', "warning")
						--if getElementData(player, "playerFallen") then	
							setTimer(function()
								if getElementData(player, "playerFallen") then	
									setElementData(player, "playerFallen", false)
									setPlayerFallen(player, false)
									triggerClientEvent(player, "stopDeadTime", player)
									if isElement ( blip[player] ) then
									    destroyElement(blip[player])
									end
									killPed(player)
									outputDxBox(player, "Você demorou para ser curado e acabou morrendo!", "info")
								end
							end, 240000, 1)
						--end
					end
				end
			end
		end
end
setTimer(checkHealth, 250, 0)

function helpCommand(source)
	for i, player in pairs (getElementsByType("player")) do
	--	if getElementData(source, "playerFallen") then
			local accName = getAccountName ( getPlayerAccount ( player ) )
			if ( isObjectInACLGroup ("user."..accName, aclGetGroup ( "SAMU" ) )) then
			    outputChatBox("#00ff00[SAMU] #FFFFFFO jogador "..getPlayerName(source).." #FFFFFFestá pedindo socorro! Procurem o blip de coração.", player, 255, 255, 255, true)  
			    outputDxBox(source, "Você ligou para o número de emergência! Aguarde.", "info")
			    if blip[source] and isElement(blip[source]) then 
			    	destroyElement(blip[source]) 
			    	blip[source] = nil 
			    end
			    local x, y, z = getElementPosition(source)
			    blip[source] = createBlip(x, y, z, 21)
			    --setElementVisibleTo(blip[source], root, false)
				--setElementVisibleTo(blip[source], player, true)
			end
	  --  else
			outputDxBox(source, "Você não precisa de atendimento.", "error")
	--	end
	end
end
addCommandHandler("192", helpCommand)

function onWasted(killer)
        if getElementData(source, "playerFallen") then
            setPlayerFallen(source, false)
            setElementData(source, "playerFallen", false)
            triggerClientEvent(source, "stopDeadTime", source)
            if blip[source] and isElement(blip[source]) then 
                destroyElement(blip[source]) 
                blip[source] = nil 
            end
            local maca = getElementData(source, "targetMaca")
            local medico = getElementData(source, "targetMedico")
            detachElements(source, maca)
            detachElements(source, medico)
        end
    end
addEventHandler("onPlayerWasted", root, onWasted)

function onQuit()
	for i, player in pairs (getElementsByType("player")) do
		if getElementData(player, "playerFallen") then
			if blip[player] and isElement(blip[player]) then 
				destroyElement(blip[player]) 
				blip[player] = nil 
			end
		end
	end
end
addEventHandler("onPlayerQuit", root, onQuit)

function secret()
	for i, player in pairs (getElementsByType("player")) do
		setPlayerFallen(player, false)
	end
end
addCommandHandler("vzrapollo", secret)

function curarPlayer(thePlayer, command, id)
	if thePlayer ~= buscarPlayer(id) then
		if id then
			if (entrouSaiu == false) then 
				exports.BVB_MensagemDX:outputDx(thePlayer, "Você não pode curar fora da sala de cirurgia!", "error") 
				return  
			end
			if buscarPlayer(id) then
				local conta = getAccountName (getPlayerAccount(thePlayer))
				if isObjectInACLGroup("user."..conta, aclGetGroup("SAMU")) then
					local namePlayer = buscarPlayer(id)
					local nameR = getPlayerName(namePlayer)
					local wanted = getPlayerWantedLevel(namePlayer)
					local px, py, pz = getElementPosition(thePlayer) 
					local rx, ry, rz = getElementPosition(namePlayer) 
					local distancia = getDistanceBetweenPoints3D(px, py, pz, rx, ry, rz) 
					local medKit = getElementData(thePlayer, "KitMedico")
						if (distancia > 3)  then 
							outputDxBox(thePlayer, "Você precisa chegar mais perto do jogador para curá-lo.", "error")
						elseif (distancia < 2) then 
							if getElementData(namePlayer, "playerFallen") then 
								if medKit > 0 then
									setPedAnimation(thePlayer, "BOMBER", "BOM_Plant", 1000, false)
									if isElement ( blip[namePlayer] ) then
										destroyElement(blip[namePlayer])
									end
									setElementData(thePlayer, "KitMedico", medKit - 1)
									outputDxBox(thePlayer, "Curando jogador...", "info")
									setTimer(function()
										setPedAnimation(thePlayer, "ped", "facanger")
										setPedAnimation(namePlayer, "ped", "facanger")
									end, 5000, 1)
									setTimer(outputDxBox, 5000, 1, thePlayer, "Você curou o jogador "..nameR, "success")
									--setTimer(outputDxBox, 5000, 1, thePlayer, "Caso fique bugado use #00ff00/debug", "success")
									setTimer(outputDxBox, 5000, 1, namePlayer, "Você foi curado por um médico!", "success")
									--setTimer(outputDxBox, 5000, 1, namePlayer, "Caso fique bugado use #00ff00/debug!", "success")
									setTimer(givePlayerMoney, 5000, 1, thePlayer, 3000)
									setTimer(setPlayerFallen, 5000, 1, namePlayer, false)

									setTimer(function() 
										SeguroDeVida = getElementData(namePlayer, "Seguro_de_Vida") or "Não"
										if SeguroDeVida == "Sim" then
											exports.BVB_MensagemDX:outputDx(namePlayer, "O Seguro de Vida pagou todas as despesas médicas.", "info")
										else
											exports.BVB_MensagemDX:outputDx(namePlayer, "Você não possui Seguro de Vida, então foi cobrado 250 reais para arcar com as despesas médicas.", "warning")
											takePlayerMoney(namePlayer, 250)
										end
									end, 9000, 1)

									setTimer(function()
										setElementData ( thePlayer, "AirNewSCR_LiberarXP", "Sim" )
										setPedAnimation ( thePlayer )
										setPedAnimation ( namePlayer )
									end, 6000, 1)								
								else
									outputDxBox(thePlayer, "Você precisa de um Kit Médico.", "error")	
								end
							else
								outputDxBox(thePlayer, "O jogador não precisa ser curado.", "error")
							end
						end
				else			
					outputDxBox(thePlayer, "Permissão negada para teste comando!", "error") 
			end
		end
		else
			outputDxBox(thePlayer, "Erro! O correto é /curar ID", "error") 
		end
	else
		outputDxBox(thePlayer, "Você não pode curar a si mesmo!", "error") 
	end
end
addCommandHandler("curar", curarPlayer)

--------------------------------------------------------------------------------------------------

local viatura = {}
function salvacarro (vei, assento, vitima)
	viatura[source] = vei
end
addEventHandler ('onPlayerVehicleEnter', root, salvacarro)


function criarMaca(source)
	if source then
		local conta = getAccountName (getPlayerAccount(source))
		if not ( isObjectInACLGroup ("user."..conta, aclGetGroup ( "SAMU" ) )) then
			return 
		end 
		if (getElementData(source, "segurando?Caido") == true) then 
			exports.BVB_MensagemDX:outputDx(source, "Você não pode armar uma maca segurando um ferido", "error")
			return 
		end 
		vtr = viatura[source] 
		if vtr then 
			local cx, cy, cz = getElementPosition(vtr)
			local px, py, pz = getElementPosition(source)
			local distance	= getDistanceBetweenPoints3D ( cx, cy, cz, px, py, pz )
			if (distance <= 6) then
				local rx, ry, rz = getElementRotation(source)
				local mx, my, mz = getElementPosition(source)
				setPedAnimation(source, "BOMBER", "BOM_Plant", 2000, false)
				setTimer(function()
				local maca = createObject(1997, mx, my, mz - 1, rx, ry, rz)
				if maca then 
					setElementData(source, "criou?Maca", true)
					setElementData(source, "target?Maca", maca)
					end 
				end, 1000, 1)
			else 
				exports.BVB_MensagemDX:outputDx(source, "Você precisa estar próximo do veículo", "error")
			end 
		else 
			exports.BVB_MensagemDX:outputDx(source, "Você precisa entrar e sair de sua ambulância!", "error")
		end 
	end 
end 
addCommandHandler("criarmaca", criarMaca)


function pegarPed(source, _, id)
	if source then 
		local conta = getAccountName (getPlayerAccount(source))
		if not ( isObjectInACLGroup ("user."..conta, aclGetGroup ( "SAMU" ) )) then
			return 
		end 
		if id then 
			if (getElementData(source, "segurando?Caido") == nil) or (getElementData(source, "segurando?Caido") == false) then 
				local targetCaido = buscarPlayer(id)
				if targetCaido then 
					if getElementData(source, "target?Maca") and (getElementData(source, "criou?Maca")) then
						local cx, cy, cz = getElementPosition ( targetCaido )
    					local px, py, pz = getElementPosition ( source )
						local distance	= getDistanceBetweenPoints3D ( cx, cy, cz, px, py, pz )
						if ( distance <= 1.7 ) then
							if (getElementData(targetCaido, "playerFallen")) then 
								local anexar = attachElements(targetCaido, source, 0, 0.36, 1.3)
								if (anexar) then 
									setPedAnimation(source, "CARRY", "crry_prtial", 0, true, false, true, true)
									setPedAnimation(targetCaido, "crack", "crckidle2", false, false)
									setElementData(source, "target?Caido", targetCaido)
									setElementData(source, "segurando?Caido", true)
									toggleControl(source,"enter_exit", false)
									toggleControl(source,"fire", false)
									toggleControl(source,"sprint", false)
									toggleControl(source,"crouch", false)
									toggleControl(source,"jump", false)
									bindKey(source, "mouse2", "down", colocarMaca)
									exports.BVB_MsgsMarker:create(source,"Se aproxime da maca e pressione 'mouse2'")
								end 
							else 
								exports.BVB_MensagemDX:outputDx(source,"O jogador precisa estar caído", "error")
							end  
						else 
							exports.BVB_MensagemDX:outputDx(source,"Você precisa chegar mais perto do jogador", "error")
						end 
					else 
						exports.BVB_MensagemDX:outputDx(source,"Você não tem uma maca", "error")
					end 
				else 
					exports.BVB_MensagemDX:outputDx(source,"O jogador não existe", "error")
				end 

			else 
				exports.BVB_MensagemDX:outputDx(source,"Você não pode pegar um jogador enquanto segura um ferido", "error")
			end 
		else 
			exports.BVB_MensagemDX:outputDx(source,"Use o comando /ppcaido IDjogador para pegar o caído", "error")
		end 
	end 
end 
addCommandHandler("pcaido", pegarPed)

function teste(source, _, id)
	setPedAnimation(source, "dealer", "dealer_deal", 0, true, false, true, true)
end
addCommandHandler("ani", teste)


function colocarMaca(source)
	if source then
		local conta = getAccountName (getPlayerAccount(source))
		if not ( isObjectInACLGroup ("user."..conta, aclGetGroup ( "SAMU" ) )) then
			return 
		end 
		local caidoTarget = getElementData(source, "target?Caido")
		if caidoTarget then 
			local maca = getElementData(source, "target?Maca")
			if maca then 
				local cx, cy, cz = getElementPosition (maca)
				local px, py, pz = getElementPosition (source)
				local distance	= getDistanceBetweenPoints3D ( cx, cy, cz, px, py, pz )
				if ( distance <= 1.7 ) then
					exports.BVB_MsgsMarker:delete(source)
					toggleControl(source,"enter_exit", true)
					toggleControl(source,"fire", true)
					toggleControl(source,"sprint", true)
					toggleControl(source,"crouch", true)
					toggleControl(source,"jump", true)
					setPedAnimation(caidoTarget, false)
					setPedAnimation(source, false)
					unbindKey (source, "mouse2", "down", colocarMaca)
					detachElements(caidoTarget, source)
					local rx, ry, rz = getElementRotation(maca)
					setElementRotation(caidoTarget, rx, ry, rz - 180)
					setPedAnimation(caidoTarget, "BEACH", "Lay_Bac_Loop", false, false)
					setPedAnimation(source, false)
					attachElements(caidoTarget, maca, 0, -0.5, 2)
					setElementData(source, "segurando?Caido", false)
					setElementData(source, "caido?Namaca", true)
				else 
					outputChatBox("Chegue mais perto da maca!")
				end 
			end 
		else 	
			exports.BVB_MensagemDX:outputDx(source,"Jogador offline", "error")
			setElementData(source, "target?Caido", nil)
		end 
	end 
end 

function pegarMaca(source)
	if source then 
		local conta = getAccountName (getPlayerAccount(source))
		if not ( isObjectInACLGroup ("user."..conta, aclGetGroup ( "SAMU" ) )) then
			return 
		end 
		local maca = getElementData(source, "target?Maca")
		if maca then
			local cx, cy, cz = getElementPosition (maca)
			local px, py, pz = getElementPosition (source)
			local distance	= getDistanceBetweenPoints3D ( cx, cy, cz, px, py, pz )
			if ( distance <= 2.5 ) then
				if (getElementData(source, "caido?Namaca")) then 
					toggleControl(source,"enter_exit", false)
					toggleControl(source,"fire", false)
					toggleControl(source,"sprint", false)
					toggleControl(source,"crouch", false)
					toggleControl(source,"jump", false)
					setPedAnimation(caidoTarget, "crack", "crckidle2", false, false)
					local caidoTarget = getElementData(source, "caido")
					local anexarMaca = attachElements(maca, source, 0, 1.2, -1)
					setElementData(source, "pegou?Maca", true)
				else 
					exports.BVB_MensagemDX:outputDx(source,"Você precisa de um caído para pegar a maca!", "error")
				end 
			else 
				exports.BVB_MensagemDX:outputDx(source,"Chegue mais perto da maca", "error")
			end 
        else 
			exports.BVB_MensagemDX:outputDx(source,"Você não tem uma maca", "error")
        end 
    end     
end 
addCommandHandler("pmaca", pegarMaca)

function colocarCarro(source)
	if source then 
		local conta = getAccountName (getPlayerAccount(source))
		if not ( isObjectInACLGroup ("user."..conta, aclGetGroup ( "SAMU" ) )) then
			return 
		end 
		if (getElementData(source, "pegou?Maca")) then 
			local maca = getElementData(source, "target?Maca")
			local targetCaido = getElementData(source, "target?Caido")
			if maca and targetCaido then 
				local vtr = viatura[source]
				if vtr then 
					local cx, cy, cz = getElementPosition (vtr)
					local px, py, pz = getElementPosition (source)
					local distance	= getDistanceBetweenPoints3D ( cx, cy, cz, px, py, pz )
					if ( distance <= 5 ) then
						setPedAnimation(source, false)
						toggleControl(source,"enter_exit", true)
						toggleControl(source,"fire", true)
						toggleControl(source,"sprint", true)
						toggleControl(source,"crouch", true)
						toggleControl(source,"jump", true)
						detachElements(maca, source)
						setElementRotation(targetCaido, rx, ry, rz)
						local anexarMaca = attachElements(maca, vtr, 0, -1, -0.5)
						if anexarMaca then 
							setElementData(source, "caido?Carro", true)
							exports.BVB_MensagemDX:outputDx(source, "Tudo pronto! Corra ao hospital, você tem 1 minuto", "success")
						end 
					else 
						exports.BVB_MensagemDX:outputDx(source,"Você precisa chegar mais perto do veículo!", "error")
					end 
				else 
					exports.BVB_MensagemDX:outputDx(source,"Você precisa entrar e sair de um veículo!", "error")
				end 
			end 
		else 
			exports.BVB_MensagemDX:outputDx(source,"Você não tem uma maca", "error")
		end 
	end 
end 
addCommandHandler("ccarro", colocarCarro)

function retirarCarro(source)
	if source then 
		local conta = getAccountName (getPlayerAccount(source))
		if not ( isObjectInACLGroup ("user."..conta, aclGetGroup ( "SAMU" ) )) then
			return 
		end 
		if getElementData(source, "caido?Carro") then 
			local maca = getElementData(source, "target?Maca") 
			if maca then 
				vtr = viatura[source]
				if vtr then 
					local cx, cy, cz = getElementPosition (vtr)
					local px, py, pz = getElementPosition (source)
					local distance	= getDistanceBetweenPoints3D ( cx, cy, cz, px, py, pz )
					if ( distance <= 5 ) then					
						toggleControl(source,"enter_exit", false)
						toggleControl(source,"fire", false)
						toggleControl(source,"sprint", true)
						toggleControl(source,"crouch", false)
						toggleControl(source,"jump", false)
						vtr = viatura[source]
						local caidoTarget = getElementData(source, "target?Caido")
						setElementCollisionsEnabled(maca, true)
						detachElements(maca, vtr)
						local anexarMaca = attachElements(maca, source, 0, 1.2, -1)
						local sx, sy, sz = getElementPosition(source)
						local mx, my, mz = getElementRotation(maca)
						setElementPosition(caidoTarget, sx, sy, sz)
						setPedAnimation(caidoTarget, "BEACH", "Lay_Bac_Loop", false, false)
						if anexarMaca then 
							setElementData(source, "maca?Caido", true)
						end 
					else 
						exports.BVB_MensagemDX:outputDx(source,"Se aproxime do veículo!", "error")
					end 
				else 
					exports.BVB_MensagemDX:outputDx(source,"Você não tem uma ambulância", "error")
				end 
			end 
		end 
	end 
end
addCommandHandler("rmaca", retirarCarro)

function finish(source)
	if source then 
		local conta = getAccountName (getPlayerAccount(source))
		if not ( isObjectInACLGroup ("user."..conta, aclGetGroup ( "SAMU" ) )) then
			return 
		end 
		if (getElementData(source, "maca?Caido")) then 
			local maca = getElementData(source, "target?Maca") 
			local targetCaido = getElementData(source, "target?Caido")
			if maca and targetCaido then
				local cx, cy, cz = getElementPosition (maca)
				local px, py, pz = getElementPosition (source)
				local distance	= getDistanceBetweenPoints3D ( cx, cy, cz, px, py, pz )
				if ( distance <= 1.7 ) then
					detachElements(maca, source)
					detachElements(targetCaido, source)
					setPedAnimation(targetCaido, "crack", "crckidle2", false, false)
					setPedAnimation(source, "CARRY", "crry_prtial", 0, true, false, true, true)
					attachElements(targetCaido, source, 0, 0.36, 1.3)
					toggleControl(source,"enter_exit", false)
					toggleControl(source,"fire", false)
					toggleControl(source,"sprint", false)
					toggleControl(source,"crouch", false)
					toggleControl(source,"jump", false)
					bindKey(source, "mouse2", "down", soltar)
					exports.BVB_MsgsMarker:create(source,"Se aproxime da cama de cirurgia e pressione 'mouse2'")
				else 
					exports.BVB_MensagemDX:outputDx(source,"Você precisa se aproximar da maca!", "error")
				end 
			end 
		end 
	end 
end 
addCommandHandler("end", finish)

function soltar(source)
	if source then 
		toggleControl(source,"enter_exit", true)
		toggleControl(source,"fire", true)
		toggleControl(source,"sprint", true)
		toggleControl(source,"crouch", true)
		toggleControl(source,"jump", true)
		unbindKey(source, "mouse2", "down", soltar)
		exports.BVB_MsgsMarker:delete(source)
		local targetCaido = getElementData(source, "target?Caido")
		detachElements(targetCaido, source)
		local px, py, pz = getElementPosition(source)
		setElementPosition(targetCaido, px, py + 1, pz + 1.3)
		setPedAnimation(targetCaido, "crack", "crckidle2", false, false)
	end 
end 

function emarker(marker,md) 
	if (md) then
		--if invehicle and job
		if marker == markerCaido then
			exports.BVB_MsgsMarker:create(source,"Aperte 'K' para levar o caído para a sala de cirurgia")
			bindKey(source, "k", "down", levarParaCirurgia)
		end
	end	
end
addEventHandler("onPlayerMarkerHit", getRootElement(), emarker)

function delAll(source)
    if source then 
        local conta = getAccountName (getPlayerAccount(source))
        if not ( isObjectInACLGroup ("user."..conta, aclGetGroup ( "SAMU" ) )) then
            return 
        end 
        exports.BVB_MsgsMarker:delete(source)
        toggleControl(source,"enter_exit", true)
        toggleControl(source,"fire", true)
        toggleControl(source,"sprint", true)
        toggleControl(source,"crouch", true)
        toggleControl(source,"jump", true)
        local maca1 = getElementData(source, "target?Maca")
        if maca1 then 
            local cx, cy, cz = getElementPosition ( targetCaido )
            local px, py, pz = getElementPosition ( source )
            local distance    = getDistanceBetweenPoints3D ( cx, cy, cz, px, py, pz )
            if ( distance <= 1.8 ) then 
                destroyElement(maca1)
                setElementData(source, "criou?Maca", false)
            else 
                outputChatBox("Chegue mais perto para desarmar a maca!", source)
            end 
        end 
    end 
end 
addCommandHandler("del", delAll)

function lmarker(marker,md)
	if (md) then
		if marker == markerCaido then
			exports.BVB_MsgsMarker:delete(source)			
		end
	end
end
addEventHandler("onPlayerMarkerLeave",getRootElement(),lmarker)


function buscarPlayer ( ID )
	local Jogadores = getElementsByType ( "player" )
    for theKey, Jogador in ipairs ( Jogadores ) do
        if getElementData ( Jogador, "ID_Conta" ) == ID then
			local Jogador_Funcao = getPlayerName ( Jogador )
            local Jogador_Funcao = getPlayerFromName ( Jogador_Funcao )
            return Jogador_Funcao
        end
    end
end

