-- data/scripts/entity/merchants/factory.lua
-- Increases number of deliver/fetch routes to 6

local ROUTES_MAX_COUNT = 6
local ROUTES_DEFAULT_COUNT = 3

local base_initialize = Factory.initialize
local base_refreshConfigUI = Factory.refreshConfigUI

Factory.buildConfigUI = function(tab)
    local thsplit = UIHorizontalSplitter(Rect(tab.size), 10, 0, 0.35)
    local thsplit2 = UIHorizontalSplitter(thsplit.top, 10, 0, 0.75)

    -- top area showing production
    tab:createFrame(thsplit2.top)

    local vsplit = UIVerticalMultiSplitter(thsplit2.top, 80, 10, 2)

    local lister = UIVerticalLister(vsplit:partition(0), 4, 0)
    ingredientLabels = {}
    for i = 1, 20 do
        local rect = lister:nextRect(10)
        local vsplit = UIVerticalSplitter(rect, 5, 0, 0.86)

        local left = tab:createLabel(vsplit.left, "", 11)
        left:setLeftAligned()
        left.font = FontType.Normal

        local right = tab:createLabel(vsplit.left, "", 11)
        right:setRightAligned()
        right.font = FontType.Normal

        local supply = tab:createLabel(vsplit.right, "", 11)
        supply:setRightAligned()
        supply.font = FontType.Normal
        supply.color = ColorRGB(0, 1, 0)

        table.insert(ingredientLabels, { left = left, right = right, supply = supply })
    end

    local lister = UIVerticalLister(vsplit:partition(1), 4, 0)
    productLabels = {}
    for i = 1, 20 do
        local rect = lister:nextRect(10)
        local vsplit = UIVerticalSplitter(rect, 5, 0, 0.86)

        local left = tab:createLabel(vsplit.left, "", 11)
        left:setLeftAligned()
        left.font = FontType.Normal

        local right = tab:createLabel(vsplit.left, "", 11)
        right:setRightAligned()
        right.font = FontType.Normal

        local supply = tab:createLabel(vsplit.right, "", 11)
        supply:setRightAligned()
        supply.font = FontType.Normal
        supply.color = ColorRGB(0, 1, 0)

        table.insert(productLabels, { left = left, right = right, supply = supply })
    end

    local lister = UIVerticalLister(vsplit:partition(2), 4, 0)
    statsLabels = {}
    for i = 1, 8 do
        local rect = lister:nextRect(10)

        local left = tab:createLabel(rect, "", 11)
        left:setLeftAligned()
        left.font = FontType.Normal

        local right = tab:createLabel(rect, "", 11)
        right:setRightAligned()
        right.font = FontType.Normal

        table.insert(statsLabels, { left = left, right = right })
    end

    local a = vsplit:partition(0)
    local b = vsplit:partition(1)
    local center = (a.center + b.center) / 2

    local r = Rect(center - 30, center + 30)
    r.position = r.position + vec2(0, -20)
    productionIcon = tab:createPicture(r, "data/textures/icons/production.png")
    productionIcon.isIcon = true

    r.position = r.position + vec2(0, 40)
    numProductionsLabel = tab:createLabel(r, "x3", 20)
    numProductionsLabel:setCenterAligned()

    -- error label for production problems
    productionErrorSign = UICollection()
    local frame = tab:createFrame(thsplit2.bottom)

    thsplit2:setPadding(15, 15, 15, 15)

    local label = tab:createLabel(thsplit2.bottom, "Station can't produce because ingredients are missing!"%_t, 14)
    label.color = ColorRGB(1, 1, 0)
    label.centered = true

    local vsplit = UIVerticalSplitter(thsplit2.bottom, 0, 0, 0.5)
    vsplit:setLeftQuadratic()

    local icon = tab:createPicture(vsplit.left, "data/textures/icons/hazard-sign.png")
    icon.isIcon = true
    icon.color = ColorRGB(1, 1, 0)
    icon.lower = icon.lower - vec2(5, 5)
    icon.upper = icon.upper + vec2(5, 5)

    productionErrorSign:insert(label)
    productionErrorSign:insert(icon)
    productionErrorSign:insert(frame)
    productionErrorSign.label = label
    productionErrorSign.icon = icon

    productionErrorSign:hide()


    -- lower area with config options
    local hsplit = UIHorizontalSplitter(thsplit.bottom, 10, 0, 0.8)
    local vsplit = UIVerticalMultiSplitter(thsplit.bottom, 10, 0, 2)
    local lister = UIVerticalLister(vsplit:partition(0), 5, 0)

    basePriceLabel = tab:createLabel(Rect(), "Base Price %"%_t, 12)
    lister:placeElementTop(basePriceLabel)
    basePriceLabel.centered = true

    basePriceSlider = tab:createSlider(Rect(), -20, 20, 40, "", "onBasePriceSliderChanged")
    lister:placeElementTop(basePriceSlider)
    basePriceSlider:setValueNoCallback(0)
    basePriceSlider.unit = "%"
    basePriceSlider.tooltip = "Sets the base price of goods bought and sold by this station. A low base price attracts more buyers and a high base price attracts more sellers."%_t

    lister:nextRect(15)

    allowBuyCheckBox = tab:createCheckBox(Rect(), "Buy goods from others"%_t, "onAllowBuyChecked")
    lister:placeElementTop(allowBuyCheckBox)
    allowBuyCheckBox:setCheckedNoCallback(true)
    allowBuyCheckBox.tooltip = "If checked, the station will buy goods from traders from other factions than you."%_t

    allowSellCheckBox = tab:createCheckBox(Rect(), "Sell goods to others"%_t, "onAllowSellChecked")
    lister:placeElementTop(allowSellCheckBox)
    allowSellCheckBox:setCheckedNoCallback(true)
    allowSellCheckBox.tooltip = "If checked, the station will sell goods to traders from other factions than you."%_t

    lister:nextRect(10)

    activelyRequestCheckBox = tab:createCheckBox(Rect(), "Actively request goods"%_t, "onActivelyRequestChecked")
    lister:placeElementTop(activelyRequestCheckBox)
    activelyRequestCheckBox:setCheckedNoCallback(true)
    activelyRequestCheckBox.tooltip = "If checked, the station will actively request traders to deliver goods when it's empty.\nIf unchecked, it may stay empty until a trader visits randomly."%_t

    activelySellCheckBox = tab:createCheckBox(Rect(), "Actively sell goods"%_t, "onActivelySellChecked")
    lister:placeElementTop(activelySellCheckBox)
    activelySellCheckBox:setCheckedNoCallback(true)
    activelySellCheckBox.tooltip = "If checked, the station will request traders that will buy its goods when it's full.\nIf unchecked, its goods may sit around until a trader visits randomly."%_t

    lister:nextRect(10)

    -- transport capacity UI

    local transportRow = lister:nextRect(32)
    local tsplit = UIVerticalSplitter(transportRow, 8, 0, 0.32)
    tsplit:setLeftQuadratic()

    local tooltip = "Shuttles transport a certain amount of volume (but always at least 1 good) per every few seconds to other stations."%_t

    transportIcon = tab:createPicture(tsplit.left, "data/textures/icons/transport-shuttles.png")
    transportIcon.isIcon = true
    transportIcon.tooltip = tooltip

    transportCapacityLabel = tab:createLabel(tsplit.right, "", 14)
    transportCapacityLabel:setLeftAligned()
    transportCapacityLabel.tooltip = tooltip

    lister:nextRect(10) -- отступ перед кнопками апгрейда

    -- delivery UI
    local routesMax = Factory.getMaxRoutes()
    local lister = UIVerticalLister(vsplit:partition(1), 8, 0)

    local label = tab:createLabel(Rect(), "Deliver goods to stations:"%_t, 12)
    lister:placeElementTop(label)
    label.centered = true

    for i = 1, ROUTES_MAX_COUNT do
        local errLabel = tab:createLabel(Rect(), "", 10)
        errLabel.centered = true
        lister:placeElementTop(errLabel)
        table.insert(deliveredStationsErrorLabels, errLabel)

        local combo = tab:createValueComboBox(Rect(), "sendConfig")
        lister:placeElementTop(combo)
        table.insert(deliveredStationsCombos, combo)
        if i > routesMax then
            combo.visible = false
            errLabel.visible = false
        end
    end

    lister:nextRect(30)

    local lister = UIVerticalLister(vsplit:partition(2), 8, 0)
    local label = tab:createLabel(Rect(), "Fetch goods from stations:"%_t, 12)
    lister:placeElementTop(label)
    label.centered = true

    for i = 1, ROUTES_MAX_COUNT do
        local errLabel = tab:createLabel(Rect(), "", 10)
        errLabel.centered = true
        lister:placeElementTop(errLabel)
        table.insert(deliveringStationsErrorLabels, errLabel)

        local combo = tab:createValueComboBox(Rect(), "sendConfig")
        lister:placeElementTop(combo)
        table.insert(deliveringStationsCombos, combo)
        if i > routesMax then
            combo.visible = false
            errLabel.visible = false
        end
    end

    -- upgrade UI
    local vsplit = UIVerticalMultiSplitter(hsplit.bottom, 10, 0, 2)

    local upgradeRect = vsplit:partition(0)
    upgradeRect.lower = upgradeRect.lower - vec2(0, 45)
    local lister = UIVerticalLister(upgradeRect, 10, 0)

    local row = lister:nextRect(32)
    local rowSplit = UIVerticalSplitter(row, 10, 0, 0.5)
    rowSplit:setLeftQuadratic()

    upgradeRoutesButton = tab:createButton(rowSplit.left, "", "onUpgradeRoutesButtonPressed")
    upgradeRoutesButton.icon = "data/textures/icons/bars.png"

    upgradeRoutesPriceLabel = tab:createLabel(rowSplit.right, "", 14)
    upgradeRoutesPriceLabel:setRightAligned()

    row = lister:nextRect(32)
    rowSplit = UIVerticalSplitter(row, 10, 0, 0.5)
    rowSplit:setLeftQuadratic()

    upgradeProductionButton = tab:createButton(rowSplit.left, "", "onUpgradeProductionButtonPressed")
    upgradeProductionButton.icon = "data/textures/icons/upgrade-production.png"

    upgradeProductionPriceLabel = tab:createLabel(rowSplit.right, "", 14)
    upgradeProductionPriceLabel:setRightAligned()

    row = lister:nextRect(32)
    rowSplit = UIVerticalSplitter(row, 10, 0, 0.5)
    rowSplit:setLeftQuadratic()

    upgradeShuttlesButton = tab:createButton(rowSplit.left, "", "onUpgradeShuttlesButtonPressed")
    upgradeShuttlesButton.icon = "data/textures/icons/upgrade-shuttles.png"

    upgradeShuttlesPriceLabel = tab:createLabel(rowSplit.right, "", 14)
    upgradeShuttlesPriceLabel:setRightAligned()
