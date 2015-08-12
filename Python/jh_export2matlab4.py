# -*- coding: utf-8 -*-
"""
Created on Fri Sep  5 10:22:00 2014

@author: jeaninehunnicutt
"""

import os

from friday_harbor.structure import Ontology
from friday_harbor.mask import Mask
import friday_harbor.experiment as experiment
import numpy as np
import scipy.io as sio

# Settings:
data_dir = '/Applications/anaconda/friday_harbor_data'
dataOutDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3'
os.chdir(dataOutDir)
target = []


my_target_structure_acronym_list = ['CP','ACB'] # Adding in the NAc too

ontology = Ontology(data_dir=data_dir)
em = experiment.ExperimentManager(data_dir=data_dir)
#all_cortical_areas = ['FRP','GU','MO','SS', 'VISC','AUD','VIS','ACA','PL','ILA','ORB','AI','RSP','PTL','TE','PERI','ECT']
#per_region = [0]*len(all_cortical_areas)


#compile the list of experiments that we want 
# We need a quick function to remove duplicates from a list.
def f7(seq):
    seen = set()
    seen_add = seen.add
    return [x for x in seq if not (x in seen or seen_add(x))]
    

ontology = Ontology(data_dir=data_dir)
em = experiment.ExperimentManager(data_dir=data_dir)
#all_cortical_areas = ['FRP','GU','MO','SS', 'VISC','AUD','VIS','ACA','PL','ILA','ORB','AI','RSP','PTL','TE','PERI','ECT']
#per_region = [0]*len(all_cortical_areas)

            
#region_specific_injs = [100140756,100140949,100141219,100141599,100141796,100142655,100148142,100149109,112162251,112229103,112306316,112595376,112596790,112670853,112936582,113887162,116903968,117298988,120491896,120814821,120875816,121510421,126117554,126908007,139426984,139520203,141602484,142656218,146077302,156394513,156741826,157062358,157556400,157654817,
#157710335,157711748,158255941,158314278,158435116,159319654,159832064,161458737,166054929,166082128,166083557,166271142,166323186,166323896,166324604,166461899,167794131,168002073,168003640,168163498,168164972,168165712,171276330,176430283,180719293,182467026,182616478,182794184,183461297,183470468,183471174,184167484,184168193,
#263106036,263242463,263780729,264629246,264630019,264630726,266486371,266487079,266644610,272414403,272735030,272735744,272737914,272821309,278317239,278317945,283019341,283020912,286299886,286300594,286312782,286313491,287494320,287495026,287769286,292373346,292374068,292374777,292476595,292792016,292792724,293471629,294396492,294481346,294482052,294484177,297652799,298324391]
# this list was updated 9/23/14 to exclude 272822110 because it is the only posterior MOs included and to include 286299886 because it was abberrently excuded previously

# Update 4/22/15 : New list that has the brains above PLUS Amygdala, Subiculum, SNr, and more Auditory & AI_GI_DI
region_specific_injs = [184168899, 166153483, 296048512, 180917660, 174361746, 182294687, 113144533, 277710753, 125832322, 156493815, 181600380, 146858006, 112881858, 158914182, 100141993, 175263063, 292532065, 178488859, 286610216, 286610923, 182226839, 127795906, 127222723, 157063781, 152994878, 122641784, 127649005, 159319654, 166323896, 183461297, 183470468, 126117554, 161458737, 139426984, 139520203, 112596790, 272737914, 176430283, 100149109, 120491896, 158314278, 264630726, 278317239, 166083557, 182794184, 142656218, 157062358, 272414403, 292476595, 286299886, 263242463, 100140756, 157710335, 287494320, 286313491, 157556400, 156394513, 292374068, 168002073, 182616478, 120814821, 166082128, 112670853, 141602484, 180719293, 168164972, 183471174, 156741826, 287769286, 112306316, 158435116, 283019341, 292374777, 293471629, 294396492, 263106036, 157711748, 168165712, 292792724, 184167484, 112229103, 166271142, 292373346, 184168193, 272735744, 294484177, 159832064, 166054929, 100140949, 100148142, 112595376, 166323186, 171276330, 182467026, 264629246, 292792016, 168003640, 266486371, 266644610, 278317945, 286300594, 120875816, 168163498, 272735030, 286312782, 297652799, 100142655, 112162251, 112936582, 117298988, 126908007, 157654817, 158255941, 166324604, 166461899, 264630019, 283020912, 298324391, 263780729, 266487079, 272821309, 287495026, 121510421, 167794131, 294481346, 294482052, 100141219, 100141599, 100141796, 113887162, 116903968, 146077302]

