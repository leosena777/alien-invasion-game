WIDTH_SCREEN = 320
HEIGHT_SCREEN = 400
MAX_METEORO = 12
END_GAME = false
METEORS_DESTROY = 0
VICTORY_GAME = false
NUMBER_METEROS_FOR_VICTORY = 30

nave = {
    src = "imagens/14bis.png",
    width = 55,
    lenght = 63,
    image = nil,
    x = WIDTH_SCREEN / 2 - 64 / 2,
    y = HEIGHT_SCREEN - 64,
    fires = {}
}

meteoros = {}
function destroyNave()
    nave.src = "imagens/explosao_nave.png"
    nave.image = love.graphics.newImage(nave.src)
    nave.width = 67
    nave.lenght = 77
    destroySound:play()
end

function isCollision(x1, y1, l1, a1, x2, y2, l2, a2)
    return x2 < x1 + l1 and x1 < x2 + l2 and y1 < y2 + a2 and y2 < y1 + a1
end

function changeEnvironmentMusic()
    musicEnvironment:stop()
    gameOverSound:play()
end

function checkNaveCollision()
    for k, meteoro in pairs(meteoros) do
        if isCollision(meteoro.x, meteoro.y, meteoro.width, meteoro.height,
                       nave.x, nave.y, nave.width, nave.lenght) then
            destroyNave()
            END_GAME = true
            changeEnvironmentMusic()
        end
    end
end

function checkShootCollision()
    for i=#nave.fires, 1,-1 do
        for j=#meteoros,1,-1 do
            if isCollision(
                nave.fires[i].x, nave.fires[i].y, nave.fires[i].width, nave.fires[i].height,
                meteoros[j].x, meteoros[j].y, meteoros[j].width, meteoros[j].height
            ) then
                METEORS_DESTROY = METEORS_DESTROY + 1
                table.remove( nave.fires , i )
                table.remove( meteoros , j )
                break
            end
        end
    end 
end

function checkVictory()
    if METEORS_DESTROY >= NUMBER_METEROS_FOR_VICTORY then
        VICTORY_GAME = true
        musicEnvironment:stop()
        winnerSound:play()
    end
end

function collisionCheck()
    checkNaveCollision()
    checkShootCollision()
end

function removeMeteoro()
    for i = #meteoros, 1, -1 do
        if meteoros[i].y > HEIGHT_SCREEN then table.remove(meteoros, i) end
    end
end

function createMeteoro()
    meteoro = {
        x = math.random(WIDTH_SCREEN),
        y = -70,
        width = 50,
        height = 44,
        peso = math.random(3),
        deslocamento = math.random(-1, 1)
    }
    table.insert(meteoros, meteoro)
end

function moveMeteoro()
    for k, meteoro in pairs(meteoros) do
        meteoro.y = meteoro.y + meteoro.peso
        meteoro.x = meteoro.x + meteoro.deslocamento
    end
end

function moveNave()
    if love.keyboard.isDown('w') then nave.y = nave.y - 1; end
    if love.keyboard.isDown('s') then nave.y = nave.y + 1; end
    if love.keyboard.isDown('a') then nave.x = nave.x - 1; end
    if love.keyboard.isDown('d') then nave.x = nave.x + 1; end
end

function firing()
    shotSound:play()
    local fire = {x = nave.x + nave.width / 2, y = nave.y, width = 16, height = 16}

    table.insert(nave.fires, fire)

end

function moveFire()
    for i = #nave.fires, 1, -1 do
        if nave.fires[i].y > 0 then
            nave.fires[i].y = nave.fires[i].y - 2
        else
            table.remove(nave.fires, i)
        end
    end
end

function love.load()
    love.window.setMode(WIDTH_SCREEN, HEIGHT_SCREEN, {resizable = false})
    love.window.setTitle('14 bis vs Meteoros')
    math.randomseed(os.time())

    -- images
    background = love.graphics.newImage('imagens/background.png')
    nave.image = love.graphics.newImage(nave.src)
    meteoro_img = love.graphics.newImage('imagens/meteoro.png')
    fireImage = love.graphics.newImage('imagens/tiro.png')
    gameOverImg = love.graphics.newImage('imagens/gameover.png')
    victoryGameImg = love.graphics.newImage('imagens/vencedor.png')

    -- audios
    musicEnvironment = love.audio.newSource('audios/ambiente.wav', "static")
    destroySound = love.audio.newSource('audios/destruicao.wav', "static")
    gameOverSound = love.audio.newSource('audios/game_over.wav', "static")
    shotSound = love.audio.newSource('audios/disparo.wav', 'static')
    winnerSound = love.audio.newSource('audios/winner.wav', 'static')

    musicEnvironment:setLooping(true)
    musicEnvironment:play()

end
 
function love.update(dt)
    if not END_GAME and not VICTORY_GAME then
        if love.keyboard.isDown('w', 's', 'a', 'd') then moveNave() end

        if #meteoros < MAX_METEORO then createMeteoro() end
        removeMeteoro()
        moveMeteoro()
        moveFire()
        collisionCheck()
        checkVictory()
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'space' then
        firing()
    end
end

function love.draw()
    love.graphics.draw(background, 0, 0)
    love.graphics.draw(nave.image, nave.x, nave.y)

    for k, meteoro in pairs(meteoros) do
        love.graphics.draw(meteoro_img, meteoro.x, meteoro.y)
    end

    for k, fire in pairs(nave.fires) do
        love.graphics.draw(fireImage, fire.x, fire.y)
    end

    if END_GAME then
        love.graphics.draw(gameOverImg, WIDTH_SCREEN /2 - 102 , HEIGHT_SCREEN/2 -70 )
    end 

    if VICTORY_GAME then 
        love.graphics.draw(victoryGameImg, WIDTH_SCREEN /2 - victoryGameImg:getWidth()/2 , HEIGHT_SCREEN/2 - victoryGameImg:getHeight()/2 )
    end

    love.graphics.print('Meteoros restantes: ' .. NUMBER_METEROS_FOR_VICTORY - METEORS_DESTROY, 5,5)
end
