% Clear the workspace
close all;
clearvars;
sca;
Screen('Preference', 'SkipSyncTests', 1);
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

screens = Screen('Screens');% Get the screen numbers
screenNumber = max(screens);% Draw to the external screen if avaliable
white = WhiteIndex(screenNumber);% Define black and white
black = BlackIndex(screenNumber);
grey = white / 2;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber,...
    grey, [], 32, 2, [], [], kPsychNeed32BPCFloat);
ifi = Screen('GetFlipInterval', window);% Query the frame duration

% Screen resolution in Y
screenYpix = windowRect(4);
screenXpix = windowRect(3);

rcycles = 12;% Number of white/black circle pairs
tcycles = 24;% Number of white/black angular segment pairs (integer)
% Now we make our checkerboard pattern
xylim =2*pi * rcycles;
[x, y] = meshgrid(-xylim: 2 * xylim / (screenYpix - 1): xylim,...
    -xylim: 2 * xylim / (screenYpix - 1): xylim);
at = atan2(y, x);
% Hasta aqui se tiene diseñado donde sera 1 y 0, es decir blanco o negro,
% pero falta definir que partes se mostraran y cuales permaneceran grises.
% Falto elejir que parte se mostrara, es decir que cuadrantes elegir.
checks = ((1 + sign(sin(at * tcycles) + eps)...
    .* sign(sin(sqrt(x.^2 + y.^2)))) / 2) * (white - black) + black;
circle   = x.^2 + y.^2 <= (xylim)^2;%circulo principal gris exterior
circle_2 = x.^2 + y.^2 <= (12*(xylim/12))^2;
circle_3 = x.^2 + y.^2 <= (10*(xylim/12))^2;
checks = circle .* checks + grey * ~circle_2 + grey * circle_3; 

% Now we make this into a PTB texture
radialCheckerboardTexture(1)  = Screen('MakeTexture', window, checks);
radialCheckerboardTexture(2)  = Screen('MakeTexture', window, 1 - checks);

% Start angle at which we would like our mask to begin (degrees)
startAngle = 0;
% Length of the arc (degrees)
arcAngle = 330;
% The rect in which we will define our arc
arcRect = CenterRectOnPointd([0 0 screenYpix screenYpix],...
    screenXpix / 2, screenYpix / 2);% Rate at which our mask will rotate

% Time we want to wait before reversing the contrast of the checkerboard
checkFlipTimeSecs = 1/8;%Indicated the frequency of the stimuls
checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
frameCounter = 0;
% Time we want to wait before change the angle position
checkFlipTimeSecs_pos = 2;%Indicated the frequency of the stimuls
checkFlipTimeFrames_pos = round(checkFlipTimeSecs_pos / ifi);
frameCounter_pos = 0;


% Time to wait in frames for a flip
waitframes = 1;
% Texture cue that determines which texture we will show
textureCue = [1 2];

% Sync us to the vertical retrace
vbl = Screen('Flip', window);
i_est=0;
posicion_circulo=0;
%Creamos al  punto rojo en el centro
dotColor = [1 0 0];
dotXpos = screenXpix/2;
dotYpos = screenYpix/2;
dotSizePix = 10;

while ~KbCheck

    % Increment the counter
    frameCounter = frameCounter + 1;
    frameCounter_pos = frameCounter_pos + 1;

    % Draw our texture to the screen
    Screen('DrawTexture', window, radialCheckerboardTexture(textureCue(1)));
    Screen('DrawDots', window, [dotXpos dotYpos], dotSizePix, dotColor, [], 2);
    % Draw our mask
    Screen('FillArc', window, grey, arcRect, startAngle, arcAngle);
     Screen('DrawDots', window, [dotXpos dotYpos], dotSizePix, dotColor, [], 2);
    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    % Modify the angule postion
    if frameCounter_pos == checkFlipTimeFrames_pos
        frameCounter_pos = 0;
 
        startAngle =  30*randi([1 12],1,1);
        cir = randi([1 12],1,1)
        
        if rem(cir,2)==0
            checks = ((1 + sign(sin(at * tcycles) + eps)...
            .* sign(sin(sqrt(x.^2 + y.^2)))) / 2) * (white - black) + black;
            circle_2 = x.^2 + y.^2 <= (cir*(xylim/12))^2;
            circle_3 = x.^2 + y.^2 <= ((cir-2)*(xylim/12))^2;
            checks = circle .* checks + grey * ~circle_2 + grey * circle_3; 
            % Now we make this into a PTB texture
            radialCheckerboardTexture(1)  = Screen('MakeTexture', window, checks);
            radialCheckerboardTexture(2)  = Screen('MakeTexture', window, 1 - checks);
        else 
            cir=cir+1;
            checks = ((1 + sign(sin(at * tcycles) + eps)...
            .* sign(sin(sqrt(x.^2 + y.^2)))) / 2) * (white - black) + black;
            circle_2 = x.^2 + y.^2 <= (cir*(xylim/12))^2;
            circle_3 = x.^2 + y.^2 <= ((cir-2)*(xylim/12))^2;
            checks = circle .* checks + grey * ~circle_2 + grey * circle_3; 
            % Now we make this into a PTB texture
            radialCheckerboardTexture(1)  = Screen('MakeTexture', window, checks);
            radialCheckerboardTexture(2)  = Screen('MakeTexture', window, 1 - checks);
        end
        est_ubicacion(i_est+1,1)=calculo_ubicacion(cir,startAngle)%Indica la posicion en la que apareci el estimulo
%         vect_ubicacion(posicion_circulo)=est_ubicacion;
        i_est=i_est+1;
    end
    % Reverse the texture cue to show the other polarity if the time is up
    if frameCounter == checkFlipTimeFrames
        textureCue = fliplr(textureCue);%Change the order of the vector to show
        frameCounter = 0;
    end
end

% Clear up and leave the building
sca;
close all;