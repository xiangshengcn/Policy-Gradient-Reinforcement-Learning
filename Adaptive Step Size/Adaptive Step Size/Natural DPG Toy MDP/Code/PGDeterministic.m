function [cum_rwd] = PGDeterministic(agent, mdp, iterations,  sigma)

fprintf('\Natural Deterministic Policy Gradient\n');

%get return of current policy
cum_rwd = zeros(1,iterations+1);
sample_traj = mdp.H;
cum_rwd(1) = mdp.estCumRwd(@agent.policy, sample_traj);
fprintf(['MDP Estimated Reward= ', num2str(cum_rwd(1)), '\n'])
mdp_type_kernels = AllKernels (GridWorldKernel(mdp));


for p = 2:(iterations+1)
         
    fprintf(['\n**** Iteration p = ', num2str(p-1), ' ******\n']); 

    current_variables = agent.variables;
    
    %pulling trajectory/data at every iteration
    trajectory = mdp.pull_trajs( @agent.policy_exploratory, 1, mdp.H);      
    [prev_state, prev_action, succ_state] = trajectory_data(trajectory);
      
    old_Traj = [prev_state prev_action];
    new_Traj = [succ_state];
                   
     expected_values = Expected_Functions_Class (mdp_type_kernels, agent, old_Traj, new_Traj);   
     %rho_d = Rho_Integrator(expected_values, mdp);  
                            
     [critic] = QFunctionApproxClass(expected_values,mdp, agent, old_Traj, new_Traj); 
           
     [natural_gradient, R] = Natural_Gradient(agent, critic, old_Traj, new_Traj);
     
     gradient_inc = natural_gradient;
   
     
     
 %adaptive step size here - "Adaptive Step-Size for Policy Gradient Methods"
    Grad_Norm = norm(gradient_inc, 2).^2;
    Num_Constant = ( 1 - mdp.gamma ).^3 * sqrt(2*pi) * sigma.^3;
    
    Numerator = Num_Constant * Grad_Norm;
    
    mod_A = 2;
       
    Den_Constant = ( mdp.gamma * sqrt(2*pi) * sigma ) + 2*(1-mdp.gamma)*mod_A;   
    M=1;  
    Den_Constant2 = R * M.^2;
    Grad_One_Norm = norm(gradient_inc,1).^2;
    
    Denominator = Den_Constant * Den_Constant2 * Grad_One_Norm;
    
    eta_k = Numerator/Denominator;
    
    

    agent.update_variables(current_variables);  
    lastReward = mdp.estCumRwd(@agent.policy, sample_traj);
    
    newVariables = current_variables + eta_k * gradient_inc;
    agent.update_variables (newVariables);        
    newReward  = mdp.estCumRwd(@agent.policy, sample_traj);

    if newReward < lastReward
        agent.update_variables(current_variables);
        newReward = lastReward;
    end
    
          
    %reporting the reward
    estRwd = newReward;   
    fprintf(['Estimated Reward from Natural Deterministic Policy Gradient= ', num2str(estRwd), '\n']); 

    fprintf('Step Size = %3d | Sigma =%3d \n', eta_k, sigma);
    
    
    cum_rwd(p) = estRwd;    

end
end  
 









    