end

Factory.setConfig = function(config)
    if onClient() then
        -- apply config to UI elements
        basePriceSlider:setValueNoCallback(round((config.priceFactor - 1.0) * 100.0))
        basePriceLabel.tooltip = "This station will buy and sell its goods for ${percentage}% of the normal price."%_t % { percentage = round(config.priceFactor * 100.0) }

        allowBuyCheckBox:setCheckedNoCallback(config.buyFromOthers)
        allowSellCheckBox:setCheckedNoCallback(config.sellToOthers)
        activelyRequestCheckBox:setCheckedNoCallback(config.activelyRequest)
        activelySellCheckBox:setCheckedNoCallback(config.activelySell)

        local i = 1
        local max = Factory.getMaxRoutes()

        for id, trades in pairs(config.deliveredStations) do
            deliveredStationsCombos[i]:setSelectedValueNoCallback(id)
            i = i + 1
            if i > max then break end
        end

        for a = i, ROUTES_MAX_COUNT do
            deliveredStationsCombos[a]:setSelectedIndexNoCallback(0)
        end

        local i = 1
        for id, trades in pairs(config.deliveringStations) do
            deliveringStationsCombos[i]:setSelectedValueNoCallback(id)
            i = i + 1

            if i > max then break end
        end

        for a = i, ROUTES_MAX_COUNT do
            deliveringStationsCombos[a]:setSelectedIndexNoCallback(0)
        end

        if TradingAPI.window.visible then
            Factory.refreshConfigUI()
        end
    else
        if not config then return end

        -- apply config to factory settings
        local owner, station, player = checkEntityInteractionPermissions(Entity(), AlliancePrivilege.ManageStations)
        if not owner then return end

        Factory.trader.buyPriceFactor = math.min(1.5, math.max(0.5, config.priceFactor))
        Factory.trader.sellPriceFactor = Factory.trader.buyPriceFactor + 0.2

        Factory.trader.buyFromOthers = config.buyFromOthers
        Factory.trader.sellToOthers = config.sellToOthers
        Factory.trader.activelyRequest = config.buyFromOthers and config.activelyRequest
        Factory.trader.activelySell = config.sellToOthers and config.activelySell
        Factory.trader.deliveredStations = config.deliveredStations or {}
        Factory.trader.deliveringStations = config.deliveringStations or {}

        Factory.sendConfig()
    end
