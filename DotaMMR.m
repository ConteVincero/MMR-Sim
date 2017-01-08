clf

Games=20000;
%Playing less than 2000 games may cause errors due to too many players

PlayerSkill=zeros(Games,1);
PlayerMMR=zeros(Games,1);
PlayerSkillGrowth=zeros(Games,1);
PlayerSkillMax = zeros(Games,1);
PlayerGames = zeros(Games,1);
MMRs = zeros(40,Games);
MMRscale = zeros(40,1);
Skill = 0;
Luck = 0;
AverageMMR = zeros(Games,1);
TotalMMR = 0;
Radiant = 0;
Dire = 0;
Median = zeros(Games,1);
Resolution = 250;   %The resolution of the surface plot
PlayerSurf=zeros(30,30);
%This number influences the chance of a win being determined by
%skill or luck
SkillFactor = 1000;

%create player base
for Count = 1:1000
    PlayerSkill(Count) = int64(normrnd(2000,500));
    PlayerMMR(Count) = max(PlayerSkill(Count)+(round(normrnd(0,300))),1);
    PlayerSkillGrowth(Count) = int64(rand*3);
    PlayerSkillMax(Count) = max(round(normrnd(5000,1000)),PlayerSkill(Count)+1000);
end
TotalPlayers = 1000;

