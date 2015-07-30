function [Cum_Rwd_Sigma, Step_Size_Results, meanReward,rwdBlob1, rwdBlob2, rwdBlob3, totalReward] = run()

mdp = Toy (0,0.99,20,9)
state1 = mdp.getStartState;
state2 = mdp.transit(state1,1);
state3 = mdp.transit(state2,1);
state4 = mdp.transit(state3,1);
state5 = mdp.transit(state1,-1);
state6 = mdp.transit(state5,-1);
state7 = mdp.transit(state6,-1);
rwdBlob1 = mdp.reward(state1,1) + mdp.reward(state2,1) + mdp.reward(state2,1)*18
rwdBlob2 = mdp.reward(state1,1) + mdp.reward(state2,1) + mdp.reward(state3,1) + mdp.reward(state3,1)*17
rwdBlob3 = mdp.reward(state1,1) + mdp.reward(state5,1) + mdp.reward(state6,1) + mdp.reward(state7,1) + mdp.reward(state7,1)*16
totalReward = mdp.reward(state1,1) + mdp.reward(state2,1) + mdp.reward(state3,1) + mdp.reward(state4,1) + mdp.reward(state4,1)*16

%%set up an MDP 
noise=0;
gamma=0.99;
H=20;   % H = 50
Actions = 9;

%setting up the MDP here
mdp = Toy(noise, gamma, H, Actions);

%mdp_type_kernels = AllKernels (GridWorldKernel(mdp));
agent_kernel_type = GridWorldKernel(mdp); %make a same version of PendulumKernel - to be used with Pend MDPs

%parameters for the agent
centres = 25;

experiments = 10;
iterations = 200;
cumulativeReward = zeros(experiments,iterations+1);

sigma = 0.4;

Step_Size_Results ={};
Cum_Rwd_Sigma={length(sigma)};

c_epsilon = [128, 256, 512, 1000 ];

%c_epsilon = 512;

momentum = 0.999;

for s = 1:length(sigma)
    for a = 1:length(momentum)
     for b = 1:length(c_epsilon)
        for i = 1:experiments
                      
    fprintf(['\n**** EXPERIMENT NUMBER p = ', num2str(i), ' ******\n']); 

    agentKernel = agent_kernel_type.Kernels_State(sigma(s));     %Gaussian Kernel
    agent = Agent(centres, sigma(s), agentKernel, mdp); 
    [cum_rwd] = PGStochastic(agent, mdp, iterations, momentum(a), c_epsilon(b), sigma(s));    
    cumulativeReward(i, :) = cum_rwd;    
 
        end   
    meanReward = mean(cumulativeReward(:,:));
    Step_Size_Results{a,b} = meanReward;
    
     end

     
    end
    Cum_Rwd_Sigma{s,:} = Step_Size_Results;

end
    %save results
    save 'All Results SPG Classical Momentum.mat'



    




