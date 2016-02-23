function [time_in_ms] = dataAvailable( obj, event )
%DATAAVAILABLE This function gets called when data becomes available
%   Detailed explanation goes here
    global lastHit translationMatrix maximumAllowedLapTimeMinutes minimumAllowedLapTimeSeconds racersPreferences laps n_laps fastestLaps;
    message = fscanf(obj);
    maximumAllowedLapTimeMinutes
    if length(message) > 11
        carNumber = message(8:14);
        %since we are only using 2 digits, only use the last 2.
        carNum = str2num(carNumber(end-1:end));
        racer = translationMatrix(carNum);
%         hours = str2num(message(4:5));
%         minutes = str2num(message(6:7));
        time = message(15:end);
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
    end
    
end