# Update 4/20/15 : variables to let me test changes to the code without running loops
#expid = 292476595
#expid = 100140756
#curr_acronym = 'CP'


metadata_attributes = ['structure_color',
 'name',
 'structure_name',
 'gender',
 'transgenic_line',
 'wildtype',
 'structure_abbrev',
 'structure_id',
 'strain',
 'injection_coordinates',
 'num_voxels',
 'sum',
 'injection_structures_acronym_list',
 'injection_volume',
 'id']           
             
#target2=target
target2=region_specific_injs; 
           
for expid in target2:
 
    #my_LIMS_id = 277714322
    my_LIMS_id = expid
    
    # Initializations:
    ontology = Ontology(data_dir=data_dir)
    em = experiment.ExperimentManager(data_dir=data_dir)
    
    # Grab the particular experiment:
    my_experiment = em.experiment_by_id(my_LIMS_id)
    
    ## Get the injection site mask for this experiment, and assocaited density values:
    #inj_mask = my_experiment.injection_mask()
    #inj_mask_as_tuple_list = zip(*inj_mask.mask)
    #density_vals = my_experiment.density(mask_obj=inj_mask)

##get the masks and density values for each experiment    
    
    #do right side - the side ipsilateral to the injection
    print "%7s: %3s %7s" % ('Area', '#:', 'mean:')
    regMask = []
    all_density_vals = []
    density_vals = []
    for curr_acronym in my_target_structure_acronym_list:
        curr_id = ontology.acronym_id_dict[curr_acronym]
        m_right = ontology.get_mask_from_id_right_hemisphere_nonzero(curr_id)
        density_vals = my_experiment.density(mask_obj=m_right)
        all_density_vals = np.r_[all_density_vals, density_vals]
                
#        density_vals_clean = density_vals[density_vals>=0]
        #print "%7s: %3s %7.4f" % (curr_acronym, len(density_vals_clean), density_vals_clean.mean()) 
        regMask= regMask + zip(*m_right.mask)
        
    
#    dens = my_experiment.density()
#    dvi = dens[regMask]
    
    
#    ############# From Nick's
#    my_target_structure_acronym_list = ['CP','ACB'] # Adding in the NAc too
#    
#    ipsi_mask = []
#    contra_mask = []
#    # Pull mask voxels here (since we'll be looping through experiments below)
#    for curr_acronym in my_target_structure_acronym_list:
#        curr_id = ontology.acronym_id_dict[curr_acronym]
#        m_right = ontology.get_mask_from_id_right_hemisphere_nonzero(curr_id)
#        m_left = ontology.get_mask_from_id_left_hemisphere_nonzero(curr_id)
#        ipsi_mask = ipsi_mask + zip(*m_right.mask)
#        contra_mask = contra_mask + zip(*m_left.mask) 
#    ##############
    
    #sio.savemat('voxPosR.mat', {'voxPosR':regMask})
    #sio.savemat('voxDensityR.mat', {'voxDensityR':density_vals})

    
    s2='voxDenR_' + str(expid) + '_'+ my_experiment.structure_abbrev + '.mat'
    s1='voxPosR_' + str(expid) + '_'+ my_experiment.structure_abbrev + '.mat'

    sio.savemat(s1, {'voxPosR':regMask})
    sio.savemat(s2, {'voxDenR':all_density_vals})
      
    
    
    #my_exp = em.experiment_by_id(expid)
    #s='voxDensityR_' + str(expid) + '_'+ my_exp.structure_abbrev + '.mat'
    #f=open(s,'w')
    #f.close()
       
    
    
    #do left side - ie contralateral to the injection
    print "%7s: %3s %7s" % ('Area', '#:', 'mean:')
    regMask = []
    injMask = []  #Update 4/20/15
    all_density_vals = []
    density_vals = []
    all_inj_density_vals = [] #Update 4/20/15 
    all_dens = []
    m_inj = []
    dens = []
    inj_density_vals = []
    for curr_acronym in my_target_structure_acronym_list:
        curr_id = ontology.acronym_id_dict[curr_acronym]
        m_left = ontology.get_mask_from_id_left_hemisphere_nonzero(curr_id)
        density_vals = my_experiment.density(mask_obj=m_left)
        all_density_vals = np.r_[all_density_vals, density_vals]
        
