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

while true
    idn = fscanf(s);
    %A message shuld look like: @	210	8329133	51.198
    if length(idn) > 11
        display(idn);
        %messages(counter) = (idn(7:end));
        carNumber = idn(8:14);
        %since we are only using 2 digits, only use the last 2.
        carNum = str2num(carNumber(end-1:end));
        racer = translationMatrix(carNum);
%         hours = str2num(idn(4:5));
%         minutes = str2num(idn(6:7));
        time = idn(15:end);
        seconds = str2double(time);
        time_in_ms = seconds * 1000 ;
        if lastHit(racer) > 0
            lapTime = time_in_ms - lastHit(racer);
            if (lapTime < (60*maximumAllowedLapTimeMinutes*1000)) && (lapTime > (minimumAllowedLapTimeSeconds * 1000))
                n_laps(racer) =  n_laps(racer) + 1;
                %calculate lap time
                %convert all to ms:
                lapTime = time_in_ms - lastHit(racer);
                laps(racer, n_laps(racer)) = lapTime*0.001;
                if lapTime < fastestLaps(racer) ||  fastestLaps(racer) == 0
                    fastestLaps(racer) = lapTime;
                    display(sprintf('%s new fast time %.3f on lap %d', racersPreferences{racer,2}, lapTime*0.001, n_laps(racer)));
                end
                figure(1);
                close;
                figure(1);
                hold on;
                completedLaps = find(n_laps > 0);
                
                for n = 1:length(completedLaps)
                    plot(laps(completedLaps(n), 1:n_laps(completedLaps(n))), racersPreferences{completedLaps(n),3});
                    legendEntries{n} = [racersPreferences{completedLaps(n),1}, ', fastest: ', num2str(fastestLaps(completedLaps(n)) * 0.001)];
                end
                legend(legendEntries);
                drawnow;
            else 
                display(sprintf('%s (car number = %s) invalid laptime %.3f.', racersPreferences{racer,1}, carNumber,  lapTime*0.001));
            end
        end
        lastHit(racer) = time_in_ms;
        
        %        if fastestLaps(carNum) <
        %display(sprinf('Car number = %s', carNumber));
    end
end
fclose(s);
