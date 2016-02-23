global lastHit translationMatrix maximumAllowedLapTimeMinutes minimumAllowedLapTimeSeconds racersPreferences laps n_laps fastestLaps;

maximumAllowedLapTimeMinutes = 5; %if you take longer than 5 minutes it assumes that it is not a lap, but maybe the beginning of a new race
minimumAllowedLapTimeSeconds = 5; %it should take at least this amount of time to do a lap... this is to avoid multiple shots.

racers = 6;
%Transponder number -> to racer: eg. Transponder number 8329133 belongs to Luca
% and he is number 1. Buy got noe I am only using the last 2 digits...
% this part can do with a lot of improvements
translationMatrix = zeros(99,1);
translationMatrix(60) = 1; %Luca
translationMatrix(97) = 2; %Ryan;
translationMatrix(33) = 3; %Test 3
translationMatrix(90) = 4; %Test 0
translationMatrix(71) = 4; %Test 1

racersPreferences = {'Luca', '9060860', 'r'; ...
    'Ryan', '6639697', 'b'; ...
    'Test3', '8329133', 'g'; ...
    'Test0', '8865990', 'k'; ...
    'Test1', '8191271', 'c'; ...
    };
laps = zeros(racers, 200);
n_laps = zeros(racers);

%s = serial('COM4');
%fopen(s);

%clear out the buffer
while s.BytesAvailable > 0;
    fscanf(s)
end
 
DataToSend = [char(001),char(037),char(013),char(010)];
%switch mode on the timing system
fprintf(s,'%s', DataToSend);
idn = fscanf(s);

fastestLaps = zeros(racers,1);
lastHit = zeros(racers,1);
%messages = [];
counter = 1;

s.BytesAvailableFcnMode = 'terminator';
s.BytesAvailableFCn = @dataAvailable;

%closing
% fclose(s);
% delete(s);
% clear s;
