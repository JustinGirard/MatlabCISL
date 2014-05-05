        iterDat = simulation.runActionsAmount;
                iterDatTarg = simulation.runActionsAmountTarget;
                %alpha,gamma,expereince,quality(Q) , iteration,rewd
                learnDat = simulation.learningDataAverages;

                save ('onePFexample_iter', 'iterDat');
                save ('onePFexample_iter_targ', 'iterDatTarg');
                save ('onePFexample_learndat', 'learnDat');
