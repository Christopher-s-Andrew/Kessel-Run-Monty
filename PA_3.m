%created by chrisopher andrew on 5/7/21 for num method class
%uses monti carlo random numbers to solve problem
%proble is given a cluster1.mat

%worse completed settings
badVBase = 0;
badVDIR = 0;
badPos = 0;
badTime = 0;

%good completion settings
goodVBase = 0;
goodVDIR = 0;
goodPos = 0;
goodTime = 1000000000000;

%clear the current figure, uses the default
clf;
fprintf("sim takes around 1 minuite to run on my machine,\n not sure how long it will take on yours\n");
%sim starts here
load cluster1.mat; %import grav wells, hopfully same file name
for runCycles = 1:40000 %adjust this to change trial amount, more = better result
    
    %generate start position/velocity/launch angle and then run sim
    startX = unifrnd(-5,5);
    vDir = normrnd(0,pi/4);
    vBase = unifrnd(2,5);
    
    %run sim
    t = sim(startX,vDir,vBase,0,hM,hX,hY);
    
    %update bad time if needed from sim results
    if t ~= 0 && badTime < t
        badVBase = vBase;
        badVDIR = vDir;
        badPos = startX;
        badTime = t;
    end
    
    %update good time if needed from sim results
    if t ~= 0 && goodTime > t
        goodVBase = vBase;
        goodVDIR = vDir;
        goodPos = startX;
        goodTime = t;
    end
end

%rerun sim only graph data this time
clf; %clear figure in case of weirdness
a = sim(badPos,badVDIR,badVBase,1,hM,hX,hY);
a = sim(goodPos,goodVDIR,goodVBase,1,hM,hX,hY);

fprintf("Best time = %f [s]\n", goodTime*0.02);
fprintf("Worest time = %f [s]\n", badTime*0.02);



%function that runs the sim, only returns a non 0 final time if the sim
%completes
function finalTime = sim(startPos,startAngle,StartV, plotMe, hM, hX, hY)
    %setup varribles
    
    timeStep = 0.02; %takes around 1 min to run all sims on my machine
    %initial craft varribles
    craftY = -10;
    G = 1;
    craftAX = 0;
    craftAY = 0;
    craftVX = 0;
    craftVY = 0;
    craftMass = 1; %assumed don't think it was specified in PA pdf
    failState = 0;
    victoryState = 0;
    
    %start pos calc
    craftX = startPos;
    craftVX = sin(startAngle)*StartV;
    craftVY = cos(startAngle)*StartV;
    
    %plotting
    if plotMe == 1
        title("PA 3 Kessel Run slowest and fastest paths discovered");
       % xlabel("X");
       % ylabel("Y");
        scatter(hX,hY,'O', 'black'); %plot holes
    end
    
    %update step here 
    t = 0; %sim time
    for t = 0:5000 %max sim time, probly wont reach
        %plotting
        if plotMe == 1
            %plotting with automagical color
            hold on
            color = (abs(craftY)+6)/16;
            if craftY < 0
                c = [0 0 color];
                
            elseif craftY > 0
                c = [color 0 0];
            end
            scatter(craftX,craftY,25, c, 'filled');
        end
        craftAX = 0;
        craftAY = 0;
        %calculate new acceleration
        for i = 1:length(hM)
            craftAX = craftAX +  hM(i) *(hX(i) - craftX)/(sqrt((hX(i) - craftX)^2 + (hY(i) - craftY)^2))^3;
            craftAY = craftAY +  hM(i) *(hY(i) - craftY)/(sqrt((hX(i) - craftX)^2 + (hY(i) - craftY)^2))^3;
        end

        %velocity step
        craftVX = craftVX + craftAX*timeStep;
        craftVY = craftVY + craftAY*timeStep;

        %position step
        craftX = craftX + craftVX*timeStep;
        craftY = craftY + craftVY*timeStep;

        %failChecks
        if  sqrt(craftAX^2 + craftAY^2) >= 4 || craftY < -10 || craftX > 10 || craftX < -10
            failState = 1;
            break;
        end

        %victory check
        if craftY > 10
            victoryState = 1;
            break;
        end
    end
    
    %decide if we should output a time base on victory state and fail state
    %check
    if victoryState > 0 && failState < 1
        finalTime = t;
    else
        finalTime = 0;
    end
end
   