end

function Factory.onUpgradeRoutesButtonPressed()
    if onClient() then
        invokeServerFunction("onUpgradeRoutesButtonPressed")
        return
    end

    local station = Entity()

    local buyer, _, player = getInteractingFaction(callingPlayer, AlliancePrivilege.SpendResources,
        AlliancePrivilege.ManageStations)
    if not buyer then return end

    if Factory.getMaxRoutes() >= ROUTES_MAX_COUNT then
        player:sendChatMessage("", ChatMessageType.Error, "Routes count is already at maximum."%_t)
        return
    end

    local price = Factory.getRouteUpgradeCost()

    local canPay, msg, args = buyer:canPay(price)
    if not canPay then -- if there was an error, print it
        player:sendChatMessage(Entity(), 1, msg, unpack(args))
        return
    end

    buyer:pay(price)

    station:setValue("max_routes", Factory.getMaxRoutes() + 1)

    Factory.sync()
    invokeClientFunction(player, "refreshConfigUI")
end

callable(Factory, "onUpgradeRoutesButtonPressed")

function Factory.getMaxRoutes()
    local station = Entity()
    if not station or not station.playerOwned then return ROUTES_DEFAULT_COUNT end
    return station:getValue("max_routes") or ROUTES_DEFAULT_COUNT
