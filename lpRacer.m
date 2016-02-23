maximumAllowedLapTimeMinutes = 5; %if you take longer than 5 minutes it assumes that it is not a lap, but maybe the beginning of a new race
minimumAllowedLapTimeSeconds = 5; %it should take at least this amount of time to do a lap... this is to avoid multiple shots.

racers = 6;
%Transponder number -> to racer: eg. Transponder number 10 belongs to Luca
% and he is number 1.
translationMatrix = zeros(99,1);
translationMatrix(10) = 1; %Luca
translationMatrix(7) = 2; %Ryan;
translationMatrix(3) = 3; %Test 3

racersPreferences = {'Luca', '10', 'r'; ...
    'Ryan', '7', 'b'; ...
    'Test3', '3', 'g'; ...;
    };
laps = zeros(racers, 200);
n_laps = zeros(racers);

%s = serial('COM4');
%fopen(s);

fastestLaps = zeros(racers,1);
lastHit = zeros(racers,1);
messages = [];
counter = 1;



while true
    idn = fscanf(s);
    if length(idn) > 11
        messages(counter) = str2num(idn(2:end));
        carNumber = idn(2:3);
        carNum = str2num(carNumber);
        racer = translationMatrix(carNum);
        hours = str2num(idn(4:5));
        minutes = str2num(idn(6:7));
        seconds = str2num(idn(8:9));
        ms = str2num(idn(10:12));
        time_in_ms = ((((hours*60) + minutes) * 60) + seconds) * 1000 + ms;
        %display(sprintf('%s (car number = %s), hours: %d, minutes %d, seconds %d, ms: %d', racersPreferences{racer,1}, carNumber, hours, minutes, seconds, ms));
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