%Start the simulation
for Round = 1:Games
    
    %Add new player
    Limit = randi(5);
    for Count = 1:Limit
    TotalPlayers = TotalPlayers+1;
    PlayerSkill(TotalPlayers) = int64(normrnd(2000,500));
    PlayerMMR(TotalPlayers) = PlayerSkill(TotalPlayers)+randi([-500,500]);
    PlayerSkillGrowth(TotalPlayers) = int64(rand*5);
    PlayerSkillMax(TotalPlayers) = int64(normrnd(4000,1000));
    %fprintf('%g \n', PlayerMMR(TotalPlayers))
    end
    
    %Sort arrays
    RemoveCount=0;
    for Count =2:TotalPlayers
        Number = Count -1;
        if PlayerMMR(Count)> PlayerMMR(Number)            
            PlayerMMRTemp = PlayerMMR(Count);
            PlayerSkillTemp = PlayerSkill(Count);
            PlayerSkillGrowthTemp = PlayerSkillGrowth(Count);
            PlayerSkillMaxTemp = PlayerSkillMax(Count);
            PlayerGamesTemp = PlayerGames(Count);
            while PlayerMMRTemp> PlayerMMR(Number) && Number>=1                
                PlayerMMR(Number+1) = PlayerMMR(Number);
                PlayerSkill(Number+1) = PlayerSkill(Number);
                PlayerSkillGrowth(Number+1) = PlayerSkillGrowth(Number);
                PlayerSkillMax(Number+1)=PlayerSkillMax(Number);
                PlayerGames(Number+1) = PlayerGames(Number);
                Number = Number -1;
                if Number == 0
                    break
                end
            end        
            PlayerMMR(Number+1) = PlayerMMRTemp;
            PlayerSkill(Number+1) = PlayerSkillTemp;
            PlayerSkillGrowth(Number+1) = PlayerSkillGrowthTemp;
            PlayerSkillMax(Number+1)=PlayerSkillMaxTemp;
            PlayerGames(Number+1)=PlayerGamesTemp;
        elseif PlayerMMR(Count)==0;
            RemoveCount=RemoveCount+1;
        end
    end
    TotalPlayers=TotalPlayers-RemoveCount;
    Median(Round)=PlayerMMR(int64(TotalPlayers/2));
    %play games
    for Count = 1:10:TotalPlayers-10
        RadiantTeam = [1,3,4,7,8];
        DireTeam=[0,2,5,6,9];
        
        %Calculate skill difference
        %Calculate MMRs
        RadiantMMR = 0;
        DireMMR = 0;
        RadiantSkill=0;
        DireSkill=0;
        for number = 1:5
            RadiantMMR = RadiantMMR + PlayerMMR(Count+RadiantTeam(number));
            DireMMR = DireMMR + PlayerMMR(Count+DireTeam(number));
            RadiantSkill=RadiantSkill+PlayerSkill(Count+RadiantTeam(number));
            DireSkill=DireSkill+PlayerSkill(Count+DireTeam(number));
        end
        RadiantMMR = RadiantMMR/5;
        DireMMR = DireMMR/5;
        RadiantSkill=RadiantSkill/5;
        DireSkill=DireSkill/5;
        
        Random = int64(rand*SkillFactor)-(SkillFactor/2);
        
        if DireSkill+Random >RadiantSkill
            MMRGain = int64((RadiantMMR-DireMMR))/75+25;
            for number = 1:5
                if PlayerMMR(Count+RadiantTeam(number)) >MMRGain 
                    PlayerMMR(Count+RadiantTeam(number))=PlayerMMR(Count+RadiantTeam(number))-MMRGain;
                else
                    PlayerMMR(Count+RadiantTeam(number)) = 1;
                end
                %This is for people abandoning but still winning
                %if rand(100)<0.1
                    %if PlayerMMR(Count+DireTeam(number)) >MMRGain 
                        %PlayerMMR(Count+DireTeam(number))=PlayerMMR(Count+DireTeam(number))-MMRGain;
                    %else
                        %PlayerMMR(Count+DireTeam(number)) = 1;
                    %end
                %else
                    PlayerMMR(Count+DireTeam(number))=PlayerMMR(Count+DireTeam(number))+MMRGain;
                %end
            end
            if RadiantSkill<DireSkill
                Skill = Skill +1;
            else
                Luck = Luck +1;
            end
            Dire = Dire + 1;
        else
            MMRGain = int64(DireMMR-RadiantMMR)/75+25;
            for number = 1:5
                if PlayerMMR(Count+DireTeam(number)) >MMRGain 
                    PlayerMMR(Count+DireTeam(number))=PlayerMMR(Count+DireTeam(number))-MMRGain;
                else
                    PlayerMMR(Count+DireTeam(number)) = 1;
                end
                %This is for people abandoning but still winning
                %if rand(100)<0.1
                    %if PlayerMMR(Count+RadiantTeam(number)) >MMRGain 
                        %PlayerMMR(Count+RadiantTeam(number))=PlayerMMR(Count+RadiantTeam(number))-MMRGain;
                    %else
                        %PlayerMMR(Count+RadiantTeam(number)) = 1;
                    %end
                %else
                    PlayerMMR(Count+RadiantTeam(number))=PlayerMMR(Count+RadiantTeam(number))+MMRGain;
                %end
                
            end
            if RadiantSkill>DireSkill
                Skill = Skill +1;
            else
                Luck = Luck +1;
            end
            Radiant = Radiant + 1;
        end
    end
   
    TotalMMR=0;
    
    %Do sorting stuff and remove players
    
    for Count = 1:TotalPlayers
        PlayerGames(Count)=PlayerGames(Count)+1;
        %IncreaseSkill
        PlayerSkill(Count)=PlayerSkill(Count)+min(PlayerSkillGrowth(Count),(PlayerSkillMax(Count)-PlayerSkill(Count))/50);
        %Graph MMRs
        Counter = 0;
        TotalMMR = TotalMMR+PlayerMMR(Count);
        for Number = 250:250:9000
            Counter = Counter + 1;
            MMRscale(Counter)=Number;
            if PlayerMMR(Count)<Number
                MMRs(Counter,Round)=MMRs(Counter,Round)+1;
                break
            end
        end
        %Remove Players
        if rand<max((normpdf(PlayerGames(Count),0,2000)*10),0.0004)
            PlayerMMR(Count)=0;
            PlayerSkill(Count)=0;
            PlayerSkillGrowth(Count) = 0;
            PlayerSkillMax(Count) = 0;
            PlayerGames(Count)=0;
        end
    end
    AverageMMR(Round)=TotalMMR/TotalPlayers;
    
    fprintf('%g %% \n',Round*100/Games)
    