end

function Factory.getRouteUpgradeCost()
    local stage = (Factory.getMaxRoutes() - 3) / 3 + 1
    local price = getFactoryUpgradeCost(production, stage) / 4
    return price
end

Factory.initialize = function(producedGood, productionIndex, size)
    local station = Entity()
    if station and station.playerOwned then
        if not station:getValue("max_routes") then
            station:setValue("max_routes", ROUTES_DEFAULT_COUNT)
        end
    end
    base_initialize(producedGood, productionIndex, size)
end

Factory.refreshConfigUI = function()
    base_refreshConfigUI()
    if not upgradeRoutesButton or not upgradeRoutesPriceLabel then return end
    if Factory.getMaxRoutes() < ROUTES_MAX_COUNT then
        local price = createMonetaryString(Factory.getRouteUpgradeCost())
        upgradeRoutesPriceLabel.caption = "${price} Cr"%_t % { price = price }
        upgradeRoutesPriceLabel.visible = true
        upgradeRoutesButton.tooltip = "An upgrade that allows you to increase the route limit to ${amount}"%_t % { amount = Factory.getMaxRoutes() + 1 }
        upgradeRoutesButton.visible = true
    else
        upgradeRoutesPriceLabel.visible = false
        upgradeRoutesButton.visible = true
        upgradeRoutesButton.active = false
        upgradeRoutesButton.tooltip = nil
    end
    Factory.applyRouteLimit()
end

function Factory.applyRouteLimit()
    local max = Factory.getMaxRoutes()

    for i = 1, ROUTES_MAX_COUNT do
        if deliveredStationsCombos[i] then
            deliveredStationsCombos[i].visible = (i <= max)
        end
        if deliveredStationsErrorLabels[i] then
            deliveredStationsErrorLabels[i].visible = (i <= max)
        end

        if deliveringStationsCombos[i] then
            deliveringStationsCombos[i].visible = (i <= max)
        end
        if deliveringStationsErrorLabels[i] then
            deliveringStationsErrorLabels[i].visible = (i <= max)
        end
    end
end