#        density_vals_clean = density_vals[density_vals>=0]
        #print "%7s: %3s %7.4f" % (curr_acronym, len(density_vals_clean), density_vals_clean.mean()) 
        regMask= regMask + zip(*m_left.mask)
       
    
    dens = my_experiment.density() #Update 4/20/15
#        all_dens = np.r_[all_dens, dens] #Test 4/20/15
    
    m_inj = my_experiment.injection_mask()    #Update 4/20/15 I think this is what I need to have the masks of the injection sites... 
    inj_density_vals = my_experiment.injection(mask_obj=m_inj) #Update 4/20/15 
    all_inj_density_vals = np.r_[all_inj_density_vals, inj_density_vals] #Update 4/20/15 
    injMask = injMask + zip(*m_inj.mask)     #Update 4/20/15 needed to do this zip thing for the str projection mask, so maybe I need it for the injection one too... 
        
        
#    dens = my_experiment.density()
#    dvc = dens[regMask] #this resulded in a 4D arrag that saved as 1.6GB per side... 
    
    #sio.savemat('voxPosL.mat', {'voxPosL':regMask})
    #sio.savemat('voxDensityL.mat', {'voxDensityL':density_vals})
    
    s2='voxDenL_' + str(expid) + '_'+ my_experiment.structure_abbrev + '.mat'
#    s22='voxDen2_' + str(expid) + '_'+ my_experiment.structure_abbrev + '.mat' #Test 4/20/15
    s1='voxPosL_' + str(expid) + '_'+ my_experiment.structure_abbrev + '.mat'
    s3='voxPosI_' + str(expid) + '_'+ my_experiment.structure_abbrev + '.mat'  #Update 4/20/15
    s4='voxDenI_' + str(expid) + '_'+ my_experiment.structure_abbrev + '.mat'  #Update 4/20/15
#Update 4/20/15: testing this...     
    s5='voxDenD_' + str(expid) + '_'+ my_experiment.structure_abbrev + '.mat'  #Update 4/20/15
#    s6='voxPosX_' + str(expid) + '_'+ my_experiment.structure_abbrev + '.mat'  #Update 4/22/15 trying the injection mask raw
#    s7='voxDenX_' + str(expid) + '_'+ my_experiment.structure_abbrev + '.mat'  #Update 4/22/15 trying the injection densities raw
    

    sio.savemat(s1, {'voxPosL':regMask})
    sio.savemat(s2, {'voxDenL':all_density_vals})
#    sio.savemat(s22, {'voxDen2':all_dens}) #Test 4/20/15
    sio.savemat(s3, {'voxPosInj':injMask})  #Update 4/20/15
    sio.savemat(s4, {'voxDenInj':all_inj_density_vals}) #Update 4/20/15
    sio.savemat(s5, {'voxDenAll':dens})  #Update 4/20/15
#    sio.savemat(s6, {'voxPosInj2':m_inj})  #Update 4/20/15
#    sio.savemat(s7, {'voxDenInj2':inj_density_vals}) #Update 4/20/15
    
    
    a={}   #this is creating a bunch of metadata files for the brains
    for attribute in metadata_attributes:
        a[str(attribute[:28])]=getattr(em.experiment_by_id(expid), attribute)
    filename ='inj_metadata_' + str(expid)  
      
    sio.savemat(filename,{'a':a})

    
# Save the injection specific information to be used in Matlab
injid_file = open('injid.csv', 'w')
for injID in region_specific_injs:
    injid_file.write("%s,%s,%s\n" % (injID, em.experiment_by_id(injID).structure_abbrev, em.experiment_by_id(injID).injection_mask().centroid))
injid_file.close()   
 

#k = em.experiment_by_id(injID).__dict__.keys()  