%     fprintf('%g \n',TotalPlayers)

% This is used for printing pictures of what's going on to file
%     f = figure('Visible','off');
%     scatter(PlayerMMR,PlayerSkill,'.')
%     grid on
%     grid minor
%     hold on
%     plot(X,X,'r')
%     xlabel('MMR')
%     ylabel('Skill')
%     title('Plot of Skill against MMR')
%     hold off
%     print(f,strcat('C:\Users\Dominic\Pictures\Matlab\',num2str(Round)), '-dpng');
%   
  
end

%Calculate games played distribution
Counter = 0;
for Number = 100:100:20000
    Counter = Counter + 1;
    GameScale(Counter)=Number;
end
GamesCount = zeros(Counter,1);
for Count = 1:TotalPlayers
    Counter = 0;
    for Number = 100:100:20000
        Counter = Counter + 1;
        if PlayerGames(Count)<=Number
            GamesCount(Counter)=GamesCount(Counter)+1;
            break
        end
    end
end

% Now it's done, plot the graphs!
grid on
grid minor
%plot(MMRscale,MMRs)
fprintf('%g %% games won by skill \n',(Skill/(Skill+Luck))*100)
fprintf('Dire won %g %% of games \n', Dire/(Radiant+Dire)*100)
hold on
plot(Median,'r')
plot(AverageMMR,'b')
xlabel('Games')
ylabel('MMR')
title('Average and Median MMR after each round of games')
legend('Median MMR','Average MMR','Location','southeast')
hold off
pause

% f = figure('Visible','off');
scatter(PlayerMMR,PlayerSkill,'.')
grid on
grid minor
hold on
X=1:9000;
plot(X,X,'r')
xlabel('MMR')
ylabel('Skill')
title('Plot of Skill against MMR')
hold off
% print(f,strcat('C:\Users\Dominic\Pictures\Matlab',num2str(Round)), '-dpng');
pause

plot(MMRscale,MMRs(:,10))
grid on
hold on
plot(MMRscale,MMRs(:,Games/4),'r')
plot(MMRscale,MMRs(:,Games/2),'g')
plot(MMRscale,MMRs(:,Games*.75),'y')
plot(MMRscale,MMRs(:,Games),'k')
legend('10 rounds',strcat(num2str(Games/4),' rounds'),strcat(num2str(Games/2),' rounds'),strcat(num2str(Games*0.75),' rounds'),strcat(num2str(Games),' rounds'))
xlabel('MMR')
ylabel('Number of players')
title('MMR Distribution changes over time')
hold off
pause

scatter(PlayerGames,PlayerMMR,'.')
grid on
grid minor
xlabel('Games Played')
ylabel('MMR')
title('Plot of games played against MMR')
pause

plot(GameScale,GamesCount)
grid on
xlabel('Games')
ylabel('Number of players')
title('Games Played distribution')
pause

for i = 1:30
    x(i)=Resolution*i;
    y(i)=Resolution*i;
end

for i=1:TotalPlayers
    %GamesPlayed(int64(PlayerMMR(i)/resolution)+1,int64(PlayerSkill(i)/resolution)+1)=GamesPlayed(int64(PlayerMMR(i)/resolution)+1,int64(PlayerSkill(i)/resolution)+1)+PlayerGames(i);
    PlayerSurf(int64(PlayerMMR(i)/Resolution)+1,int64(PlayerSkill(i)/Resolution)+1)=PlayerSurf(int64(PlayerMMR(i)/Resolution)+1,int64(PlayerSkill(i)/Resolution)+1)+1;
end
%for i=1:2000
    %for j=1:2000
        %SurfaceChart(i,j)=GamesPlayed(i,j)/PlayerCount(i,j);
    %end
%end
H=surf(x,y,PlayerSurf);
set(H,'LineStyle','none')      
axis([0 7000 0 7000 0 inf])